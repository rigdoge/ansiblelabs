# Nginx 监控系统

这是一个基于 Ansible 的自动化部署方案，用于安装和配置完整的 Nginx 监控系统，包括 Prometheus、Alertmanager、Nginx Exporter 和 Grafana。

## 系统组件

- **Prometheus**: 监控数据采集和存储系统（端口：9090）
- **Alertmanager**: 告警管理系统（端口：9093）
- **Nginx Exporter**: Nginx 指标收集器（端口：9113）
- **Grafana**: 数据可视化平台（端口：3000）

## 前置条件

- 安装 Ansible
- 目标服务器需要：
  - Debian/Ubuntu 系统
  - sudo 权限
  - 能够访问互联网（用于下载软件包）

## 安装步骤

1. 克隆仓库：
   ```bash
   git clone https://github.com/rigdoge/ansiblelabs.git
   cd ansiblelabs
   ```

2. 修改 inventory 文件，配置目标服务器：
   ```ini
   [nginx]
   localhost ansible_connection=local ansible_become=yes ansible_become_method=sudo
   ```

3. 运行安装命令：
   ```bash
   ansible-playbook monitoring-playbook.yml -K
   ```
   系统会提示输入 sudo 密码。

## 卸载步骤

如果需要卸载监控系统：

```bash
ansible-playbook uninstall-monitoring.yml -K
```

这将删除所有组件，包括配置文件和数据。

## 访问监控界面

安装完成后，可以通过以下地址访问各个组件：

1. **Prometheus**
   - 地址：`http://129.151.159.11:9090`
   - 用途：查询原始监控数据
   - 常用指标：
     - `nginx_up`: Nginx 运行状态
     - `nginx_connections_active`: 当前活跃连接数
     - `nginx_http_requests_total`: 总请求数

2. **Grafana**
   - 地址：`http://129.151.159.11:3000`
   - 默认账号：admin
   - 默认密码：admin
   - 首次登录会要求修改密码
   - 预配置：
     - 已添加 Prometheus 数据源
     - 已导入 Nginx 监控仪表盘

3. **Alertmanager**
   - 地址：`http://129.151.159.11:9093`
   - 用途：管理和查看告警

4. **Nginx Exporter 指标**
   - 地址：`http://129.151.159.11:9113/metrics`
   - 用途：查看原始 Nginx 指标

## 目录结构

```
.
├── monitoring-playbook.yml    # 主安装脚本
├── uninstall-monitoring.yml   # 卸载脚本
└── roles/
    ├── prometheus/           # Prometheus 配置
    ├── alertmanager/        # Alertmanager 配置
    ├── nginx-exporter/      # Nginx Exporter 配置
    └── grafana/             # Grafana 配置
```

## 常见问题

1. **如何修改 Grafana 密码？**
   - 首次登录时系统会自动提示
   - 或在 Grafana UI 中的用户设置中修改

2. **如何添加新的监控目标？**
   - 编辑 `/etc/prometheus/prometheus.yml`
   - 重启 Prometheus：`systemctl restart prometheus`

3. **监控数据保存多久？**
   - Prometheus 默认保存 15 天
   - 可以通过修改 Prometheus 配置更改保留时间

## 安全建议

1. 修改默认密码
2. 限制访问端口
3. 配置 HTTPS
4. 设置防火墙规则

## 维护和故障排除

1. 检查服务状态：
   ```bash
   sudo systemctl status prometheus
   sudo systemctl status alertmanager
   sudo systemctl status nginx-exporter
   sudo systemctl status grafana-server
   ```

2. 查看日志：
   ```bash
   journalctl -u prometheus
   journalctl -u alertmanager
   journalctl -u nginx-exporter
   journalctl -u grafana-server
   ```

## 更新和升级

当需要更新组件版本时，修改相应角色中的版本号，然后重新运行 playbook：

1. 先卸载旧版本：
   ```bash
   ansible-playbook uninstall-monitoring.yml -K
   ```

2. 安装新版本：
   ```bash
   ansible-playbook monitoring-playbook.yml -K
   ``` 