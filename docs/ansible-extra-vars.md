# Ansible Extra Variables 使用指南

## 1. 基本用法

### 1.1 命令行传递单个变量
```bash
ansible-playbook playbook.yml --extra-vars "variable_name=value"
```

### 1.2 使用 JSON 格式
```bash
ansible-playbook playbook.yml --extra-vars '{"variable_name": "value"}'
```

### 1.3 从文件加载变量（推荐）
```bash
# 从 YAML 文件加载
ansible-playbook playbook.yml --extra-vars "@vars.yml"

# 从 JSON 文件加载
ansible-playbook playbook.yml --extra-vars "@vars.json"
```

## 2. 密码文件示例

### 2.1 创建密码文件 (password.yml)
```yaml
---
ansible_become_password: your_sudo_password
mysql_root_password: your_mysql_root_password
```

### 2.2 使用密码文件
```bash
# 运行 playbook 时加载密码文件
ansible-playbook playbook.yml --extra-vars "@password.yml"

# 同时使用多个变量文件
ansible-playbook playbook.yml --extra-vars "@password.yml" --extra-vars "@other_vars.yml"
```

### 2.3 组合使用
```bash
# 同时使用文件和命令行变量
ansible-playbook playbook.yml --extra-vars "@password.yml" --extra-vars "variable=value"
```

## 3. 安全建议

1. 密码文件保护：
   ```bash
   # 设置严格的文件权限
   chmod 600 password.yml
   ```

2. 在 .gitignore 中排除密码文件：
   ```
   # .gitignore
   password.yml
   *_password.yml
   ```

3. 考虑使用 ansible-vault 加密密码文件：
   ```bash
   # 加密密码文件
   ansible-vault encrypt password.yml
   
   # 使用加密的密码文件
   ansible-playbook playbook.yml --extra-vars "@password.yml" --ask-vault-pass
   ```

## 4. 最佳实践

1. 文件命名建议：
   - password.yml - 用于密码
   - vars.yml - 用于普通变量
   - env_vars.yml - 用于环境变量

2. 变量优先级：
   - --extra-vars 具有最高优先级
   - 可以覆盖 playbook 中定义的变量
   - 可以覆盖 inventory 中的变量

3. 使用场景：
   - 临时覆盖配置
   - 传递敏感信息
   - 环境特定的变量

## 5. 常见问题

1. 文件不存在：
   ```bash
   # 确保使用正确的路径
   ansible-playbook playbook.yml --extra-vars "@./password.yml"
   ```

2. 格式错误：
   ```yaml
   # 正确的 YAML 格式
   ---
   variable_name: value
   ```

3. 权限问题：
   ```bash
   # 确保当前用户有权限读取文件
   sudo chown $USER password.yml
   chmod 600 password.yml
   ``` 