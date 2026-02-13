import requests
import sys
import json
import utils

# API: Create Blocks (Append to Root)
# https://open.feishu.cn/document/server-docs/docs/docs/docx-v1/document-block/children/create
def append_content(token, doc_id, text_content):
    # Append to the root block (doc_id itself is the root block_id)
    url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # Simple text block
    blocks = [
        {
            "block_type": 2, # Text
            "text": {"elements": [{"text_run": {"content": text_content}}]}
        }
    ]
    
    payload = {"children": blocks}
    
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 200 and response.json().get("code") == 0:
        print("✍️ Content appended successfully!")
        return True
    else:
        print(f"❌ Failed to append content: {response.text}")
        return False

def main():
    if len(sys.argv) < 3:
        print("Usage: python update_doc.py <doc_token> <text_to_append>")
        return

    doc_arg = sys.argv[1]
    text_content = sys.argv[2]
    
    doc_id = doc_arg.split('/')[-1] if 'feishu.cn' in doc_arg else doc_arg
    
    print(f"📝 Updating Document: {doc_id}...")
    token = utils.get_tenant_access_token()
    if not token: return
    
    append_content(token, doc_id, text_content)

if __name__ == "__main__":
    main()
