from dataclasses import dataclass, field
from typing import List, Optional, Any, Dict
from enum import Enum

class TaskStatus(Enum):
    PENDING = "PENDING"
    IN_PROGRESS = "IN_PROGRESS"
    DONE = "DONE"
    BLOCKED = "BLOCKED"
    FAILED = "FAILED"
    SKIPPED = "SKIPPED"
    
    @staticmethod
    def from_str(s: str) -> 'TaskStatus':
        s = s.upper().strip()
        if "DONE" in s: return TaskStatus.DONE
        if "PENDING" in s: return TaskStatus.PENDING
        if "IN_PROGRESS" in s: return TaskStatus.IN_PROGRESS
        if "BLOCKED" in s: return TaskStatus.BLOCKED
        if "FAILED" in s: return TaskStatus.FAILED
        if "SKIPPED" in s: return TaskStatus.SKIPPED
        return TaskStatus.PENDING # Default

@dataclass
class Task:
    id: str
    name: str
    status: TaskStatus
    description: str
    dependencies: List[str] = field(default_factory=list)
    line_number: int = -1  # To help with updating the file later
    raw_status: str = ""   # To help with preserving emoji if needed

@dataclass
class WorkerResult:
    success: bool
    output: str
    error_message: Optional[str] = None
    exit_code: int = 0
