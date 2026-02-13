import os
import re

def replace_with_opacity(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern: .withOpacity(args)
    # capturing the args.
    # Note: This simple regex stops at the first closing parenthesis.
    # It works for .withOpacity(0.5) and .withOpacity(val)
    # It works for .withOpacity(calc()) as discussed (consumes up to first ), leaves rest)
    # But let's verify.
    
    # Better approach: 
    # Use a loop to find .withOpacity(
    # Then count parens to find the matching closing paren.
    
    new_content = ""
    idx = 0
    length = len(content)
    modified = False
    
    while idx < length:
        # Search for .withOpacity(
        match = content.find(".withOpacity(", idx)
        if match == -1:
            new_content += content[idx:]
            break
        
        # Append part before match
        new_content += content[idx:match]
        
        # Parse arguments
        # Start after .withOpacity(
        arg_start = match + len(".withOpacity(")
        
        # Scan forward for matching closing paren
        paren_count = 1
        curr = arg_start
        while curr < length and paren_count > 0:
            if content[curr] == '(':
                paren_count += 1
            elif content[curr] == ')':
                paren_count -= 1
            curr += 1
        
        if paren_count == 0:
            # curr is now after the closing paren
            arg_content = content[arg_start : curr - 1]
            
            # Replacement
            replacement = f".withValues(alpha: {arg_content})"
            new_content += replacement
            modified = True
            
            # Continue from after the closing paren
            idx = curr
        else:
            # Unbalanced? Should not happen in valid code. 
            # safe fallback: append the matched string and continue
            new_content += content[match:arg_start]
            idx = arg_start

    if modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {file_path}")

def main():
    root_dir = 'lib'
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith('.dart'):
                filepath = os.path.join(dirpath, filename)
                replace_with_opacity(filepath)

if __name__ == '__main__':
    main()
