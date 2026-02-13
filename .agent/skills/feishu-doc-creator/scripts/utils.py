import requests
import json
import sys
import os

# Load Config
CONFIG_PATH = os.path.join(os.path.dirname(__file__), '../config.json')

def load_config():
    try:
        with open(CONFIG_PATH, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print("Error: config.json not found")
        sys.exit(1)

CONFIG = load_config()
APP_ID = CONFIG.get('app_id')
APP_SECRET = CONFIG.get('app_secret')

# Get Tenant Access Token
def get_tenant_access_token():
    if not APP_ID or not APP_SECRET:
        print("Error: app_id and app_secret must be set in config.json")
        sys.exit(1)
        
    url = "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal"
    headers = {"Content-Type": "application/json; charset=utf-8"}
    payload = {"app_id": APP_ID, "app_secret": APP_SECRET}
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        if response.status_code == 200 and response.json().get("code") == 0:
            return response.json().get("tenant_access_token")
        print(f"❌ Failed to get token: {response.text}")
    except Exception as e:
        print(f"❌ Connection error: {e}")
    return None
