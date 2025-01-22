#!/bin/bash

# 设置错误时退出
set -e

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查是否有 sudo 权限
echo -e "${YELLOW}检查 sudo 权限...${NC}"
if ! sudo -v; then
    echo -e "${RED}错误: 此脚本需要 sudo 权限才能安装系统依赖${NC}"
    echo -e "请使用以下方式之一运行:"
    echo -e "1. 使用 sudo 用户运行"
    echo -e "2. 确保当前用户在 sudoers 列表中"
    exit 1
fi

echo -e "${YELLOW}Ansible 控制节点安装脚本${NC}"
echo -e "${YELLOW}注意：此脚本仅在控制节点（运行 Ansible 的机器）上执行${NC}"
echo -e "${YELLOW}实际服务（如 Nginx, PHP 等）将由 Ansible 安装到目标服务器${NC}"
echo

# 检查 Python 版本
echo -e "${YELLOW}检查 Python 版本...${NC}"
python3 -V | grep -q "Python 3.1[1-9]" || {
    echo -e "${RED}错误: 需要 Python 3.11 或更高版本${NC}"
    exit 1
}

# 检查操作系统
echo -e "${YELLOW}检查操作系统...${NC}"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" && "$VERSION_ID" == "24.04" ]] || [[ "$ID" == "debian" && "$VERSION_ID" == "12" ]]; then
        echo -e "${GREEN}操作系统检查通过${NC}"
    else
        echo -e "${RED}警告: 推荐使用 Ubuntu 24.04 LTS 或 Debian 12${NC}"
        read -p "是否继续? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

# 安装基础依赖
echo -e "${YELLOW}安装系统级依赖 (需要 sudo 权限)...${NC}"
if [ -f /etc/debian_version ]; then
    sudo apt update
    sudo apt install -y python3-pip python3-venv
fi

# 创建虚拟环境（不需要 sudo）
echo -e "${YELLOW}创建 Python 虚拟环境 (用户级操作)...${NC}"
python3 -m venv .venv
source .venv/bin/activate

# 升级 pip（虚拟环境内，不需要 sudo）
echo -e "${YELLOW}升级 pip (虚拟环境内)...${NC}"
pip install --upgrade pip

# 安装 Ansible 和依赖（虚拟环境内，不需要 sudo）
echo -e "${YELLOW}安装 Ansible 和依赖 (虚拟环境内)...${NC}"
pip install -r "${SCRIPT_DIR}/requirements.txt"

# 验证安装
echo -e "${YELLOW}验证安装...${NC}"
ansible --version
ansible-lint --version
molecule --version
yamllint --version
pre-commit --version

# 创建 ansible.cfg
echo -e "${YELLOW}创建 ansible.cfg...${NC}"
cat > ansible.cfg << EOF
[defaults]
inventory = inventory
roles_path = roles
host_key_checking = False
retry_files_enabled = False
interpreter_python = auto_silent

[ssh_connection]
pipelining = True
EOF

# 创建基本目录结构
echo -e "${YELLOW}创建项目目录结构...${NC}"
mkdir -p {roles,group_vars,host_vars}

# 创建 inventory 文件
echo -e "${YELLOW}创建 inventory 文件...${NC}"
cat > inventory << EOF
[all]
# 在这里添加你的服务器
EOF

echo -e "${GREEN}Ansible 控制节点设置完成!${NC}"
echo -e "注意事项："
echo -e "1. 虚拟环境（.venv）仅包含 Ansible 及其工具"
echo -e "2. 实际服务将由 Ansible 安装到目标服务器"
echo -e "3. 使用以下命令激活虚拟环境后即可使用 Ansible："
echo -e "${YELLOW}source .venv/bin/activate${NC}" 