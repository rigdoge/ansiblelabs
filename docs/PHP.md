# PHP 多版本管理指南

## 安装和配置

### 1. 配置可用版本

编辑 `roles/php/defaults/main.yml` 文件来配置需要的 PHP 版本：

```yaml
php_available_versions:
  "8.3":
    status_port: 9003
    priority: 30
    state: absent  # 设置为 present 来安装
  "8.2":
    status_port: 9002
    priority: 20
    state: present  # 当前安装
  "8.1":
    status_port: 9001
    priority: 10
    state: present  # 当前安装
```

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

每个 PHP 版本都有独立的监控端点：
- PHP 8.1: `:9001/status`
- PHP 8.2: `:9002/status`
- PHP 8.3: `:9003/status`

可以在 Grafana 仪表板中查看各版本的：
- 进程数
- 内存使用
- 慢请求数
- 请求队列长度

## 常见问题

### 1. 版本切换后 Web 服务器配置

切换 PHP 版本后，需要确保 Web 服务器（如 Nginx）配置指向正确的 PHP-FPM socket：
```
fastcgi_pass unix:/run/php/php[VERSION]-fpm.sock;
```

### 2. 扩展管理

每个 PHP 版本都有独立的扩展配置。要为特定版本安装新扩展：

1. 编辑 `roles/php/defaults/main.yml` 中的 `php_extensions` 列表
2. 运行 playbook 更新

### 3. 性能调优

可以通过编辑以下文件调整 PHP-FPM 配置：
- `roles/php/templates/www.conf.j2`：进程池配置
- `roles/php/templates/php.ini.j2`：PHP 配置 