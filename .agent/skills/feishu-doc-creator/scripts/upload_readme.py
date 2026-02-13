import sys
import os

# 将脚本所在目录加入 path，以便导入同目录下的模块
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

import utils
import markdown_converter

def upload_readme(readme_path):
    if not os.path.exists(readme_path):
        print(f"❌ File not found: {readme_path}")
        return

    print(f"📖 Reading {readme_path}...")
    with open(readme_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 获取标题（通常是第一行 # 之后的内容，或者文件名）
    title = "单词小助教 - 项目文档 (README)"
    for line in content.split('\n'):
        if line.startswith('# '):
            title = line[2:].strip()
            break

    print(f"🚀 Initializing Feishu Connection...")
    token = utils.get_tenant_access_token()
    if not token:
        print("❌ Failed to get access token.")
        return

    # 1. 创建文档
    import create_doc
    print(f"📄 Creating Document: {title}...")
    doc = create_doc.create_document(token, title)
    if not doc:
        return
    
    doc_id = doc.get('document_id')
    doc_url = f"https://www.feishu.cn/docx/{doc_id}"
    print(f"🔗 Created: {doc_url}")

    # 2. 设置权限 (组织内可编辑)
    create_doc.set_public_permission(token, doc_id)

    # 3. 转换并写入内容
    print("✍️ Parsing Markdown and writing content...")
    blocks = markdown_converter.parse_markdown_to_blocks(content)
    
    # 飞书 API 限制一次创建 blocks 的数量（通常 100 个），如果 readme 很大，可能需要分批
    import requests
    doc_blocks_url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # 分批写入 (每批 50 个 block)
    batch_size = 50
    for i in range(0, len(blocks), batch_size):
        batch = blocks[i:i + batch_size]
        payload = {"children": batch}
        response = requests.post(doc_blocks_url, headers=headers, json=payload)
        if response.status_code == 200 and response.json().get("code") == 0:
            print(f"✅ Batch {i//batch_size + 1} written.")
        else:
            print(f"⚠️ Batch {i//batch_size + 1} failed: {response.text}")

    # 4. 通知用户
    config = utils.load_config()
    user_mobile = config.get('user_mobile_to_add')
    user_email = config.get('user_email_to_add')
    
    user_id = None
    if user_mobile:
        user_id = create_doc.get_user_id(token, str(user_mobile), is_mobile=True)
    elif user_email:
        user_id = create_doc.get_user_id(token, user_email, is_mobile=False)

    if user_id:
        create_doc.send_message(token, user_id, title, doc_url)
        print("📩 Notification sent to Feishu.")
    else:
        print("⚠️ Skip notification: No user info in config.")

    print("\n🎉 Success! You can access the doc at:")
    print(doc_url)

if __name__ == "__main__":
    readme_abs_path = "/Users/tingjing/word_assistant/README.md"
    upload_readme(readme_abs_path)
