import requests
import json
import sys
import os
import time

# Import shared modules
try:
    import utils
    import read_doc
    import update_doc
except ImportError:
    # Handle running from distinct directories if needed
    sys.path.append(os.path.dirname(__file__))
    import utils
    import read_doc
    import update_doc

# Load Config via Utils
CONFIG = utils.load_config()
APP_ID = CONFIG.get('app_id')
APP_SECRET = CONFIG.get('app_secret')
USER_EMAIL = CONFIG.get('user_email_to_add')
USER_MOBILE = CONFIG.get('user_mobile_to_add')

# 1. Get Tenant Access Token (delegated to utils)
def get_tenant_access_token():
    return utils.get_tenant_access_token()

# 2. Get User ID (for sending message)
def get_user_id(token, identifier, is_mobile=False):
    if is_mobile:
        url = "https://open.feishu.cn/open-apis/contact/v3/users/batch_get_id?user_id_type=open_id"
        payload = {"mobiles": [identifier]}
    else:
        url = "https://open.feishu.cn/open-apis/contact/v3/users/batch_get_id?user_id_type=open_id"
        payload = {"emails": [identifier]}
        
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    response = requests.post(url, headers=headers, json=payload)
    
    if response.status_code == 200:
        data = response.json()
        if data.get("code") == 0:
            user_list = data.get("data", {}).get("user_list", [])
            if user_list and user_list[0].get("user_id"):
                return user_list[0].get("user_id")
    print(f"❌ Failed to resolve User ID for {identifier}")
    return None

# 3. Create Document
def create_document(token, title):
    url = "https://open.feishu.cn/open-apis/docx/v1/documents"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    payload = {"title": title, "folder_token": ""} # Root folder
    
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 200 and response.json().get("code") == 0:
        return response.json().get("data", {}).get("document", {})
    print(f"❌ Failed to create document: {response.text}")
    return None

# 4. Set Public Permission (Organization Editable)
def set_public_permission(token, doc_id):
    # API: Patch Public Permission
    # Doc: https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/reference/drive-v1/permission-public/patch
    url = f"https://open.feishu.cn/open-apis/drive/v1/permissions/{doc_id}/public?type=docx"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # link_share_entity: "tenant_editable" -> 组织内获得链接可编辑
    payload = {
        "link_share_entity": "tenant_editable",
        "type": "docx" # Important!
    }
    
    response = requests.patch(url, headers=headers, json=payload)
    if response.status_code == 200 and response.json().get("code") == 0:
        print("🔓 Permission set to: Organization Editable")
        return True
    
    print(f"⚠️ Permission Warning: {response.text}")
    print("👉 Hint: Check 'drive:permission:public:update' scope.")
    return False

# 5. Write Content (Rich Formatting)
def write_content(token, doc_id):
    # API: Create Blocks
    doc_url = f"https://open.feishu.cn/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # Professional PRD Template
    template = """
# 🚀 产品需求文档 (PRD)

> **文档状态**: 🟢 进行中 | **负责人**: AI Assistant | **最后更新**: 今日

## 1. 项目背景 (Background)
在此简述项目的核心目标、用户痛点及商业价值。

- **核心目标**: 提升销售转化率，优化客户接待体验。
- **适用范围**: 门店销售顾问、客服团队。

## 2. 核心功能 (Core Features)

| 功能模块 | 优先级 | 描述 |
|---|---|---|
| 到店登记 | P0 | 快速录入自然进店客户，支持OCR识别 |
| 试驾排队 | P0 | 实时展示试驾车队列，预估等待时间 |
| 电子签约 | P1 | 全流程无纸化试驾协议签署 |

## 3. 详细设计 (Detail Design)

### 3.1 到店登记流程
1. 顾问输入手机号
2. 系统自动匹配线索
   - 若存在：自动回显画像
   - 若不存在：手动补全信息
3. 提交后生成接待记录

> 💡 **设计注意**: 无论是否预约，提前到店均需关联原预约单，避免数据重复。

### 3.2 异常处理
- **网络中断**: 支持离线暂存，网络恢复后自动同步。
- **数据冲突**: 以后端最后更新时间戳为准。

## 4. 数据埋点 (Analytics)
- `evt_visit_submit`: 到店登记提交成功
- `evt_test_drive_click`: 点击试驾申请按钮

---
*本文档由 AI 全能助手自动生成*
"""

    import markdown_converter
    blocks = markdown_converter.parse_markdown_to_blocks(template)
    
    payload = {"children": blocks}
    
    response = requests.post(doc_url, headers=headers, json=payload)
    if response.status_code == 200 and response.json().get("code") == 0:
        print("✍️ Content written successfully!")
    else:
        print(f"⚠️ Failed to write content: {response.text}")

# 6. Send Message
def send_message(token, user_id, title, url):
    msg_url = "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    content = {
        "text": f"✅ **文档创建成功**\n\n📄 标题：{title}\n🔗 链接：{url}\n\n已为您预置了标准 PRD 模版，包含：\n- 结构化目录\n- 状态表格\n- 重点提示样式"
    }
    
    payload = {
        "receive_id": user_id,
        "msg_type": "text",
        "content": json.dumps(content)
    }
    
    requests.post(msg_url, headers=headers, json=payload)
    print("📩 Message sent to user.")

def main():
    if len(sys.argv) < 2:
        title = "AI 生成文档"
    else:
        title = sys.argv[1]

    print("🚀 Identifying User...")
    token = get_tenant_access_token()
    if not token: return

    # Determine user identifier
    mobile = str(USER_MOBILE) if USER_MOBILE else None
    email = USER_EMAIL
    
    user_id = None
    if mobile:
        user_id = get_user_id(token, mobile, is_mobile=True)
    elif email:
        user_id = get_user_id(token, email, is_mobile=False)
        
    if not user_id:
        print("❌ Cannot find user to notify. Aborting.")
        return

    print(f"📄 Creating Document: {title}...")
    doc = create_document(token, title)
    if not doc: return
    
    doc_id = doc.get('document_id')
    doc_url = f"https://www.feishu.cn/docx/{doc_id}"
    print(f"🔗 URL: {doc_url}")

    # Set Permission
    set_public_permission(token, doc_id)
    
    # Write Content
    write_content(token, doc_id)
    
    # Notify
    send_message(token, user_id, title, doc_url)
    
    print("\n---------- 🤖 全能助手能力测试 ----------")
    print("⏳ 等待文档索引同步 (2s)...")
    time.sleep(2)
    
    # Test 1: Read Confirmation
    print("📖 [测试] 正在读取刚创建的文档...")
    content = read_doc.read_document_content(token, doc_id)
    if content:
        print(f"✅ 读取成功! 字数: {len(content)}")
    else:
        print("❌ 读取失败")

    # Test 2: Update (Append)
    print("📝 [测试] 正在追加一段新内容...")
    new_text = "【追加记录】这是全能助手在创建文档后自动追加的测试内容。\n此操作证明了 Bot 具备对该文档的完整编辑能力。"
    success = update_doc.append_content(token, doc_id, new_text)
    
    if success:
        print("✅ 追加成功!")
        # Test 3: Re-read to verify
        print("📖 [测试] 再次读取以验证...")
        time.sleep(1)
        updated_content = read_doc.read_document_content(token, doc_id)
        if "追加记录" in updated_content:
            print("🎉 验证成功! 文档已更新。")
        else:
            print("⚠️ 验证失败: 未读到追加的内容。")
    
    print("----------------------------------------\n")
    print("✅ All Done!")

if __name__ == "__main__":
    main()
