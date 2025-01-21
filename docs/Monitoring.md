# 监控系统配置指南

本文档介绍如何安装、配置和卸载各个组件的监控。

## 监控组件说明

监控系统分为以下几个部分：

1. 基础监控组件
   - Prometheus：时序数据库，用于存储监控指标
   - Grafana：可视化平台，用于展示监控数据
   - Alertmanager：告警管理器，用于处理和发送告警
   - Node Exporter：系统指标收集器

2. Nginx 监控
   - Nginx Exporter：收集 Nginx 状态指标
   - Nginx 告警规则
   - Nginx Grafana 仪表盘

3. PHP-FPM 监控
   - PHP-FPM Exporter：收集 PHP-FPM 状态指标
   - PHP-FPM 告警规则
   - PHP-FPM Grafana 仪表盘

## 安装说明

### 1. 安装基础监控组件

```bash
ansible-playbook monitoring-base.yml -K
```

这将安装：
- Prometheus（端口：9090）
- Grafana（端口：3000）
- Alertmanager（端口：9093）
- Node Exporter（端口：9100）

### 2. 安装 Nginx 监控

```bash
ansible-playbook nginx-monitoring.yml -K
```

这将安装：
- Nginx Exporter（端口：9113）
- 配置 Nginx 状态监控
- 导入 Nginx 仪表盘
- 添加 Nginx 告警规则

### 3. 安装 PHP-FPM 监控

```bash
ansible-playbook php-monitoring.yml -K
```

这将安装：
- PHP-FPM Exporter（端口：9253）
- 配置 PHP-FPM 状态监控
- 导入 PHP-FPM 仪表盘
- 添加 PHP-FPM 告警规则

## 卸载说明

### 1. 卸载 PHP-FPM 监控

```bash
ansible-playbook uninstall-php-monitoring.yml -K
```

这将：
- 停止并删除 PHP-FPM Exporter
- 移除 PHP-FPM 告警规则
- 从 Prometheus 中移除 PHP-FPM 监控配置

### 2. 卸载 Nginx 监控

```bash
ansible-playbook uninstall-nginx-monitoring.yml -K
```

这将：
- 停止并删除 Nginx Exporter
- 移除 Nginx 告警规则
- 从 Prometheus 中移除 Nginx 监控配置

### 3. 卸载所有监控组件

```bash
ansible-playbook uninstall-monitoring.yml -K
```

这将完全卸载所有监控组件，包括：
- Prometheus
- Grafana
- Alertmanager
- Node Exporter
- 所有 Exporter
- 所有配置文件和数据

## 访问方式

1. Grafana 仪表盘
   - URL: http://localhost:3000
   - 默认用户名：admin
   - 默认密码：grafana

2. Prometheus
   - URL: http://localhost:9090

3. Alertmanager
   - URL: http://localhost:9093

## 告警配置

1. Nginx 告警：
   - Nginx 进程停止
   - 请求量异常
   - 错误率过高
   - 响应时间过长

2. PHP-FPM 告警：
   - PHP-FPM 进程停止
   - 进程数过高
   - 请求队列堆积
   - 内存使用过高
   - 慢请求过多

## 注意事项

1. 安装顺序：
   - 先安装基础监控组件
   - 再安装具体服务的监控

2. 卸载顺序：
   - 先卸载具体服务的监控
   - 最后卸载基础监控组件

3. 端口占用：
   - 安装前确保相关端口未被占用
   - 如需修改端口，编辑对应的配置文件

4. 数据备份：
   - 卸载前注意备份重要的监控数据和仪表盘配置 