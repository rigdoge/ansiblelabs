# Percona Server 安装与管理指南

## 目录
1. [安装](#安装)
2. [卸载](#卸载)
3. [监控配置](#监控配置)
4. [监控卸载](#监控卸载)
5. [常见问题](#常见问题)

## 安装

### 基础安装
执行以下命令安装 Percona Server:
```bash
ansible-playbook percona-playbook.yml -K
```

这将会:
1. 安装 Percona Server 8.0 最新版本
2. 配置基本参数
3. 设置 root 密码
4. 安装 MySQL Exporter

### 配置说明
主要配置文件位于 `roles/percona/defaults/main.yml`:
- `percona_version`: Percona Server 版本
- `mysql_root_password`: root 用户密码
- `mysql_port`: MySQL 端口号
- `mysql_bind_address`: 监听地址
- `mysql_max_connections`: 最大连接数
- `innodb_buffer_pool_size`: InnoDB 缓冲池大小
- `innodb_log_file_size`: InnoDB 日志文件大小

## 卸载

执行以下命令卸载 Percona Server:
```bash
ansible-playbook uninstall-percona.yml -K
```

这将会:
1. 停止 MySQL 和 MySQL Exporter 服务
2. 删除所有相关软件包
3. 清理配置文件和数据目录

## 监控配置

### 安装监控
执行以下命令配置监控:
```bash
ansible-playbook percona-monitoring.yml -K
```

这将会:
1. 添加 Prometheus 告警规则
2. 配置 Prometheus 数据源
3. 安装 Grafana 仪表盘

### 告警规则说明
- `MySQLDown`: MySQL 实例停止运行
- `MySQLHighThreadsRunning`: 运行线程数过高
- `MySQLSlowQueries`: 出现慢查询
- `MySQLReplicationLag`: 复制延迟过高
- `MySQLTablespaceFull`: 表空间接近满载

### 监控指标
1. 基础状态
   - 实例存活状态
   - 连接数
   - QPS/TPS
   
2. 性能指标
   - 慢查询数量
   - 线程使用情况
   - InnoDB 缓冲池使用率
   
3. 复制状态
   - 从库延迟
   - 复制错误

## 监控卸载

执行以下命令卸载监控:
```bash
ansible-playbook uninstall-percona-monitoring.yml -K
```

这将会:
1. 删除 Prometheus 告警规则
2. 删除 Prometheus 数据源配置
3. 删除 Grafana 仪表盘

## 常见问题

### 1. MySQL 无法启动
检查:
- 系统日志: `journalctl -u mysql`
- 错误日志: `/var/log/mysql/error.log`
- 配置文件权限: `/etc/mysql/my.cnf`

### 2. 监控数据不显示
检查:
- MySQL Exporter 状态: `systemctl status mysql_exporter`
- 连接权限: 确认 exporter 用户权限
- Prometheus 目标: 访问 `/targets` 页面

### 3. 告警未触发
检查:
- 告警规则语法
- Prometheus 规则加载状态
- AlertManager 配置

### 4. 性能问题
检查:
- 慢查询日志
- 系统资源使用情况
- InnoDB 缓冲池大小

## 维护命令

### 服务管理
```bash
# 启动服务
systemctl start mysql

# 停止服务
systemctl stop mysql

# 重启服务
systemctl restart mysql

# 查看状态
systemctl status mysql
```

### 监控管理
```bash
# 查看 MySQL Exporter 状态
systemctl status mysql_exporter

# 重启 MySQL Exporter
systemctl restart mysql_exporter

# 查看监控指标
curl localhost:9104/metrics
``` 