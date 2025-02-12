# RabbitMQ 安装和配置指南

## 系统要求
- Ubuntu 24.04 LTS
- 最小配置：2 CPU, 4GB RAM, 50GB 磁盘
- 推荐配置：4 CPU, 8GB RAM, 100GB 磁盘

## 软件版本
- RabbitMQ: 3.13.7
- Erlang: 26.0+

## 安装步骤

### 1. 基础安装
运行以下命令安装 RabbitMQ（免密码方式）：
```bash
ansible-playbook rabbitmq-playbook.yml --extra-vars "@password.yml"
```

### 2. 监控配置（可选）
如果需要配置监控，运行：
```bash
ansible-playbook rabbitmq-monitoring.yml
```

## 卸载步骤

### 1. 卸载监控（如果已安装）
```bash
ansible-playbook uninstall-rabbitmq-monitoring.yml
```

### 2. 卸载 RabbitMQ
```bash
ansible-playbook uninstall-rabbitmq.yml
```

## 配置说明
- 管理界面端口：15672
- AMQP 端口：5672
- Prometheus 指标端口：15692

## 注意事项
1. 使用免密码方式运行时，确保 `password.yml` 文件存在并包含以下变量：
```yaml
rabbitmq_admin_user: your_admin_username
rabbitmq_admin_password: your_admin_password
```
2. 建议使用 vault 加密 `password.yml` 文件
3. 安装完成后请及时修改默认密码

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
ansible-playbook rabbitmq-playbook.yml --extra-vars "@password.yml"
```

注意：`password.yml` 文件应包含以下变量：
```yaml
rabbitmq_admin_user: your_admin_username
rabbitmq_admin_password: your_admin_password
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