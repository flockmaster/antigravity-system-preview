#!/bin/bash

# 项目配置信息 - 用于各脚本复用
# 请根据实际项目修改以下变量

# 1. 原型同步配置
# 原型 GitHub 仓库地址
PROTOTYPE_REPO_URL="https://github.com/your-org/your-prototypes.git"
# 本地原型存放目录 (相对于项目根目录)
PROTOTYPE_TARGET_DIR="prototypes"

# 2. AI Code Review 配置
# AI API 地址
AI_REVIEW_API_URL="https://api.openai.com/v1/chat/completions"
# AI 模型名称
AI_REVIEW_MODEL="gpt-4o"

# 3. 其他配置
# 项目名称
PROJECT_NAME="Flutter-Project-Template"
