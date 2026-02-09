import subprocess
import json
import time
import os
from typing import Generator, Dict, Any, Optional
from codex_dispatcher.core import WorkerResult, Task

class CodexWorker:
    def __init__(self, task: Task, work_dir: str = None, timeout_seconds: int = 900):
        self.task = task
        self.work_dir = work_dir or os.getcwd()
        self.timeout_seconds = timeout_seconds
        self.process: Optional[subprocess.Popen] = None
        self.start_time = 0
        self.result = WorkerResult(success=False, output="")

    def run(self) -> Generator[Dict[str, Any], None, None]:
        """
        Runs the worker and yields JSONL events.
        Process status and result are stored in self.result after iteration completes.
        """
        # "codex exec --json --full-auto --output-last-message result_{id}.md 'TASK DESCRIPTION'"
        cmd = [
            "codex", "exec", 
            "--json", 
            "--full-auto", 
            # "--output-last-message", f"result_{self.task.id}.md", 
            # Output file might be handy but let's stick to stdout for now or capture it
            self.task.description
        ]

        # print(f"Executing: {' '.join(cmd)}")
        
        try:
            self.process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                cwd=self.work_dir,
                text=True, # text=True is alias for universal_newlines=True
                bufsize=1 # Line buffered
            )
            self.start_time = time.time()

            full_output = []

            # Read stdout line by line
            while True:
                # Check timeout
                if time.time() - self.start_time > self.timeout_seconds:
                    self.process.terminate()
                    self.result.success = False
                    self.result.error_message = "Timeout exceeded"
                    self.result.exit_code = -1
                    # print(f"Worker {self.task.id} TIMEOUT!")
                    yield {"type": "error", "content": "Timeout exceeded"}
                    break
                
                # Non-bocking read is tricky with readline, but bufsize=1 helps.
                # Standard pattern is robust enough if process outputs lines.
                output_line = self.process.stdout.readline()
                
                if output_line == '' and self.process.poll() is not None:
                    break
                
                if output_line:
                    line = output_line.strip()
                    full_output.append(line)
                    try:
                        event = json.loads(line)
                        yield event
                    except json.JSONDecodeError:
                        # Fallback for non-JSON lines (e.g. strict errors or headers)
                        # yield {"type": "raw_output", "content": line}
                        pass

            # Wait for process to finish getting exit code
            self.process.wait()
            
            # Check return code
            self.result.exit_code = self.process.returncode
            if self.process.returncode == 0:
                self.result.success = True
            else:
                self.result.success = False
                # Read stderr for error message
                stderr_out = self.process.stderr.read()
                if stderr_out:
                    self.result.error_message = stderr_out.strip()
            
            self.result.output = "\n".join(full_output)

        except FileNotFoundError:
            self.result.success = False
            self.result.error_message = "Command 'codex' not found. Please ensure codex-cli is installed."
            yield {"type": "error", "content": self.result.error_message}
            
        except Exception as e:
            self.result.success = False
            self.result.error_message = str(e)
            yield {"type": "error", "content": f"Exception: {str(e)}"}
