#!/bin/bash

# 设置错误时退出
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查是否有 sudo 权限（用于可选的系统级卸载）
echo -e "${YELLOW}检查 sudo 权限...${NC}"
if ! sudo -v; then
    echo -e "${RED}警告: 没有 sudo 权限，将跳过系统级包的卸载${NC}"
    HAVE_SUDO=false
else
    HAVE_SUDO=true
fi

# 确认卸载
echo -e "${RED}警告: 此操作将删除 Ansible 环境及相关文件${NC}"
read -p "是否继续? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# 询问是否要删除项目文件
read -p "是否删除项目文件（ansible.cfg, inventory 等）? (y/n) " -n 1 -r
echo
DELETE_PROJECT_FILES=$REPLY

# 询问是否要删除系统级包（如果有 sudo 权限）
if [ "$HAVE_SUDO" = true ]; then
    read -p "是否删除系统级包（python3-pip, python3-venv）? (y/n) " -n 1 -r
    echo
    DELETE_SYSTEM_PACKAGES=$REPLY
fi

# 1. 检查并退出虚拟环境
if [ -n "${VIRTUAL_ENV}" ]; then
    echo -e "${YELLOW}退出虚拟环境...${NC}"
    deactivate
fi

# 2. 删除虚拟环境
if [ -d ".venv" ]; then
    echo -e "${YELLOW}删除虚拟环境...${NC}"
    rm -rf .venv
fi

# 3. 删除项目文件（如果用户确认）
if [[ $DELETE_PROJECT_FILES =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}删除项目文件...${NC}"
    
    # 备份重要文件
    echo -e "${YELLOW}创建备份...${NC}"
    BACKUP_DIR="ansible_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # 备份配置文件（如果存在）
    [ -f "ansible.cfg" ] && cp ansible.cfg "$BACKUP_DIR/"
    [ -f "inventory" ] && cp inventory "$BACKUP_DIR/"
    [ -d "roles" ] && cp -r roles "$BACKUP_DIR/"
    [ -d "group_vars" ] && cp -r group_vars "$BACKUP_DIR/"
    [ -d "host_vars" ] && cp -r host_vars "$BACKUP_DIR/"
    
    echo -e "${GREEN}备份已保存到 $BACKUP_DIR 目录${NC}"
    
    # 删除文件
    rm -f ansible.cfg
    rm -f inventory
    rm -rf roles/
    rm -rf group_vars/
    rm -rf host_vars/
fi

# 4. 删除系统级包（如果用户确认且有 sudo 权限）
if [ "$HAVE_SUDO" = true ] && [[ $DELETE_SYSTEM_PACKAGES =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}删除系统级包...${NC}"
    sudo apt remove -y python3-pip python3-venv
    sudo apt autoremove -y
fi

echo -e "${GREEN}卸载完成!${NC}"
if [ -d "$BACKUP_DIR" ]; then
    echo -e "重要文件已备份到: ${YELLOW}$BACKUP_DIR${NC}"
fi 