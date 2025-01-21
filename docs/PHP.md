# PHP 多版本管理指南

## 安装和配置

### 1. 配置可用版本

编辑 `roles/php/defaults/main.yml` 文件来配置需要的 PHP 版本：

```yaml
# 默认使用的 PHP 版本
php_default_version: "8.2"  # 这里设置默认版本

# 多版本并存配置示例
php_available_versions:
  "8.4":
    status_port: 9004
    priority: 40  # 优先级数字越小，版本越优先
    state: present  # 同时安装所有版本
  "8.3":
    status_port: 9003
    priority: 30
    state: present
  "8.2":
    status_port: 9002
    priority: 20
    state: present  # 当前默认版本
  "8.1":
    status_port: 9001
    priority: 10
    state: present
```

多版本说明：
1. 每个版本使用不同的 status_port 避免端口冲突
2. priority 决定版本切换时的优先级
3. 所有版本都可以同时运行
4. 每个版本独立配置和运行：
   - 独立的 PHP-FPM 进程
   - 独立的扩展配置
   - 独立的监控端点
   - 独立的日志文件

### 2. 安装 PHP

运行 playbook 来安装配置的 PHP 版本：

```bash
ansible-playbook php-playbook.yml -K
```

## 版本管理

### 1. 切换 PHP 版本

使用提供的 `php-switch` 命令来切换默认 PHP 版本：

```bash
# 查看可用版本
php-switch

# 切换到 PHP 8.2
php-switch 8.2

# 切换到 PHP 8.1
php-switch 8.1
```

### 2. 添加新版本

1. 编辑 `roles/php/defaults/main.yml`
2. 在 `php_available_versions` 中添加新版本
3. 设置 `state: present`
4. 运行 playbook 安装

```yaml
php_available_versions:
  "8.4":  # 添加新版本
    status_port: 9004
    priority: 40
    state: present
```

### 3. 卸载版本

1. 编辑 `roles/php/defaults/main.yml`
2. 将要卸载的版本的 `state` 改为 `absent`
3. 运行 playbook 应用更改

```yaml
php_available_versions:
  "8.1":
    status_port: 9001
    priority: 10
    state: absent  # 将被卸载
```

## 监控和告警

### 1. 监控端点配置

每个 PHP 版本都有独立的监控端点：
- PHP 8.1: `:9001/status`
- PHP 8.2: `:9002/status`
- PHP 8.3: `:9003/status`
- PHP 8.4: `:9004/status`

### 2. Prometheus 配置

多版本监控不需要额外配置，PHP-FPM Exporter 会自动发现并监控所有运行中的 PHP-FPM 实例。指标会包含版本标签，例如：
```
php_fpm_processes_total{version="8.2"} 5
php_fpm_processes_total{version="8.3"} 3
```

### 3. 告警规则

告警规则会自动应用到所有 PHP 版本。如果需要为不同版本设置不同的阈值，可以修改 `roles/prometheus/templates/php-fpm.rules.yml.j2`：

```yaml
# 版本特定的进程数告警
- alert: PHPFPMTooManyProcesses82
  expr: php_fpm_processes_total{version="8.2"} > 50
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "PHP 8.2 进程数过多"
    description: "PHP 8.2 进程数达到 {{ $value }}，超过阈值 50"

# 不同版本可以设置不同的内存限制
- alert: PHPFPMHighMemoryUsage83
  expr: php_fpm_memory_usage{version="8.3"} / 1024 / 1024 > 2048  # 2GB
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "PHP 8.3 内存使用过高"
    description: "PHP 8.3 内存使用达到 {{ $value | humanize }}MB"
```

### 4. Grafana 仪表板

Grafana 仪表板已经支持多版本显示：
- 每个指标会按版本分组显示
- 可以使用版本标签筛选
- 支持比较不同版本的性能指标

### 5. 告警通知

告警通知会包含版本信息：
```
🔥 告警触发
告警级别: critical
告警名称: PHPFPMDown
告警主机: localhost
PHP版本: 8.2
告警详情: PHP-FPM 8.2 进程已停止运行
触发时间: 2024-01-21 10:15:00
```

### 6. 日志管理

每个 PHP 版本使用独立的日志文件：
- 错误日志: `/var/log/php/php{VERSION}-error.log`
- 慢查询日志: `/var/log/php/php{VERSION}-slow.log`
- FPM 日志: `/var/log/php/php{VERSION}-fpm.log`

## 常见问题

### 1. 版本切换后 Web 服务器配置

#### 单版本配置
切换 PHP 版本后，需要确保 Web 服务器（如 Nginx）配置指向正确的 PHP-FPM socket：
```nginx
fastcgi_pass unix:/run/php/php[VERSION]-fpm.sock;
```

#### 多版本配置
可以通过 Nginx location 配置支持多个 PHP 版本：
```nginx
# PHP 8.4
location ~ \.php84$ {
    fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}

# PHP 8.3
location ~ \.php83$ {
    fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}

# PHP 8.2 (默认)
location ~ \.php$ {
    fastcgi_pass unix:/run/php/php8.2-fpm.sock;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

使用方法：
- `example.php` - 使用默认版本（8.2）
- `example.php83` - 使用 PHP 8.3
- `example.php84` - 使用 PHP 8.4

### 2. 扩展管理

每个 PHP 版本都有独立的扩展配置。要为特定版本安装新扩展：

1. 编辑 `roles/php/defaults/main.yml` 中的 `php_extensions` 列表
2. 运行 playbook 更新

### 3. 性能调优

可以通过编辑以下文件调整 PHP-FPM 配置：
- `roles/php/templates/www.conf.j2`：进程池配置
- `roles/php/templates/php.ini.j2`：PHP 配置 