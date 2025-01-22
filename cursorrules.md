# Cursor Rules for AnsibleLabs Project

## 软件版本要求

### 1. 自动化工具
- **Ansible**: 2.15.*
  - ansible-core: 2.15.*
  - ansible-lint: latest
  - molecule: latest
  - yamllint: latest
  - pre-commit: latest

### 2. Web 服务相关
- **Nginx**: 1.24.*
- **PHP**:
  - PHP 8.3.* (默认版本)
  - PHP 8.2.*
- **Composer**: 2.7.*
- **Varnish**: 7.5.*

### 3. 数据库和缓存
- **Percona**: 8.0.*
- **Redis**: 7.2.*
- **OpenSearch**: 2.12.*

### 4. 消息队列
- **RabbitMQ**: 3.13.7
  - 依赖 Erlang 26.0+

### 5. 管理工具
- **phpMyAdmin**: latest
- **Webmin**: latest
- **fail2ban**: latest
- **certbot**: latest

## 项目架构

### 1. 自动化工具
- **Ansible**
  - 配置管理和自动化部署工具
  - 版本要求：2.15.*
  - 配置文件：
    - ansible.cfg：Ansible 主配置
    - inventory：主机清单
    - group_vars：组变量
    - host_vars：主机变量
  - 代码检查工具：
    - ansible-lint：Ansible 代码规范检查
    - yamllint：YAML 格式检查
    - pre-commit：提交前检查
  - 测试工具：
    - molecule：角色测试框架

### 2. Web 服务层
- **Nginx**
  - 作为 Web 服务器
  - 配置位于 `roles/nginx/`
  - 监控通过 nginx-exporter 实现
  - 版本要求：1.24.*

- **PHP-FPM**
  - PHP 应用运行环境
  - 配置位于 `roles/php/`
  - 监控通过 php-fpm-exporter 实现
  - 多版本支持：
    - PHP 8.3.* (默认)
    - PHP 8.2.*

- **Varnish**
  - HTTP 缓存服务器
  - 版本要求：7.5.*

### 3. 数据库层
- **Percona**
  - MySQL 的企业级分支
  - 配置位于 `roles/percona/`
  - 包含监控配置
  - 版本要求：8.0.*

- **Redis**
  - 内存数据库/缓存
  - 版本要求：7.2.*

- **OpenSearch**
  - 搜索引擎
  - 版本要求：2.12.*

### 4. 消息队列
- **RabbitMQ**
  - 消息中间件
  - 配置位于 `roles/rabbitmq/`
  - 版本：3.13.7
  - 依赖 Erlang 26.0+

### 5. 监控系统
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

### 6. 管理工具
- **phpMyAdmin**
  - 数据库管理界面
  - 使用最新稳定版

- **Webmin**
  - 系统管理界面
  - 使用最新稳定版

- **fail2ban**
  - 安全防护工具
  - 使用最新稳定版

- **certbot**
  - SSL 证书管理
  - 使用最新稳定版

## 开发规范

### 1. Ansible 规范
- 使用 roles 组织代码
- 变量命名使用 snake_case
- 敏感信息使用 vault 加密
- 每个 role 必须包含：
  - defaults/main.yml：默认变量
  - handlers/main.yml：处理器
  - tasks/main.yml：主任务
  - templates/：模板文件
  - tests/：测试文件
  - README.md：文档

### 2. 代码规范
- 使用 Ansible Lint 检查代码
- 遵循 YAML 格式规范
- 使用 Git 提交规范

### 3. 测试规范
- 使用 Molecule 进行角色测试
- 提供卸载脚本以支持回滚
- 测试环境使用 Ubuntu 24.04

### 4. 文档规范
- 每个角色必须包含 README.md
- 配置变更必须更新文档
- 关键配置必须有注释说明

### 5. 安全规范
- 移除默认用户和密码
- 使用 Vault 加密敏感信息
- 配置适当的访问权限

### 6. 监控规范
- 每个组件必须配置监控
- 提供标准的告警规则
- 监控数据需要持久化

## 部署流程

### 1. 环境准备
1. 安装 Ansible 及依赖工具
2. 配置 inventory 文件
3. 配置 group_vars 和 host_vars

### 2. 基础设施
1. 安装基础系统组件
2. 配置系统参数
3. 安装监控组件

### 3. 应用服务
1. 部署 Nginx
2. 部署 PHP-FPM
3. 部署 Percona
4. 部署 RabbitMQ

### 4. 监控配置
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