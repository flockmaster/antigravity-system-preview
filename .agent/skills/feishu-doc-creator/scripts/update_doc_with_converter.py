import requests
import sys
import json
import utils
import markdown_converter

def create_and_fill_table(token, doc_id, table_block_spec):
    """
    Creates a table framework and fills content, solving empty line issues.
    """
    url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    rows = table_block_spec["table"]["property"]["row_size"]
    cols = table_block_spec["table"]["property"]["column_size"]
    # In markdown_converter, cells is a flat list of strings
    raw_cells_content = table_block_spec["table"]["cells"]
    
    # 1. Create Empty Table Framework
    empty_table_payload = {
        "children": [{
            "block_type": 31,
            "table": {
                "property": {
                    "row_size": rows,
                    "column_size": cols,
                    "header_row": True
                }
            }
        }]
    }
    
    print("    - Creating empty table structure...")
    resp = requests.post(url, headers=headers, json=empty_table_payload)
    data = resp.json()
    if data.get("code") != 0:
        print(f"❌ Failed to create table framework: {resp.text}")
        return
    
    # 2. Get Cell IDs
    table_info = data["data"]["children"][0]["table"]
    cell_ids = table_info["cells"]
    
    # 3. Fill Content
    print(f"    - Filling {len(raw_cells_content)} cells...")
    for i, cell_id in enumerate(cell_ids):
        if i < len(raw_cells_content):
            content = raw_cells_content[i]
            if not content: continue
            
            cell_children_url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{cell_id}/children"
            
            # Step A: Get default empty block
            list_resp = requests.get(cell_children_url, headers=headers)
            default_blocks = list_resp.json().get("data", {}).get("items", [])
            
            # Step B: Write new content
            # Parse the cell content again to support rich text inside table!
            elements = markdown_converter.parse_text_to_elements(content)
            cell_payload = {
                "children": [{
                    "block_type": 2, # Text
                    "text": {"elements": elements}
                }]
            }
            requests.post(cell_children_url, headers=headers, json=cell_payload)
            
            # Step C: Delete default empty block
            if default_blocks:
                block_id_to_del = default_blocks[0]["block_id"]
                del_url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{cell_id}/children/batch_delete"
                requests.delete(del_url, headers=headers, json={"block_ids": [block_id_to_del]})

def clear_and_update_with_converter(token, doc_id, markdown_content):
    url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    print("🔄 Parsing Markdown with markdown_converter...")
    blocks = markdown_converter.parse_markdown_to_blocks(markdown_content)
    
    if not blocks:
        print("⚠️ No blocks parsed from content.")
        return False

    print(f"📦 Total blocks to handle: {len(blocks)}")
    
    # Batch processing with special Table handling
    current_batch = []
    success = True
    
    def submit_batch(batch):
        if not batch: return True
        payload = {"children": batch}
        print(f"📡 Sending batch of {len(batch)} blocks...")
        response = requests.post(url, headers=headers, json=payload)
        if response.status_code != 200 or response.json().get("code") != 0:
            print(f"❌ Failed to update batch: {response.text}")
            return False
        return True

    for block in blocks:
        if block["block_type"] == 31: # Table
            # 1. Submit pending batch
            if current_batch:
                if not submit_batch(current_batch): success = False
                current_batch = []
            
            # 2. Handle Table specially
            try:
                create_and_fill_table(token, doc_id, block)
            except Exception as e:
                print(f"❌ Table creation error: {e}")
                success = False
        else:
            current_batch.append(block)
            if len(current_batch) >= 50:
                if not submit_batch(current_batch): success = False
                current_batch = []
    
    # Submit remaining
    if current_batch:
        if not submit_batch(current_batch): success = False
            
    if success:
        print("✅ Document updated with professional formatting (Tables included)!")
    return success

def main():
    if len(sys.argv) < 3:
        print("Usage: python update_doc_with_converter.py <doc_token> <markdown_content>")
        return

    doc_arg = sys.argv[1]
    input_content = sys.argv[2]
    
    # Check if input_content is a file path
    import os
    if os.path.exists(input_content) and os.path.isfile(input_content):
        print(f"📂 Reading markdown content from file: {input_content}")
        with open(input_content, 'r', encoding='utf-8') as f:
            markdown_content = f.read()
    else:
        print("📝 Treating input as raw markdown string.")
        markdown_content = input_content
    
    doc_id = doc_arg.split('/')[-1] if 'feishu.cn' in doc_arg else doc_arg
    
    print(f"📝 Professional Formatting Update for: {doc_id}...")
    token = utils.get_tenant_access_token()
    if not token: return
    
    clear_and_update_with_converter(token, doc_id, markdown_content)

if __name__ == "__main__":
    main()
