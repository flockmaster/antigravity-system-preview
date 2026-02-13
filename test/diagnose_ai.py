import os
import base64
import time
import json
import requests
from flask import Flask, render_template_string, jsonify, request

app = Flask(__name__)

# --- 配置信息 (同步自 Flutter AppConfig) ---
DOUBAO_CONFIG = {
    "api_key": "4d3b6638-b7d5-4d81-8150-e52dfba7547c",
    "base_url": "https://ark.cn-beijing.volces.com/api/v3",
    "model": "doubao-seed-1-6-251015"
}

GEMINI_CONFIG = {
    "api_key": "AIzaSyBDT1X20BHGJeMHqI-LcdGpV3pzhZN2mRE",
    "model": "gemini-3-flash-preview" # 严格匹配 Flutter AppConfig
}

IMAGE_PATH = "/Users/tingjing/word_assistant/test/1.jpg"

# 最终优化版 V2：所有字段强约束
TARGET_CONDITION = "用户在视觉上标记的英文单词（如 打钩 √, 圈画 O, 下划线, 括号或荧光笔标记）。"
PROMPT_TEXT = (
    f"你是一个单词提取引擎。识别图中满足条件的单词：{TARGET_CONDITION}\n\n"
    "必须严格按照以下 JSON 数组格式返回。每个对象必须包含所有 5 个字段（不得缺失）：\n"
    "[\n"
    "  {\n"
    "    \"word\": \"单词原文\",\n"
    "    \"phonetic\": \"/音标/\",\n"
    "    \"meaning_full\": \"完整中文义\",\n"
    "    \"meaning_for_dictation\": \"极简中文义\",\n"
    "    \"sentence\": \"简单的英文例句\"\n"
    "  }\n"
    "]\n\n"
    "输出准则：\n"
    "1. 字段完整性：word, phonetic, meaning_full, meaning_for_dictation, sentence 必须全部返回。\n"
    "2. 例句要求：为每个单词生成一个适合小学生难度的、不超过 10 个词的简单英文例句。\n"
    "3. 音标要求：必须包含标准美式 IPA 音标。\n"
    "4. 格式要求：纯 JSON 数组，严禁包含 Markdown 标签或任何其它非 JSON 文字。"
)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>AI 响应性能诊断 - 多模型对比</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background: #f5f5f7; color: #1d1d1f; max-width: 1000px; margin: 40px auto; padding: 0 20px; }
        .card { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); margin-bottom: 24px; }
        .stats { display: flex; gap: 20px; }
        .stat-item { flex: 1; text-align: center; border-right: 1px solid #eee; }
        .stat-item:last-child { border-right: none; }
        .stat-value { font-size: 24px; font-weight: bold; color: #0071e3; }
        .stat-label { font-size: 12px; color: #86868b; text-transform: uppercase; }
        pre { background: #f0f0f0; padding: 15px; border-radius: 8px; overflow-x: auto; font-size: 13px; line-height: 1.5; white-space: pre-wrap; word-break: break-all; }
        .word-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 15px; }
        .word-card { background: #fafafa; border: 1px solid #e5e5e5; padding: 12px; border-radius: 8px; }
        .word-text { font-weight: bold; font-size: 18px; color: #333; }
        .word-phonetic { color: #666; font-style: italic; }
        .word-meaning { font-size: 14px; margin-top: 5px; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .controls { display: flex; gap: 10px; align-items: center; }
        select { padding: 8px 12px; border-radius: 8px; border: 1px solid #ccc; font-size: 14px; }
        button { background: #0071e3; color: white; border: none; padding: 10px 20px; border-radius: 20px; cursor: pointer; font-weight: 500; }
        button:hover { background: #0077ed; }
        button:disabled { background: #999; }
        #loading { display: none; color: #0071e3; font-weight: 500; margin-top: 10px; }
        .img-preview { max-width: 100%; border-radius: 8px; margin-bottom: 15px; max-height: 300px; object-fit: contain; }
        .prompt-box { background: #eef7ff; border-left: 4px solid #0071e3; padding: 12px; margin: 10px 0; font-size: 14px; }
        .error-msg { color: #d70015; background: #fff1f1; padding: 10px; border-radius: 8px; margin-top: 10px; border: 1px solid #ffcaca; }
        .tag { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; margin-left: 8px; vertical-align: middle; }
        .tag-gemini { background: #e8f0fe; color: #1967d2; }
        .tag-doubao { background: #fce8e6; color: #d93025; }
    </style>
</head>
<body>
    <div class="header">
        <h1>AI 性能诊断 <small style="font-weight:normal; font-size:14px; color:#666;">(v2.0 Beta)</small></h1>
        <div class="controls">
            <select id="modelSelect">
                <option value="doubao">模型: 豆包 (Doubao-Seed)</option>
                <option value="gemini">模型: Gemini 2.0 Flash</option>
            </select>
            <button onclick="runTest()" id="testBtn">开始测试</button>
        </div>
    </div>

    <div class="card">
        <h3>测试环境</h3>
        <p><strong>测试图片:</strong> {{ image_path }}</p>
        <img src="data:image/jpeg;base64,{{ image_base64 }}" class="img-preview" />
        
        <h4>发送的 Prompt：</h4>
        <div class="prompt-box"><pre style="background:transparent; padding:0; margin:0;">{{ prompt_text }}</pre></div>
        
        <div id="loading">🚀 正在请求 AI 接口，请稍后...</div>
    </div>

    <div id="results" style="display:none;">
        <div class="card stats">
            <div class="stat-item">
                <div class="stat-value" id="time-total">0s</div>
                <div class="stat-label">总耗时</div>
            </div>
            <div class="stat-item">
                <div class="stat-value" id="word-count">0</div>
                <div class="stat-label">识别单词数</div>
            </div>
            <div class="stat-item">
                <div class="stat-value" id="status-code">200</div>
                <div class="stat-label">HTTP 状态</div>
            </div>
        </div>

        <div class="card stats" style="background: #fcfcfd;">
            <div class="stat-item">
                <div class="stat-value" id="payload-size" style="font-size: 18px;">0 KB</div>
                <div class="stat-label">请求体积 (Payload)</div>
            </div>
            <div class="stat-item">
                <div class="stat-value" id="token-prompt" style="font-size: 18px;">0</div>
                <div class="stat-label">Prompt Tokens</div>
            </div>
            <div class="stat-item">
                <div class="stat-value" id="token-thinking" style="font-size: 18px; color: #f5a623;">0</div>
                <div class="stat-label">思考 Tokens (Hidden)</div>
            </div>
            <div class="stat-item">
                <div class="stat-value" id="token-output" style="font-size: 18px;">0</div>
                <div class="stat-label">输出 Tokens</div>
            </div>
        </div>

        <div id="thinking-explanation" class="prompt-box" style="display:none; background: #fffbe6; border-left-color: #f5a623; font-size: 12px;">
            ⚠️ <strong>关于 thoughtSignature：</strong> 这是 Gemini 思考过程的加密签名。即便返回的是 JSON，Gemini 内部也会进行空转思考（Thoughts）。它会计入 Token 消耗并占用生成时间。
        </div>

        <div id="error-container" style="display:none;" class="error-msg"></div>

        <div class="card">
            <h3>识别到的单词</h3>
            <div id="word-container" class="word-grid"></div>
        </div>

        <div class="card">
            <h3>原始 JSON 响应</h3>
            <pre id="raw-json"></pre>
        </div>
    </div>

    <script>
        async function runTest() {
            const btn = document.getElementById('testBtn');
            const loader = document.getElementById('loading');
            const results = document.getElementById('results');
            const errBox = document.getElementById('error-container');
            const model = document.getElementById('modelSelect').value;
            
            btn.disabled = true;
            loader.style.display = 'block';
            results.style.display = 'none';
            errBox.style.display = 'none';

            const startTime = performance.now();
            try {
                const response = await fetch(`/api/test?type=${model}`);
                const data = await response.json();
                const endTime = performance.now();

                document.getElementById('time-total').innerText = ((endTime - startTime) / 1000).toFixed(2) + 's';
                document.getElementById('status-code').innerText = data.status || 500;
                document.getElementById('payload-size').innerText = data.payload_kb + ' KB';
                document.getElementById('token-prompt').innerText = data.usage.prompt || 0;
                document.getElementById('token-thinking').innerText = data.usage.thinking || 0;
                document.getElementById('token-output').innerText = data.usage.output || 0;

                const thinkingBox = document.getElementById('thinking-explanation');
                thinkingBox.style.display = data.usage.thinking > 0 ? 'block' : 'none';
                
                if (data.status !== 200) {
                    errBox.innerText = `错误信息: ${data.error || '未知错误'}`;
                    errBox.style.display = 'block';
                }

                document.getElementById('raw-json').innerText = JSON.stringify(data.raw || data, null, 2);
                
                const words = data.words || [];
                document.getElementById('word-count').innerText = words.length;
                
                const container = document.getElementById('word-container');
                container.innerHTML = '';
                words.forEach(w => {
                    const div = document.createElement('div');
                    div.className = 'word-card';
                    div.innerHTML = `
                        <div class="word-text">${w.word}</div>
                        <div class="word-phonetic">${w.phonetic || ''}</div>
                        <div class="word-meaning">${w.meaning_for_dictation || w.meaning_full || ''}</div>
                        <div style="font-size: 12px; color: #888; margin-top: 8px; font-style: italic;">${w.sentence || ''}</div>
                    `;
                    container.appendChild(div);
                });

                results.style.display = 'block';
            } catch (e) {
                console.error(e);
                alert('请求异常，请查看开发者工具控制台');
            } finally {
                btn.disabled = false;
                loader.style.display = 'none';
            }
        }
    </script>
</body>
</html>
"""

def get_image_base64(path):
    with open(path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def call_doubao(image_b64):
    headers = {
        'Authorization': f'Bearer {DOUBAO_CONFIG["api_key"]}',
        'Content-Type': 'application/json',
    }
    # 切换到标准的 chat/completions 接口，并设置 reasoning_effort
    payload = {
        "model": DOUBAO_CONFIG["model"],
        "reasoning_effort": "minimal",  # 关键：设置为 minimal 以禁用深度思考，追求极速响应
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": PROMPT_TEXT},
                    {
                        "type": "image_url", 
                        "image_url": {"url": f"data:image/jpeg;base64,{image_b64}"}
                    }
                ]
            }
        ],
        "stream": False
    }
    
    payload_str = json.dumps(payload)
    payload_kb = len(payload_str.encode('utf-8')) / 1024
    
    start = time.time()
    # 注意：这里从 /responses 切换到了更通用的 /chat/completions
    url = f"{DOUBAO_CONFIG['base_url']}/chat/completions"
    resp = requests.post(url, headers=headers, data=payload_str, timeout=60)
    duration = time.time() - start
    
    words = []
    usage = {"prompt": 0, "thinking": 0, "output": 0}
    raw_json = {}
    try:
        raw_json = resp.json()
        # Chat Completion 的解析逻辑
        content = raw_json['choices'][0]['message']['content']
        # 清理 JSON Markdown 标识
        text = content.strip().strip('`').replace('json\n', '')
        words = json.loads(text)
        
        usage_data = raw_json.get('usage', {})
        usage = {
            "prompt": usage_data.get('prompt_tokens', 0),
            "thinking": usage_data.get('reasoning_tokens', 0), # 观察是否还有推理 token
            "output": usage_data.get('completion_tokens', 0)
        }
    except Exception as e:
        print(f"Doubao Parse Error: {e}")
    
    return {
        "status": resp.status_code, 
        "duration": duration, 
        "words": words, 
        "payload_kb": round(payload_kb, 2),
        "usage": usage,
        "raw": raw_json if resp.status_code == 200 else resp.text
    }

def call_gemini(image_b64):
    # 使用 Google AI REST API
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_CONFIG['model']}:generateContent?key={GEMINI_CONFIG['api_key']}"
    payload = {
        "contents": [{
            "parts": [
                {"text": PROMPT_TEXT},
                {"inline_data": {"mime_type": "image/jpeg", "data": image_b64}}
            ]
        }],
        "generationConfig": {
            "responseMimeType": "application/json"
        }
    }
    
    payload_str = json.dumps(payload)
    payload_kb = len(payload_str.encode('utf-8')) / 1024

    start = time.time()
    resp = requests.post(url, data=payload_str, headers={"Content-Type": "application/json"}, timeout=60)
    duration = time.time() - start
    
    words = []
    usage = {"prompt": 0, "thinking": 0, "output": 0}
    raw_json = {}
    try:
        raw_json = resp.json()
        text = raw_json['candidates'][0]['content']['parts'][0]['text']
        words = json.loads(text)
        
        usage_md = raw_json.get('usageMetadata', {})
        usage = {
            "prompt": usage_md.get('promptTokenCount', 0),
            "thinking": usage_md.get('thoughtsTokenCount', 0),
            "output": usage_md.get('candidatesTokenCount', 0)
        }
    except Exception as e:
        print(f"Gemini Parse Error: {e}")
    
    return {
        "status": resp.status_code, 
        "duration": duration, 
        "words": words, 
        "payload_kb": round(payload_kb, 2),
        "usage": usage,
        "raw": raw_json if resp.status_code == 200 else resp.text
    }

@app.route('/')
def home():
    img_b64 = get_image_base64(IMAGE_PATH)
    return render_template_string(
        HTML_TEMPLATE, 
        image_path=IMAGE_PATH,
        image_base64=img_b64,
        prompt_text=PROMPT_TEXT
    )

@app.route('/api/test')
def run_test():
    ai_type = request.args.get('type', 'doubao')
    img_b64 = get_image_base64(IMAGE_PATH)
    
    if ai_type == 'gemini':
        return jsonify(call_gemini(img_b64))
    else:
        return jsonify(call_doubao(img_b64))

if __name__ == '__main__':
    print(f"诊断服务器(v2.0)已启动: http://127.0.0.1:5005")
    app.run(port=5005)
