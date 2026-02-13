import re

def remove_emojis(text):
    # 用户明确要求移除 Emoji (User strictly requested to remove Emojis)
    pattern = re.compile(
        r'[\U00010000-\U0010ffff]|'  # 补充平面 (绝大多数 Emoji)
        r'[\u2600-\u27BF]|'          # 杂项符号和丁字符号
        r'[\u2300-\u23FF]|'          # 杂项技术符号 (比如 ⌨️)
        r'[\u2b50\u2b55\u2b1b\u2b1c]|' # 常用形状/星星
        r'[\u203c\u2049\u2122\u2139\u2194-\u2199\u21a9-\u21aa]' # 常用符号/箭头
    , re.UNICODE)
    return pattern.sub('', text)

def parse_markdown_to_blocks(markdown_text):
    blocks = []
    lines = markdown_text.split('\n')
    
    current_table = []
    in_table = False
    in_code_block = False
    code_block_content = []
    code_language = ""

    for line in lines:
        # 0. Handle Code Blocks
        if line.strip().startswith('```'):
            if in_code_block:
                # End of code block
                in_code_block = False
                blocks.append(create_code_block(code_block_content, code_language))
                code_block_content = []
                code_language = ""
            else:
                # Start of code block
                in_code_block = True
                code_language = line.strip().replace('```', '').strip()
            continue
        
        if in_code_block:
            code_block_content.append(line)
            continue

        stripped = line.strip()
        
        # 1. Handle Tables
        if stripped.startswith('|') and stripped.endswith('|'):
            if not in_table:
                in_table = True
                current_table = []
            # 过滤掉分割线 |---|---|
            if re.match(r'^\|[\s-]+\|.*\|$', stripped) or '---' in stripped:
                continue 
            cells = [c.strip() for c in stripped.strip('|').split('|')]
            current_table.append(cells)
            continue
        else:
            if in_table:
                blocks.append(create_table_block(current_table))
                in_table = False
                current_table = []

        if not stripped:
            continue
            
        clean_text = remove_emojis(stripped).strip()
        if not clean_text: continue

        # 2. Headings (H1 - H9)
        heading_match = re.match(r'^(#+)\s+(.*)', clean_text)
        if heading_match:
            level = len(heading_match.group(1))
            content = heading_match.group(2)
            if level <= 9:
                blocks.append(create_heading_block(content, level))
            else:
                blocks.append(create_text_block(content)) 
            
        # 3. Lists
        elif clean_text.startswith('- '):
            blocks.append(create_list_block(clean_text[2:], ordered=False))
        elif re.match(r'^\d+\.\s', clean_text):
            content = re.sub(r'^\d+\.\s', '', clean_text)
            blocks.append(create_list_block(content, ordered=True))
        elif clean_text.startswith('> '):
            blocks.append(create_callout_block(clean_text[2:]))
        else:
            blocks.append(create_text_block(clean_text))
            
    if in_table and current_table:
        blocks.append(create_table_block(current_table))
        
    return blocks

def create_table_block(rows):
    """
    创建飞书原生表格块 (BlockType 31)。
    """
    if not rows: return create_text_block("")
    
    row_count = len(rows)
    col_count = len(rows[0])
    
    # 清理每个单元格的内容：移除 Emoji，并移除所有空格、换行、回车
    clean_rows = []
    for row in rows:
        clean_row = []
        for cell in row:
            # 1. 移除 Emoji -已取消，保留 Emoji
            text = remove_emojis(cell)
            # 2. 仅移除首尾空格，保留中间空格
            text = text.strip() 
            clean_row.append(text)
        clean_rows.append(clean_row)
    
    return {
        "block_type": 31, # 表格
        "table": {
            "property": {
                "row_size": row_count,
                "column_size": col_count,
                "header_row": True
            },
            "cells": [cell for row in clean_rows for cell in row]
        }
    }

def parse_text_to_elements(text):
    elements = []
    # 简单的解析器：先处理链接，再处理粗体
    # 注意：这是一个简化的解析，不支持嵌套太深
    
    # 将文本拆分为 segments
    # 格式: [type, content, url/style]
    # 简单的做法是：先假设都是 text，然后一轮轮 split
    
    # Step 1: Split by Links [text](url)
    link_pattern = r'(\[.*?\]\(.*?\))'
    parts = re.split(link_pattern, text)
    
    for part in parts:
        if not part: continue
        
        # Check if it is a link
        link_match = re.match(r'^\[(.*?)\]\((.*?)\)$', part)
        if link_match:
            link_text = link_match.group(1)
            link_url = link_match.group(2)
            elements.append({
                "text_run": {
                    "content": link_text,
                    "text_element_style": {
                        "link": {"url": link_url}
                    }
                }
            })
        else:
            # Process Bold inside non-link text
            # Step 2: Split by Bold **text**
            bold_parts = re.split(r'(\*\*.*?\*\*)', part)
            for b_part in bold_parts:
                if not b_part: continue
                if b_part.startswith('**') and b_part.endswith('**') and len(b_part) > 4:
                    content = b_part[2:-2]
                    elements.append({
                        "text_run": {
                            "content": content,
                            "text_element_style": {"bold": True}
                        }
                    })
                else:
                    elements.append({
                        "text_run": {
                            "content": b_part,
                            "text_element_style": {}
                        }
                    })
    return elements

def create_heading_block(text, level):
    block_type = 2 + level
    key = f"heading{level}"
    return {
        "block_type": block_type,
        key: {
            "elements": parse_text_to_elements(text)
        }
    }

def create_text_block(text):
    return {
        "block_type": 2,
        "text": {
            "elements": parse_text_to_elements(text)
        }
    }

def create_list_block(text, ordered=False):
    block_type = 13 if ordered else 12
    key = "ordered" if ordered else "bullet"
    return {
        "block_type": block_type,
        key: {
            "elements": parse_text_to_elements(text)
        }
    }

def create_callout_block(text):
    return {
        "block_type": 19, 
        "callout": {
            "background_color": 5, 
            "elements": parse_text_to_elements(text)
        }
    }

def create_code_block(lines, language):
    # Code block type is 14
    text_content = "\n".join(lines)
    return {
        "block_type": 14,
        "code": {
            "style": {
                "language": 1 # Default to Plain Text
            },
            "elements": [{
                "text_run": {
                    "content": text_content,
                    "text_element_style": {}
                }
            }]
        }
    }
