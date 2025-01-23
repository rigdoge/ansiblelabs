# Nginx 服务管理指南

## 1. 系统要求

### 1.1 基础要求
- **操作系统**：Ubuntu 24.04 LTS / Debian 12
- **Nginx 版本**：1.24.*
- **最低配置**：
  - CPU: 1 核
  - 内存: 1GB
  - 磁盘: 10GB

### 1.2 依赖组件
- **监控组件**：
  - Prometheus
  - nginx-exporter
  - Alertmanager
  - Grafana

## 2. 安装配置

### 2.1 自动安装
使用 Ansible Playbook 进行安装：
```bash
# 确保在项目根目录
cd ansiblelabs

# 激活虚拟环境
source .venv/bin/activate

# 运行 Nginx 安装 playbook
ansible-playbook nginx.yml
```

### 2.2 安装过程说明
1. **前置检查**：
   - 系统版本兼容性
   - 端口占用检查（80/443）
   - 依赖包检查

2. **基础安装**：
   - 添加 Nginx 官方源
   - 安装 Nginx 1.24.*
   - 安装必要模块

3. **配置设置**：
   - 优化系统参数
   - 配置主配置文件
   - 配置 SSL 证书
   - 配置访问日志

4. **监控配置**：
   - 安装 nginx-exporter
   - 配置 Prometheus 目标
   - 配置 Grafana 面板
   - 设置告警规则

## 3. 配置文件

### 3.1 主配置文件
位置：`roles/nginx/templates/nginx.conf.j2`
```nginx
user www-data;
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 65535;
    multi_accept on;
    use epoll;
}

http {
    include mime.types;
    default_type application/octet-stream;

    # 日志格式
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    # 访问日志
    access_log /var/log/nginx/access.log main buffer=16k;
    error_log /var/log/nginx/error.log warn;

    # 基础优化
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # SSL 配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # GZIP 压缩
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml;

    # 包含其他配置
    include /etc/nginx/conf.d/*.conf;
}
```

### 3.2 虚拟主机配置
位置：`roles/nginx/templates/vhost.conf.j2`
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name {{ nginx_server_name }};

    # HTTP 重定向到 HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name {{ nginx_server_name }};

    # SSL 配置
    ssl_certificate /etc/nginx/ssl/{{ nginx_server_name }}.crt;
    ssl_certificate_key /etc/nginx/ssl/{{ nginx_server_name }}.key;

    # 安全头部
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    # PHP-FPM 配置
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

## 4. 监控配置

### 4.1 Nginx Exporter
位置：`roles/nginx/templates/nginx-exporter.service.j2`
```ini
[Unit]
Description=Nginx Exporter
After=network.target

[Service]
Type=simple
User=nginx-exporter
ExecStart=/usr/local/bin/nginx-exporter \
    --nginx.scrape-uri=http://localhost/nginx_status \
    --web.listen-address=:9113

[Install]
WantedBy=multi-user.target
```

### 4.2 Prometheus 配置
位置：`roles/prometheus/templates/prometheus.yml.j2`
```yaml
scrape_configs:
  - job_name: 'nginx'
    static_configs:
      - targets: ['localhost:9113']
    metrics_path: /metrics
```

### 4.3 告警规则
位置：`roles/prometheus/templates/nginx.rules.yml.j2`
```yaml
groups:
- name: nginx.rules
  rules:
  - alert: NginxDown
    expr: nginx_up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Nginx 实例已停止"
      description: "服务器 {{ $labels.instance }} 的 Nginx 服务已停止运行"

  - alert: NginxHighHttp4xxErrorRate
    expr: rate(nginx_http_requests_total{status=~"^4.."}[5m]) > 5
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Nginx 4xx 错误率过高"
      description: "服务器 {{ $labels.instance }} 的 4xx 错误率超过阈值"

  - alert: NginxHighHttp5xxErrorRate
    expr: rate(nginx_http_requests_total{status=~"^5.."}[5m]) > 5
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Nginx 5xx 错误率过高"
      description: "服务器 {{ $labels.instance }} 的 5xx 错误率超过阈值"

  - alert: NginxHighConnections
    expr: nginx_connections_current > 10000
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Nginx 连接数过高"
      description: "服务器 {{ $labels.instance }} 的当前连接数超过 10000"
```

## 5. 维护操作

### 5.1 日常维护
1. **日志轮转**：
   ```bash
   # 手动触发日志轮转
   sudo nginx -s reopen
   ```

2. **配置测试**：
   ```bash
   # 测试配置文件
   sudo nginx -t
   ```

3. **平滑重启**：
   ```bash
   # 重新加载配置
   sudo nginx -s reload
   ```

### 5.2 故障排查
1. **查看错误日志**：
   ```bash
   # 实时查看错误日志
   tail -f /var/log/nginx/error.log
   ```

2. **检查连接状态**：
   ```bash
   # 查看当前连接数
   ss -ant | grep :80
   ```

3. **检查进程状态**：
   ```bash
   # 查看 Nginx 进程
   ps aux | grep nginx
   ```

## 6. 卸载说明

### 6.1 自动卸载
使用 Ansible Playbook 进行卸载：
```bash
# 运行卸载 playbook
ansible-playbook uninstall-nginx.yml
```

### 6.2 卸载过程说明
1. **前置操作**：
   - 停止 Nginx 服务
   - 停止 nginx-exporter

2. **删除组件**：
   - 删除 Nginx 包
   - 删除 nginx-exporter
   - 删除配置文件

3. **清理监控**：
   - 删除 Prometheus 目标
   - 删除 Grafana 面板
   - 删除告警规则

4. **数据备份**：
   - 备份配置文件
   - 备份访问日志
   - 备份 SSL 证书

## 7. 最佳实践

### 7.1 安全建议
1. **配置安全**：
   - 禁用不需要的模块
   - 配置适当的访问控制
   - 使用最新的 SSL/TLS 配置

2. **系统安全**：
   - 定期更新系统
   - 配置防火墙规则
   - 监控异常访问

### 7.2 性能优化
1. **系统优化**：
   - 调整系统参数
   - 优化文件描述符限制
   - 配置工作进程数

2. **缓存优化**：
   - 配置页面缓存
   - 启用压缩
   - 优化静态文件服务

### 7.3 监控建议
1. **关键指标**：
   - 请求率
   - 错误率
   - 响应时间
   - 连接数

2. **告警阈值**：
   - 根据实际情况调整
   - 设置合理的告警级别
   - 配置告警通知渠道

## 告警测试

### 停止 Nginx 服务
要测试 Nginx 的停止告警，可以使用 `disable-nginx-autostart.yml` playbook：

```bash
ansible-playbook disable-nginx-autostart.yml --extra-vars "@password.yml"
```

这个 playbook 会：
1. 停止并禁用 Nginx 服务
2. 禁用 Nginx 的自动重启功能
3. 确保 Nginx 完全停止

### 恢复 Nginx 服务
要恢复 Nginx 服务并测试恢复通知，使用 `enable-nginx-autostart.yml` playbook：

```bash
ansible-playbook enable-nginx-autostart.yml --extra-vars "@password.yml"
```

这个 playbook 会：
1. 移除 Nginx 的自动重启限制
2. 启用并启动 Nginx 服务
3. 确保 Nginx-exporter 正常运行
4. 等待服务完全启动

### 告警规则说明
当前配置了以下告警规则：

1. **NginxDown**
   - 触发条件：Nginx 停止运行
   - 等待时间：10秒
   - 严重级别：critical

2. **NginxRestarted**
   - 触发条件：Nginx 在5分钟内发生重启
   - 严重级别：warning

3. **NginxRecovered**
   - 触发条件：Nginx 恢复运行
   - 严重级别：info

### 查看告警状态
可以通过以下方式查看告警：

1. Prometheus UI：访问 http://localhost:9090/alerts
2. Alertmanager UI：访问 http://localhost:9093
3. 命令行查看：
```bash
curl -s http://localhost:9090/api/v1/alerts | jq .
``` 