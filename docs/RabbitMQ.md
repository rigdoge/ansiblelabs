# RabbitMQ 安装与监控指南

## 版本信息
- RabbitMQ 版本: 3.13.x
- Erlang 版本: 最新稳定版
- RabbitMQ Exporter 版本: 最新稳定版

## 功能特性
- 安装 RabbitMQ 3.13.x
- 配置 RabbitMQ 管理插件
- 设置用户权限和虚拟主机
- 配置 SSL/TLS（可选）
- 启用 Prometheus 指标收集
- 配置监控告警规则
- 提供 Grafana 仪表板

## 安装步骤
1. 安装 RabbitMQ
```bash
ansible-playbook rabbitmq-playbook.yml -K
```

2. 验证安装
```bash
# 检查 RabbitMQ 状态
systemctl status rabbitmq-server

# 检查管理插件
rabbitmq-plugins list

# 检查用户列表
rabbitmqctl list_users
```

3. 访问管理界面
- URL: http://your-server:15672
- 默认用户名: admin
- 默认密码: 在 playbook 中配置

## 监控配置
1. 指标收集
- RabbitMQ Exporter 端口: 9419
- 支持的指标类型：
  - 队列状态
  - 消息吞吐量
  - 连接数
  - 内存使用
  - 磁盘使用

2. 告警规则
- RabbitMQ 服务存活监控
- 队列积压告警
- 内存使用告警
- 磁盘空间告警
- 连接数告警

3. Grafana 仪表板
- 队列监控面板
- 节点状态面板
- 性能指标面板
- 告警状态面板

## 配置文件
主要配置文件位置：
- /etc/rabbitmq/rabbitmq.conf
- /etc/rabbitmq/rabbitmq-env.conf
- /etc/prometheus/rabbitmq.rules.yml

## 常见问题
1. 服务无法启动
- 检查 Erlang 版本兼容性
- 检查配置文件语法
- 检查日志文件

2. 监控数据不显示
- 确认 RabbitMQ Exporter 运行状态
- 检查 Prometheus 配置
- 验证网络连接

## 卸载步骤
```bash
ansible-playbook uninstall-rabbitmq.yml -K
```

## 注意事项
1. 安装前确保：
   - 系统满足最低要求
   - 端口未被占用
   - 磁盘空间充足

2. 安全建议：
   - 更改默认密码
   - 限制管理界面访问
   - 配置 SSL/TLS
   - 设置适当的文件权限

3. 性能优化：
   - 调整内存限制
   - 配置持久化策略
   - 设置合适的队列参数 