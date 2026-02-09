import re
from typing import List, Optional
from codex_dispatcher.core import Task, TaskStatus

def _parse_dependencies(dep_str: str) -> List[str]:
    # E.g. "T-001" or "-" or "T-001, T-002"
    dep_str = dep_str.strip()
    if dep_str == "-" or dep_str == "":
        return []
    return [d.strip() for d in dep_str.split(",")]

def parse_task_table(filepath: str) -> List[Task]:
    tasks = []
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    in_task_section = False
    header_found = False
    
    for i, line in enumerate(lines):
        stripped_line = line.strip()
        
        # Detect Task Section Start
        if "## 2. 任务拆解" in line:
            in_task_section = True
            continue 
            
        # Detect End of Section
        if in_task_section and stripped_line.startswith("---") and header_found:
            break # Assume table ends at the next separator
        
        if not in_task_section:
            continue

        # Look for table rows
        if stripped_line.startswith('|'):
            if "ID" in line and "状态" in line: # Header
                header_found = True
                continue
            if "---" in line and "---" in stripped_line: # Table Separator
                continue
            
            # This is a potentially valid task line
            # Format: | ID | Task | Status | Desc | Est | Dep |
            # split('|') results in ['', 'ID', 'Task', 'Status', 'Desc', 'Est', 'Dep', ''] usually
            parts = [p.strip() for p in line.split('|')]
            
            # Ensure enough columns
            if len(parts) >= 7: 
                # parts[0] is empty, parts[1] is ID
                task_id = parts[1]
                if not task_id.startswith("T-"):
                    continue
                
                name_md = parts[2] # May contain **markdown**
                raw_status = parts[3]
                desc = parts[4]
                # est = parts[5]
                dep_str = parts[6]
                
                # Clean up markdown in name if needed, but keeping it raw is OK for display
                status_enum = TaskStatus.from_str(raw_status)
                
                task = Task(
                    id=task_id, 
                    name=name_md, 
                    status=status_enum, 
                    description=desc, 
                    dependencies=_parse_dependencies(dep_str),
                    line_number=i + 1, # 1-based index
                    raw_status=raw_status
                )
                tasks.append(task)
                
    return tasks

def update_task_status(filepath: str, task_id: str, new_status: str) -> bool:
    """
    Updates the status of a specific task in the PRD markdown file.
    Preserves the surrounding table structure.
    """
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    updated_lines = []
    task_found = False
    
    for line in lines:
        stripped = line.strip()
        if stripped.startswith('|') and task_id in line:
            parts = [p.strip() for p in line.split('|')]
            if len(parts) >= 7 and parts[1] == task_id:
                # Reconstruct line. 
                # Original parts: ['', 'ID', 'Name', 'Status', 'Desc', 'Est', 'Dep', '']
                # We only want to change parts[3] (Status)
                
                # Mapping status to icon/text
                icon = "✅" if "DONE" in new_status else \
                       "⏳" if "PENDING" in new_status else \
                       "🔄" if "IN_PROGRESS" in new_status else \
                       "🚫" if "BLOCKED" in new_status else \
                       "⏭️" if "SKIPPED" in new_status else \
                       "🔁" if "RETRY" in new_status else ""
                
                new_status_str = f" {icon} {new_status} "
                
                # Careful reconstruction to preserve naive column separation
                # Split the original line by | but keep delimiters to preserve spacing? 
                # Hard. Simpler to just join with " | " and accept reformatting of that row.
                
                parts[3] = new_status_str
                # Rebuild: empty string at start/end implies | at start/end
                # But split results in empty strings at ends.
                # parts[0] is '', parts[-1] is ''
                
                # We need to be careful about not losing the content of other cells
                # But line.split('|') strips nothing from the content, only separates.
                # However, earlier I did [p.strip() for p...]
                
                # Let's use the split non-stripped to preserve internal spacing if possible?
                # No, standardizing spacing is fine.
                
                new_line = " | ".join(parts) + "\n"
                
                # Verify it starts/ends with | because join puts | between items, but not outside if parts[0] is ''
                # '' joined with others is '| ID | ... |' which is correct.
                
                updated_lines.append(new_line)
                task_found = True
                continue
        
        updated_lines.append(line)

    if task_found:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(updated_lines)
        return True
    
    return False
