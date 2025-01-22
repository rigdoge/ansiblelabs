# Cursor Rules for AnsibleLabs Project

## 项目架构

### 1. Web 服务层
- **Nginx**
  - 作为 Web 服务器
  - 配置位于 `roles/nginx/`
  - 监控通过 nginx-exporter 实现

- **PHP-FPM**
  - PHP 应用运行环境
  - 配置位于 `roles/php/`
  - 监控通过 php-fpm-exporter 实现

### 2. 数据库层
- **Percona**
  - MySQL 的企业级分支
  - 配置位于 `roles/percona/`
  - 包含监控配置

### 3. 消息队列
- **RabbitMQ**
  - 消息中间件
  - 配置位于 `roles/rabbitmq/`
  - 版本：3.13.x
  - 依赖 Erlang 26.0+

### 4. 监控系统
- **Prometheus**
  - 监控数据收集
  - 配置位于 `roles/prometheus/`

- **Alertmanager**
  - 告警管理
  - 配置位于 `roles/alertmanager/`

- **Grafana**
  - 数据可视化
  - 配置位于 `roles/grafana/`

- **Exporters**
  - Node Exporter：系统监控
  - Nginx Exporter：Nginx 监控
  - PHP-FPM Exporter：PHP-FPM 监控

## 开发规范

### 1. 代码规范
- 使用 Ansible Lint 检查代码
- 遵循 YAML 格式规范
- 使用 Git 提交规范

### 2. 测试规范
- 使用 Molecule 进行角色测试
- 提供卸载脚本以支持回滚
- 测试环境使用 Ubuntu 24.04

### 3. 文档规范
- 每个角色必须包含 README.md
- 配置变更必须更新文档
- 关键配置必须有注释说明

### 4. 安全规范
- 移除默认用户和密码
- 使用 Vault 加密敏感信息
- 配置适当的访问权限

### 5. 监控规范
- 每个组件必须配置监控
- 提供标准的告警规则
- 监控数据需要持久化

## 部署流程

### 1. 基础设施
1. 安装基础系统组件
2. 配置系统参数
3. 安装监控组件

### 2. 应用服务
1. 部署 Nginx
2. 部署 PHP-FPM
3. 部署 Percona
4. 部署 RabbitMQ

### 3. 监控配置
1. 配置各组件 Exporter
2. 配置 Prometheus 规则
3. 配置 Grafana 面板

## 维护规范

### 1. 版本控制
- 使用语义化版本号
- 保持依赖版本最新
- 记录版本更新日志

### 2. 备份策略
- 定期备份配置文件
- 备份监控数据
- 备份数据库数据

### 3. 更新策略
- 先在测试环境验证
- 提供回滚方案
- 记录更新日志

### 4. 问题处理
- 使用监控快速定位问题
- 保持日志完整性
- 定期检查系统状态 