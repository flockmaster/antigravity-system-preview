import sys
import os
import requests
import json
import time

# Add local path to import sibling scripts
sys.path.append(os.path.dirname(__file__))
import utils
import markdown_converter
import create_doc # reuse functions

def upload_file_content(token, doc_id, file_path):
    print(f"📖 Reading local file: {file_path}")
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ Failed to read file: {e}")
        return False

    blocks = markdown_converter.parse_markdown_to_blocks(content)
    print(f"🔄 Converting Markdown to Feishu Blocks... Total: {len(blocks)} blocks")
    
    # API: Create Blocks
    doc_url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # Chunking blocks (Feishu limit: 50 per request)
    chunk_size = 50
    for i in range(0, len(blocks), chunk_size):
        chunk = blocks[i:i + chunk_size]
        payload = {"children": chunk}
        
        print(f"📤 Uploading blocks {i+1} to {i+len(chunk)}...")
        response = requests.post(doc_url, headers=headers, json=payload)
        
        if response.status_code != 200 or response.json().get("code") != 0:
            print(f"⚠️ Failed to upload chunk {i}: {response.text}")
            return False
            
    print("✅ All blocks uploaded successfully!")
    return True

def main():
    if len(sys.argv) < 3:
        print("Usage: python upload_file.py <Doc_Title> <File_Path>")
        return

    title = sys.argv[1]
    file_path = sys.argv[2]
    
    if not os.path.exists(file_path):
        print(f"❌ File not found: {file_path}")
        return

    print("🚀 Identifying User...")
    token = utils.get_tenant_access_token()
    if not token: return

    # User ID logic similar to create_doc
    # We can reuse create_doc logic if we import it, or just copy minimal needed parts.
    # To save time and consistency, let's copy the user resolution logic or just call create_doc's function if possible.
    # But create_doc uses global config variables. Let's just re-load config here or rely on utils.
    
    # Re-implementing minimal user logic for standalone robustness
    config = utils.load_config()
    user_email = config.get('user_email_to_add')
    user_mobile = config.get('user_mobile_to_add')
    
    user_id = None
    if user_mobile:
        user_id = create_doc.get_user_id(token, str(user_mobile), is_mobile=True)
    elif user_email:
        user_id = create_doc.get_user_id(token, user_email, is_mobile=False)
        
    if not user_id:
        print("⚠️ Warning: Could not resolve User ID (for notification). Proceeding with doc creation only.")
    
    # Create Doc
    print(f"📄 Creating Document: {title}...")
    doc = create_doc.create_document(token, title)
    if not doc: return
    
    doc_id = doc.get('document_id')
    doc_url = f"https://www.feishu.cn/docx/{doc_id}"
    print(f"🔗 URL: {doc_url}")

    # Set Permissions
    create_doc.set_public_permission(token, doc_id)
    
    # Upload Content
    if upload_file_content(token, doc_id, file_path):
        if user_id:
            # Send Message
            msg_url = "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id"
            headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
            msg_content = {
                "text": f"✅ **文件转文档成功**\n\n📄 标题：{title}\n📂 源文件：{os.path.basename(file_path)}\n🔗 链接：{doc_url}\n\n已自动为您转换了 Markdown 排版。"
            }
            payload = {
                "receive_id": user_id,
                "msg_type": "text",
                "content": json.dumps(msg_content)
            }
            requests.post(msg_url, headers=headers, json=payload)
            print("📩 Notification sent.")
            
if __name__ == "__main__":
    main()
