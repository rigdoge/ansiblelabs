# Telegram 通知测试

## 已配置信息

我们已经配置了 Telegram Bot 用于监控告警：

- Bot Token: `7769020692:AAHcw3raoMSWMxzhasx9gJ4SLsOL5NoAt7c`
- Chat ID: `1171267236`
- 消息格式：HTML
- 配置文件：`roles/alertmanager/templates/alertmanager.yml.j2`

### 快速测试命令

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -d '{"chat_id": "1171267236", "text": "测试消息", "disable_notification": false}' \
     https://api.telegram.org/bot7769020692:AAHcw3raoMSWMxzhasx9gJ4SLsOL5NoAt7c/sendMessage
```

### HTML 格式测试命令

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -d '{"chat_id": "1171267236", "text": "<b>测试标题</b>\n<code>测试代码</code>\n<i>测试斜体</i>", "parse_mode": "HTML"}' \
     https://api.telegram.org/bot7769020692:AAHcw3raoMSWMxzhasx9gJ4SLsOL5NoAt7c/sendMessage
```

## 告警消息模板

我们在 Alertmanager 中配置的告警消息模板：

```
🔥 <b>告警触发</b>
<b>告警级别:</b> {{ .CommonLabels.severity }}
<b>告警名称:</b> {{ .CommonLabels.alertname }}
<b>告警主机:</b> {{ .CommonLabels.instance }}
<b>告警详情:</b> {{ .CommonAnnotations.description }}
<b>触发时间:</b> {{ .StartsAt.Format "2006-01-02 15:04:05" }}

✅ <b>告警恢复</b>
<b>告警级别:</b> {{ .CommonLabels.severity }}
<b>告警名称:</b> {{ .CommonLabels.alertname }}
<b>告警主机:</b> {{ .CommonLabels.instance }}
<b>恢复时间:</b> {{ .EndsAt.Format "2006-01-02 15:04:05" }}
```

## 准备工作

1. 获取 Bot Token
   - 在 Telegram 中找到 @BotFather
   - 发送 `/newbot` 创建新机器人
   - 保存获得的 token

2. 获取 Chat ID
   - 在 Telegram 中找到你创建的 bot
   - 发送任意消息给 bot
   - 访问 `https://api.telegram.org/bot<YourBOTToken>/getUpdates`
   - 在返回的 JSON 中找到 `chat.id`

## 测试命令

### 使用 curl 发送测试消息

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -d '{"chat_id": "YOUR_CHAT_ID", "text": "测试消息", "disable_notification": false}' \
     https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage
```

### 使用 Ansible 发送测试消息

```yaml
- name: 发送 Telegram 测试消息
  uri:
    url: "https://api.telegram.org/bot{{ telegram_bot_token }}/sendMessage"
    method: POST
    body_format: json
    body:
      chat_id: "{{ telegram_chat_id }}"
      text: "测试消息"
      disable_notification: false
  delegate_to: localhost
```

## 常见问题

1. 如果收不到消息：
   - 确认 Bot Token 是否正确
   - 确认 Chat ID 是否正确
   - 检查网络连接是否正常
   - 确认是否已经和 Bot 开始对话

2. 如果返回 401 错误：
   - Bot Token 无效或已过期
   - 需要重新从 @BotFather 获取 token

3. 如果返回 400 错误：
   - Chat ID 可能不正确
   - 消息格式可能有误

## 消息格式化

支持的格式化选项：
- HTML 格式: 添加 `parse_mode: HTML`
- Markdown 格式: 添加 `parse_mode: Markdown`

示例（HTML 格式）：
```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -d '{"chat_id": "YOUR_CHAT_ID", "text": "<b>粗体</b>\n<i>斜体</i>\n<code>代码</code>", "parse_mode": "HTML"}' \
     https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage
``` 