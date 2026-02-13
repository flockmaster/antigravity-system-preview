import requests
import sys
import json
import utils

# 使用飞书 Markdown 块类型更新文档
# 参考文档: https://open.feishu.cn/document/server-docs/docs/docs/docx-v1/document-block/children/create
def clear_and_update(token, doc_id, markdown_content):
    # 1. 获取现有所有块的 ID（为了清空文档，防止重复叠加）
    # 在这个简单的版本中，我们先直接追加。
    # 真正的“清空”需要获取所有 children 然后批量 delete，这里先优化格式问题。
    
    url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # 将 Markdown 文字转换为飞书识别的块
    # 这里我们尝试使用 Markdown 块 (block_type: 1) 或者将文本按行分割成普通文本/标题块
    
    # 飞书 API 的 create children 接口如果传入多行 text，
    # 某些 SDK 或渲染端会将其视为一个大的文本块展示在首行标题或单个卡片中。
    # 我们将其按行初步拆分。
    
    lines = markdown_content.split('\n')
    blocks = []
    
    for line in lines:
        line = line.strip()
        if not line:
            # 空行
            continue
            
        block = {"block_type": 2, "text": {"elements": [{"text_run": {"content": line}}]}}
        
        # 简单的标题识别
        if line.startswith('# '):
            block = {"block_type": 3, "heading1": {"elements": [{"text_run": {"content": line[2:]}}]}}
        elif line.startswith('## '):
            block = {"block_type": 4, "heading2": {"elements": [{"text_run": {"content": line[3:]}}]}}
        elif line.startswith('### '):
            block = {"block_type": 5, "heading3": {"elements": [{"text_run": {"content": line[4:]}}]}}
        elif line.startswith('> '):
            block = {"block_type": 12, "quote": {"elements": [{"text_run": {"content": line[2:]}}]}}
            
        blocks.append(block)
    
    # 飞书 API 单次调用建议不超过 50 个块
    for i in range(0, len(blocks), 50):
        chunk = blocks[i:i + 50]
        payload = {"children": chunk}
        response = requests.post(url, headers=headers, json=payload)
        if response.status_code != 200 or response.json().get("code") != 0:
            print(f"❌ Failed to update chunk {i}: {response.text}")
            return False
            
    print("✅ Content formatted and updated successfully!")
    return True

def main():
    if len(sys.argv) < 3:
        print("Usage: python update_doc_formatted.py <doc_token> <markdown_content>")
        return

    doc_arg = sys.argv[1]
    markdown_content = sys.argv[2]
    
    doc_id = doc_arg.split('/')[-1] if 'feishu.cn' in doc_arg else doc_arg
    
    print(f"📝 Formatting and Updating Document: {doc_id}...")
    token = utils.get_tenant_access_token()
    if not token: return
    
    # 这里我们创建一个新版本，不使用 append 而是通过结构化渲染逻辑
    clear_and_update(token, doc_id, markdown_content)

if __name__ == "__main__":
    main()
