# Ansible Vault 加密指南

## 1. 基本概念
Ansible Vault 是 Ansible 的内置加密系统，用于保护敏感数据，如：
- 密码
- API 密钥
- 私钥
- 其他敏感配置

## 2. 常用命令

### 2.1 创建加密文件
```bash
# 创建新的加密文件
ansible-vault create secrets.yml

# 交互式输入内容，例如：
mysql_password: secretpass123
api_key: abcd1234
```

### 2.2 加密现有文件
```bash
# 加密整个文件
ansible-vault encrypt vars/secrets.yml

# 加密多个文件
ansible-vault encrypt file1.yml file2.yml
```

### 2.3 查看加密文件
```bash
# 查看加密文件内容
ansible-vault view secrets.yml

# 编辑加密文件
ansible-vault edit secrets.yml
```

### 2.4 修改密码
```bash
# 更改加密文件的密码
ansible-vault rekey secrets.yml
```

### 2.5 解密文件
```bash
# 永久解密文件
ansible-vault decrypt secrets.yml
```

## 3. 在 Playbook 中使用

### 3.1 运行加密的 Playbook
```bash
# 交互式输入密码
ansible-playbook site.yml --ask-vault-pass

# 使用密码文件
ansible-playbook site.yml --vault-password-file ~/.vault_pass.txt
```

### 3.2 在配置文件中使用
```yaml
# group_vars/all/vars.yml
db_password: "{{ vault_db_password }}"

# group_vars/all/vault.yml (加密文件)
vault_db_password: secretpass123
```

## 4. 最佳实践

### 4.1 密码文件
```bash
# 创建密码文件
echo "your-vault-password" > ~/.vault_pass.txt
chmod 600 ~/.vault_pass.txt

# 在 ansible.cfg 中配置
[defaults]
vault_password_file = ~/.vault_pass.txt
```

### 4.2 多密码管理
```bash
# 使用不同 ID 的密码
ansible-vault encrypt --vault-id dev@dev-password.txt dev-secrets.yml
ansible-vault encrypt --vault-id prod@prod-password.txt prod-secrets.yml

# 运行 playbook
ansible-playbook site.yml --vault-id dev@dev-password.txt --vault-id prod@prod-password.txt
```

### 4.3 Git 集成
```bash
# .gitignore 示例
*.vault.yml
*vault.yml
.vault_pass.txt
```

## 5. 安全建议
1. 不要将密码文件提交到版本控制
2. 定期更换 vault 密码
3. 对不同环境使用不同的 vault ID
4. 限制 vault 密码文件的访问权限
5. 在生产环境使用密钥管理服务

## 6. 常见问题
1. 密码错误：
   - 检查密码文件内容
   - 确保没有多余的换行符
   
2. 权限问题：
   - 检查密码文件权限（建议 600）
   - 确保当前用户有权限访问 