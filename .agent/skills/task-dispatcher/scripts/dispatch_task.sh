#!/bin/bash

# dispatch_task.sh (Strict PM Mode)
# 职责: 模拟项目经理(PM)进行严格的任务分发和进度控制。
# 逻辑: 
#   1. PM 识别: 询问 AI "下一个任务ID是什么？"
#   2. Worker 执行: 启动独立会话执行该 ID。

PRD_FILE="$1"

if [ -z "$PRD_FILE" ]; then
    echo "Usage: $0 <path_to_prd.md>"
    exit 1
fi

echo "👨‍💼 启动 PM 调度模式 (Project Manager Dispatch)"
echo "📄 依据文档: $PRD_FILE"

MAX_LOOPS=50
loop_count=0

while [ $loop_count -lt $MAX_LOOPS ]; do
    echo "---------------------------------------------------"
    echo "🔍 Phase 1: PM 正在识别下一个任务..."
    
    # 1. 识别阶段 (Identify)
    # 只让 AI 提取 ID，不涉及任何代码执行。这很快且准确。
    IDENTIFY_PROMPT="请阅读文档 '$PRD_FILE'。
找到任务列表中**顺序第一个**状态为 'PENDING' (待办) 的任务。
请**仅输出该任务的 ID** (例如 'T-001')。
如果所有任务都已标记为 DONE，请仅输出 'DONE'。
不要解释，不要输出其他文字。"
    
    NEXT_TASK_ID=$(codex exec "$IDENTIFY_PROMPT" --full-auto)
    
    # 清理输出 (去除可能的空白符和 Markdown 格式)
    # 有时候 AI 会输出 "**T-001**"，需要清洗
    NEXT_TASK_ID=$(echo "$NEXT_TASK_ID" | tr -d '[:space:]*`')
    
    echo "📋 识别结果: [$NEXT_TASK_ID]"
    
    if [[ "$NEXT_TASK_ID" == "DONE" ]] || [[ -z "$NEXT_TASK_ID" ]]; then
        echo "🎉 所有任务已完成！项目结束。"
        break
    fi
    
    # 2. 执行阶段 (Execute)
    # 这是完全隔离的子任务窗口
    echo "🚀 Phase 2: 正在启动子任务 Worker 执行 [$NEXT_TASK_ID]..."
    
    EXEC_PROMPT="🎯 角色设定
你是一位资深软件工程师 (Worker)。现在接收来自 PM 的特定任务指派。

## 你的任务
目标: 完成任务 **$NEXT_TASK_ID**
依据: 请阅读 \`$PRD_FILE\` 中关于 $NEXT_TASK_ID 的详细描述和依赖。

## 执行步骤
1. **专注执行**: 仅编写与 $NEXT_TASK_ID 相关的代码。不要触碰其他任务。
2. **自我验证**: 编写并运行测试，确保代码质量。
3. **状态汇报**: 任务完成且测试通过后，**必须**直接修改 \`$PRD_FILE\`，将 $NEXT_TASK_ID 的状态改为 '✅ DONE'。

## 约束
- 保持上下文纯净。
- 严禁修改其他任务的状态。
"

    # 调用 Worker
    codex exec "$EXEC_PROMPT" --full-auto
    
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        echo "❌ Worker 执行非正常退出 (Exit Code: $EXIT_CODE)。停止调度。"
        exit 1
    fi

    # 3. 验证阶段 (Verify)
    # 必须确认文件中的状态已变更为 DONE，才算"执行完"
    echo "🕵️ Phase 3: 验证任务 $NEXT_TASK_ID 状态..."
    
    # 简单的 grep 检查 (假设格式比较标准)
    # 查找 Task ID 这一行，看是否包含 "DONE" 或 "Completed"
    # 这里用简单的 grep 可能会误判，但对于标准 PRD 表格通常够用
    TASK_STATUS_CHECK=$(grep "$NEXT_TASK_ID" "$PRD_FILE")
    
    if [[ "$TASK_STATUS_CHECK" == *"DONE"* ]]; then
        echo "✅ 确认任务 $NEXT_TASK_ID 已完成 (Status: DONE)。"
    else
        echo "⚠️  警告: Worker 进程已结束，但文档中任务状态仍未更新为 DONE。"
        echo "     当前行内容: $TASK_STATUS_CHECK"
        echo "🛑 为了防止死循环或重复执行，调度器将在此停止。"
        echo "     请人工检查任务情况，或手动更新 PRD 状态后重新运行此脚本。"
        exit 1
    fi
    
    loop_count=$((loop_count + 1))
    
    echo "⏸️  冷却 3 秒..."
    sleep 3
done

if [ $loop_count -ge $MAX_LOOPS ]; then
    echo "🛑 达到最大循环次数 ($MAX_LOOPS)，强制停止。"
fi
