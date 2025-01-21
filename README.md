# Ansible Nginx 安装项目

这个 Ansible 项目用于自动化安装 Nginx 1.24 版本。

## 前置条件

- 安装 Ansible
- 目标服务器可以通过 SSH 访问
- 目标服务器有 sudo 权限

## 使用方法

1. 编辑 `inventory` 文件，添加你的目标服务器信息：
   ```
   [nginx]
   your-server ansible_host=your-server-ip
   ```

2. 运行 playbook：
   ```bash
   ansible-playbook nginx-playbook.yml
   ```

## 支持的操作系统

- Debian/Ubuntu
- RHEL/CentOS

## 注意事项

- 确保目标服务器能够访问 Nginx 官方源
- 如果使用防火墙，需要开放 80 端口 