# Ubuntu 24.04 Nginx 安装指南

## 1. 安装方式

### 1.1 使用 APT 安装
```bash
# 更新软件源
sudo apt update

# 安装 Nginx
sudo apt install nginx
```

### 1.2 使用官方源安装（推荐）
```bash
# 安装依赖
sudo apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring

# 导入官方 GPG key
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# 添加官方源
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

# 更新并安装
sudo apt update
sudo apt install nginx
```

## 2. 常用命令

### 2.1 服务管理
```bash
# 启动 Nginx
sudo systemctl start nginx

# 停止 Nginx
sudo systemctl stop nginx

# 重启 Nginx
sudo systemctl restart nginx

# 重新加载配置
sudo systemctl reload nginx

# 检查状态
sudo systemctl status nginx
```

### 2.2 配置检查
```bash
# 检查配置文件语法
sudo nginx -t

# 查看编译参数
nginx -V
```

## 3. 配置文件位置
- 主配置文件：`/etc/nginx/nginx.conf`
- 站点配置：`/etc/nginx/conf.d/*.conf`
- 日志文件：`/var/log/nginx/`
- Web 根目录：`/usr/share/nginx/html/`

## 4. 卸载方式

### 4.1 保留配置卸载
```bash
sudo apt remove nginx
```

### 4.2 完全卸载（包括配置）
```bash
# 删除 Nginx 包
sudo apt purge nginx nginx-common nginx-core

# 删除依赖
sudo apt autoremove

# 删除配置目录
sudo rm -rf /etc/nginx

# 删除日志
sudo rm -rf /var/log/nginx

# 删除网站目录
sudo rm -rf /usr/share/nginx

# 删除源配置
sudo rm /etc/apt/sources.list.d/nginx.list
```

## 5. 故障排查

### 5.1 常见错误

1. 启动失败：
```bash
# 查看详细错误信息
sudo systemctl status nginx
sudo journalctl -xeu nginx.service
```

2. 端口冲突：
```bash
# 检查端口占用
sudo lsof -i :80
sudo lsof -i :443
```

3. 权限问题：
```bash
# 检查日志权限
ls -l /var/log/nginx

# 检查配置文件权限
ls -l /etc/nginx/nginx.conf
```

### 5.2 日志查看
```bash
# 访问日志
sudo tail -f /var/log/nginx/access.log

# 错误日志
sudo tail -f /var/log/nginx/error.log
```

## 6. Ansible Playbook 示例

### 6.1 安装 Nginx
```yaml
- name: Install Nginx
  hosts: all
  become: yes
  tasks:
    - name: Install prerequisites
      apt:
        name: 
          - curl
          - gnupg2
          - ca-certificates
          - lsb-release
          - ubuntu-keyring
        state: present
        update_cache: yes

    - name: Add Nginx signing key
      apt_key:
        url: https://nginx.org/keys/nginx_signing.key
        keyring: /usr/share/keyrings/nginx-archive-keyring.gpg
        state: present

    - name: Add Nginx repository
      apt_repository:
        repo: "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu {{ ansible_distribution_release }} nginx"
        filename: nginx
        state: present
        update_cache: yes

    - name: Install Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Start Nginx service
      systemd:
        name: nginx
        state: started
        enabled: yes
```

### 6.2 卸载 Nginx
```yaml
- name: Uninstall Nginx
  hosts: all
  become: yes
  tasks:
    - name: Stop Nginx service
      systemd:
        name: nginx
        state: stopped
        enabled: no
      ignore_errors: yes

    - name: Remove Nginx packages
      apt:
        name: 
          - nginx
          - nginx-common
          - nginx-core
        state: absent
        purge: yes
        autoremove: yes

    - name: Remove Nginx repository
      apt_repository:
        repo: "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu {{ ansible_distribution_release }} nginx"
        filename: nginx
        state: absent

    - name: Remove Nginx files and directories
      file:
        path: "{{ item }}"
        state: absent
      with_items:
        - /etc/nginx
        - /var/log/nginx
        - /usr/share/nginx
        - /etc/apt/sources.list.d/nginx.list
        - /usr/share/keyrings/nginx-archive-keyring.gpg
``` 