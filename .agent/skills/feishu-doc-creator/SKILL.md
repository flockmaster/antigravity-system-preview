---
name: feishu-doc-assistant
description: A full-featured Feishu/Lark document assistant. Can create, read, and update documents via API.
usage: See "Commands" section below.
---

# Feishu Document Assistant

This skill empowers the AI to interact with Feishu/Lark documents. It handles authentication automatically using local configuration.

## Capabilities

1.  **Create**: Create a new Docx, set permissions to "Organization Editable", and send the URL to the user via Feishu message.
2.  **Read**: Read the text content of an existing document.
3.  **Update**: Append text content to an existing document.

## Configuration

Ensure `.agent/skills/feishu-doc-creator/config.json` contains:
- `app_id`
- `app_secret`
- `user_mobile_to_add` (or `user_email_to_add`)

## Commands for AI Agent

### 1. Create a Document
Use this when the user asks to "start a new document", "draft a plan", etc.
```bash
python .agent/skills/feishu-doc-creator/scripts/create_doc.py "Document Title"
```
*   **Effect**: Creates doc -> Sets public permission -> Writes initial content -> Sends URL to user via IM.

### 2. Read a Document
Use this when the user provides a Doc Link/Token and asks "what's in this doc?" or wants to summarize it.
```bash
python .agent/skills/feishu-doc-creator/scripts/read_doc.py <doc_token_or_url>
```
*   **Output**: Returns the markdown-formatted text content of the document.

### 3. Update/Append to a Document
Use this when the user wants to "add notes", "write meeting minutes", or "continue writing" to an existing doc.
```bash
python .agent/skills/feishu-doc-creator/scripts/update_doc.py <doc_token_or_url> "Content string to append"
```
*   **Note**: Currently supports appending text to the end of the document.

## Dependencies

- `requests` (Standard in most environments)
