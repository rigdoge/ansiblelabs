# Ansible 安装和使用指南

## 1. 系统要求

### 控制节点要求
- **操作系统**：
  - Ubuntu 24.04 LTS (推荐)
  - Debian 12 (Bookworm)
- **Python 版本**：3.11 或更高
- **CPU 架构**：
  - arm64 (Apple Silicon, AWS Graviton 等)
  - amd64 (x86_64)
- **最低配置**：
  - CPU: 2 核
  - 内存: 4GB
  - 磁盘: 50GB

### 目标节点要求
- 与控制节点相同的操作系统要求
- SSH 服务已启用
- Python 3.x 已安装

## 2. 快速安装

### 2.1 获取安装脚本
```bash
# 克隆项目仓库
git clone https://github.com/rigdoge/ansiblelabs.git
cd ansiblelabs

# 设置脚本执行权限
chmod +x install_ansible.sh
```

### 2.2 运行安装脚本
```bash
# 运行安装脚本（不要使用 sudo）
./install_ansible.sh

# 脚本会在需要时自动请求 sudo 权限
```

注意事项：
- 不要直接使用 sudo 运行脚本
- 脚本会在需要时自动请求权限
- 如果没有 sudo 权限，请联系系统管理员
- 只有系统级依赖安装需要 sudo 权限

### 2.3 激活虚拟环境
```bash
source .venv/bin/activate
```

## 3. 安装过程说明

安装脚本会自动执行以下步骤：

1. **环境检查**：
   - 验证 Python 版本（3.11+）
   - 检查操作系统兼容性
   - 确认 sudo 权限

2. **系统级安装**（需要 sudo）：
   - python3-pip
   - python3-venv

3. **虚拟环境设置**（用户级别）：
   - 创建 Python 虚拟环境
   - 安装 Ansible 及依赖工具
   - 配置基本目录结构

4. **创建配置文件**：
   - ansible.cfg
   - inventory
   - roles/
   - group_vars/
   - host_vars/

## 4. 验证安装

激活虚拟环境后，可以验证各组件是否正确安装：

```bash
# 检查 Ansible 版本
ansible --version

# 检查其他工具
ansible-lint --version
molecule --version
yamllint --version
pre-commit --version
```

## 5. 目录结构

安装完成后，你将获得以下目录结构：
```
./
├── .venv/                  # Python 虚拟环境
├── ansible.cfg            # Ansible 配置文件
├── inventory             # 主机清单
├── roles/               # 角色目录
├── group_vars/         # 组变量
└── host_vars/          # 主机变量
```

## 6. 使用说明

### 6.1 日常使用流程

1. **激活虚拟环境**：
   ```bash
   source .venv/bin/activate
   ```

2. **编辑 inventory 文件**：
   ```bash
   # 添加目标服务器
   vim inventory
   ```

3. **运行 playbook**：
   ```bash
   ansible-playbook your-playbook.yml
   ```

### 6.2 开发工作流

1. **代码检查**：
   ```bash
   # 检查 Ansible 代码规范
   ansible-lint

   # 检查 YAML 语法
   yamllint .
   ```

2. **角色测试**：
   ```bash
   # 使用 molecule 测试角色
   cd roles/your-role
   molecule test
   ```

3. **提交前检查**：
   ```bash
   # 运行 pre-commit 钩子
   pre-commit run --all-files
   ```

## 7. 注意事项

1. **虚拟环境**：
   - `.venv` 目录仅包含 Ansible 工具链
   - 实际服务将安装在目标服务器上
   - 每次使用前需要激活虚拟环境

2. **权限管理**：
   - 安装脚本需要 sudo 权限
   - 日常使用不需要 sudo
   - 目标服务器需要 SSH 访问权限

3. **最佳实践**：
   - 定期更新依赖包
   - 使用版本控制管理代码
   - 遵循项目的代码规范

## 8. 故障排除

### 8.1 常见问题

1. **Python 版本不匹配**：
   ```bash
   # 检查 Python 版本
   python3 -V
   ```

2. **虚拟环境问题**：
   ```bash
   # 重新创建虚拟环境
   rm -rf .venv
   python3 -m venv .venv
   ```

3. **依赖包冲突**：
   ```bash
   # 清理并重新安装依赖
   pip install --upgrade --force-reinstall -r requirements.txt
   ```

### 8.2 获取帮助

- 查看项目文档
- 提交 Issue 到 GitHub
- 联系项目维护者 

## 9. 卸载说明

### 9.1 自动卸载
我们提供了自动卸载脚本：
```bash
# 运行卸载脚本（不要使用 sudo）
./uninstall_ansible.sh

# 脚本会在需要时自动请求 sudo 权限
```

注意事项：
- 不要直接使用 sudo 运行脚本
- 脚本会在需要时自动请求权限
- 可以选择是否删除系统级包
- 重要文件会自动备份

### 9.2 手动卸载步骤

1. **删除虚拟环境**：
   ```bash
   # 确保先退出虚拟环境
   deactivate
   
   # 删除虚拟环境目录
   rm -rf .venv
   ```

2. **删除项目文件**（可选）：
   ```bash
   # 删除配置文件
   rm -f ansible.cfg
   rm -f inventory
   
   # 删除目录
   rm -rf roles/
   rm -rf group_vars/
   rm -rf host_vars/
   ```

3. **删除系统级依赖**（可选，需要 sudo）：
   ```bash
   # 只有在确定这些包不被其他程序使用时才执行
   sudo apt remove python3-pip python3-venv
   sudo apt autoremove
   ```

### 9.3 注意事项

1. **数据备份**：
   - 卸载前备份重要的配置文件
   - 备份 inventory 文件
   - 备份自定义的 roles 和 playbooks

2. **依赖检查**：
   - 确认没有其他项目依赖这个环境
   - 检查是否有正在运行的任务

3. **清理建议**：
   - 建议保留配置文件的备份
   - 可以只删除虚拟环境而保留项目文件
   - 如果要完全删除，确保没有未提交的更改 