# 监控组件状态检查

## 1. 服务状态检查

检查所有监控组件的运行状态：

```bash
# 检查 Prometheus
systemctl status prometheus

# 检查 Alertmanager
systemctl status alertmanager

# 检查 Grafana
systemctl status grafana-server

# 检查各个 Exporter
systemctl status node_exporter
systemctl status nginx-exporter
systemctl status rabbitmq-exporter
```

## 2. 端口检查

确认各组件是否正在监听端口：

```bash
# 检查所有监控相关端口
ss -tunlp | grep -E '9090|9093|3000|9100|9113|9419'
```

端口说明：
- 9090: Prometheus
- 9093: Alertmanager
- 3000: Grafana
- 9100: Node Exporter
- 9113: Nginx Exporter
- 9419: RabbitMQ Exporter

## 3. Web 界面访问

各组件的 Web 界面地址：

1. Prometheus: `http://服务器IP:9090`
   - Status -> Targets: 查看所有监控目标的状态
   - Alerts: 查看当前告警规则和状态

2. Alertmanager: `http://服务器IP:9093`
   - 查看当前活动的告警
   - 查看告警的处理状态

3. Grafana: `http://服务器IP:3000`
   - 默认用户名: admin
   - 默认密码: admin
   - 查看监控仪表板

## 4. 日志检查

查看各组件的日志：

```bash
# Prometheus 日志
journalctl -u prometheus -f

# Alertmanager 日志
journalctl -u alertmanager -f

# Grafana 日志
journalctl -u grafana-server -f

# Exporter 日志
journalctl -u node_exporter -f
journalctl -u nginx-exporter -f
journalctl -u rabbitmq-exporter -f
```

## 5. 测试告警通知

1. 检查 Alertmanager 配置：
```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -d '{"chat_id": "1171267236", "text": "🔧 监控系统测试消息", "parse_mode": "HTML"}' \
     https://api.telegram.org/bot7769020692:AAHcw3raoMSWMxzhasx9gJ4SLsOL5NoAt7c/sendMessage
```

2. 检查 Prometheus 告警规则：
```bash
curl http://localhost:9090/api/v1/rules | jq
```

## 6. 常见问题处理

1. 如果服务未运行：
```bash
# 启动服务
sudo systemctl start <服务名>

# 设置开机自启
sudo systemctl enable <服务名>
```

2. 如果端口未监听：
- 检查服务配置文件中的端口设置
- 检查防火墙规则

3. 如果无法访问 Web 界面：
- 检查防火墙设置
- 确认服务器安全组规则 