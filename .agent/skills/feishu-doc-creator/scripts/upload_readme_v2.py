import sys
import os
import requests
import json
import time

# 将脚本所在目录加入 path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

import utils
import markdown_converter

class FeishuTableUploader:
    def __init__(self):
        self.token = utils.get_tenant_access_token()
        self.config = utils.load_config()

    def create_doc(self, title):
        url = "https://open.feishu.cn/open-apis/docx/v1/documents"
        headers = {"Authorization": f"Bearer {self.token}", "Content-Type": "application/json"}
        payload = {"title": title}
        resp = requests.post(url, headers=headers, json=payload)
        return resp.json().get("data", {}).get("document", {})

    def set_permission(self, doc_id):
        url = f"https://open.feishu.cn/open-apis/drive/v1/permissions/{doc_id}/public?type=docx"
        headers = {"Authorization": f"Bearer {self.token}", "Content-Type": "application/json"}
        payload = {"link_share_entity": "tenant_editable", "type": "docx"}
        requests.patch(url, headers=headers, json=payload)

    def write_blocks(self, doc_id, blocks):
        # 飞书创建块接口
        url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children"
        headers = {"Authorization": f"Bearer {self.token}", "Content-Type": "application/json"}
        
        print(f"📦 Total blocks to write: {len(blocks)}")
        
        # 顺序写入逻辑
        current_batch = []
        for b in blocks:
            if b["block_type"] == 31: # Table
                if current_batch:
                    self._submit_batch(url, headers, current_batch)
                    current_batch = []
                self.create_and_fill_table(doc_id, b)
            else:
                current_batch.append(b)
                if len(current_batch) >= 50:
                    self._submit_batch(url, headers, current_batch)
                    current_batch = []
        
        if current_batch:
            self._submit_batch(url, headers, current_batch)

    def _submit_batch(self, url, headers, batch):
        payload = {"children": batch}
        resp = requests.post(url, headers=headers, json=payload)
        if resp.status_code != 200 or resp.json().get("code") != 0:
            print(f"⚠️ Batch submission failed: {resp.text}")

    def create_and_fill_table(self, doc_id, table_block_spec):
        """
        创建表格框架并填充内容，解决空行问题
        """
        url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children"
        headers = {"Authorization": f"Bearer {self.token}", "Content-Type": "application/json"}
        
        rows = table_block_spec["table"]["property"]["row_size"]
        cols = table_block_spec["table"]["property"]["column_size"]
        raw_cells_content = table_block_spec["table"]["cells"]
        
        # 1. 创建空表框架
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
        
        resp = requests.post(url, headers=headers, json=empty_table_payload)
        data = resp.json()
        if data.get("code") != 0:
            print(f"❌ Failed to create table framework: {resp.text}")
            return
        
        # 2. 获取单元格 IDs
        table_info = data["data"]["children"][0]["table"]
        cell_ids = table_info["cells"]
        
        # 3. 填充内容：先添加新块，再删除默认空块（针对每个单元格）
        for i, cell_id in enumerate(cell_ids):
            if i < len(raw_cells_content):
                content = raw_cells_content[i]
                if not content: continue
                
                cell_children_url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{cell_id}/children"
                
                # 第一步：获取默认存在的空块 ID
                list_resp = requests.get(cell_children_url, headers=headers)
                default_blocks = list_resp.json().get("data", {}).get("items", [])
                
                # 第二步：写入新内容块
                cell_payload = {
                    "children": [{
                        "block_type": 2, # Text
                        "text": {"elements": markdown_converter.parse_text_to_elements(content)}
                    }]
                }
                requests.post(cell_children_url, headers=headers, json=cell_payload)
                
                # 第三步：删除原本的默认空块（如果存在）
                if default_blocks:
                    block_id_to_del = default_blocks[0]["block_id"]
                    del_url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{cell_id}/children/batch_delete"
                    requests.delete(del_url, headers=headers, json={"block_ids": [block_id_to_del]})

    def notify(self, title, url):
        user_mobile = self.config.get('user_mobile_to_add')
        user_email = self.config.get('user_email_to_add')
        
        import create_doc
        user_id = None
        if user_mobile:
            user_id = create_doc.get_user_id(self.token, str(user_mobile), is_mobile=True)
        elif user_email:
            user_id = create_doc.get_user_id(self.token, user_email, is_mobile=False)

        if user_id:
            msg_url = "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id"
            headers = {"Authorization": f"Bearer {self.token}", "Content-Type": "application/json"}
            content = {"text": f"📊 **原生表格完美版已生成**\n\n📄 标题：{title}\n🔗 链接：{url}"}
            payload = {"receive_id": user_id, "msg_type": "text", "content": json.dumps(content)}
            requests.post(msg_url, headers=headers, json=payload)

def upload_with_tables(readme_path):
    uploader = FeishuTableUploader()
    
    with open(readme_path, 'r', encoding='utf-8') as f:
        content = f.read()

    title = "单词小助教 - 终极修复版"
    for line in content.split('\n'):
        if line.startswith('# '):
            title = line[2:].strip()
            break

    print(f"📄 Creating Document...")
    doc = uploader.create_doc(title)
    doc_id = doc.get("document_id")
    doc_url = f"https://www.feishu.cn/docx/{doc_id}"
    
    uploader.set_permission(doc_id)
    
    print("✍️ Writing contents...")
    blocks = markdown_converter.parse_markdown_to_blocks(content)
    uploader.write_blocks(doc_id, blocks)
    
    uploader.notify(title, doc_url)
    print(f"\n🎉 Success!\n{doc_url}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
    else:
        file_path = "/Users/tingjing/word_assistant/README.md"
        
    if os.path.exists(file_path):
        upload_with_tables(file_path)
    else:
        print(f"❌ File not found: {file_path}")
