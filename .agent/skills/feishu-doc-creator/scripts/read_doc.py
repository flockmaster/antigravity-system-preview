import requests
import sys
import utils

# API: Get Blocks
# https://open.feishu.cn/document/server-docs/docs/docs/docx-v1/document-block/list
def read_document_content(token, doc_id):
    # Retrieve all blocks from the document
    url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    all_items = []
    page_token = ""
    has_more = True

    while has_more:
        params = {"page_size": 500}
        if page_token:
            params["page_token"] = page_token
            
        response = requests.get(url, headers=headers, params=params)
        
        if response.status_code != 200 or response.json().get("code") != 0:
            print(f"❌ Failed to read document: {response.text}")
            return None
            
        data = response.json().get("data", {})
        items = data.get("items", [])
        all_items.extend(items)
        
        has_more = data.get("has_more", False)
        page_token = data.get("page_token", "")

    # Parse blocks to text
    full_text = []
    # Identify table blocks separately to handle them if needed, but for now simple text
    # The block structure is flat list of blocks. We might need to handle hierarchy if strictly needed,
    # but for simple reading, linear text extraction is usually okay.
    # However, table cells are children of table blocks. This simple script might miss table content
    # if it doesn't traverse children. Let's stick to the current logic which extracts main text, 
    # but be aware tables might be tricky.
    
    # Enhanced mapping
    for item in all_items:
        block_type = item.get("block_type")
        block_data = None
        
        # 2: Text, 3-11: Headings, 12: Bullet, 13: Ordered List, 14: Code, 15: Quote
        # 27: Table (contains cells, cells contain paragraphs... this implementation ignores table structure details)
        
        if block_type == 2: block_data = item.get("text")
        elif block_type == 3: block_data = item.get("heading1")
        elif block_type == 4: block_data = item.get("heading2")
        elif block_type == 5: block_data = item.get("heading3")
        elif block_type == 6: block_data = item.get("heading4")
        elif block_type == 7: block_data = item.get("heading5")
        elif block_type == 8: block_data = item.get("heading6")
        elif block_type == 9: block_data = item.get("heading7")
        elif block_type == 10: block_data = item.get("heading8")
        elif block_type == 11: block_data = item.get("heading9")
        elif block_type == 12: block_data = item.get("bullet")
        elif block_type == 13: block_data = item.get("ordered")
        elif block_type == 14: block_data = item.get("code")
        elif block_type == 15: block_data = item.get("quote")
        elif block_type == 27: 
            full_text.append("\n[Table content skipped in simple view]\n")
            continue

        if block_data:
            elements = block_data.get("elements", [])
            line_parts = []
            for e in elements:
                # Handle Text Run
                if "text_run" in e:
                    content = e["text_run"].get("content", "")
                    link = e["text_run"].get("text_element_style", {}).get("link", {}).get("url", "")
                    if link:
                        line_parts.append(f"[{content}]({link})")
                    else:
                        line_parts.append(content)
                
                # Handle Mention Doc (Sub-PRDs usually appear this way)
                elif "mention_doc" in e:
                    md = e["mention_doc"]
                    title = md.get("title", "Untitled Doc")
                    token = md.get("token", "")
                    url = md.get("url", f"https://feishu.cn/docs/{token}") # Fallback URL construction
                    line_parts.append(f"📄 [子文档: {title}]({url})")

                # Handle File
                elif "file" in e:
                    fname = e["file"].get("name", "File")
                    line_parts.append(f"📎 [文件: {fname}]")

            line_text = "".join(line_parts)
            
            if line_text: # Allow empty lines? maybe not strip() completely if we want spacing
                prefix = ""
                if block_type == 3: prefix = "# "
                elif block_type == 4: prefix = "## "
                elif block_type == 5: prefix = "### "
                elif block_type == 12: prefix = "- "
                elif block_type == 13: prefix = "1. " # Simplified ordered list
                elif block_type == 15: prefix = "> "
                
                full_text.append(f"{prefix}{line_text}")
                
    return "\n\n".join(full_text)

def main():
    if len(sys.argv) < 2:
        print("Usage: python read_doc.py <doc_token_or_url>")
        return

    doc_arg = sys.argv[1]
    # Simple extraction of token if URL is passed
    doc_id = doc_arg.split('/')[-1] if 'feishu.cn' in doc_arg else doc_arg
    
    print(f"📖 Reading Document: {doc_id}...")
    token = utils.get_tenant_access_token()
    if not token: return
    
    content = read_document_content(token, doc_id)
    if content:
        print("\n--- Document Content ---\n")
        print(content)
        print("\n------------------------\n")
    else:
        print("⚠️ Document is empty or unreadable.")

if __name__ == "__main__":
    main()
