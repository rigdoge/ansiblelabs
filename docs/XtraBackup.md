# Percona XtraBackup 使用指南

## 简介

Percona XtraBackup 是一个开源的 MySQL 热备份工具，可以在不中断数据库服务的情况下进行备份。本文档介绍了在我们的环境中如何使用 XtraBackup。

## 自动备份配置

系统已经配置了自动备份功能：

1. **全量备份**
   - 执行时间：每天凌晨 1:00
   - 保留时间：7天
   - 备份位置：`/var/backup/mysql/full/backup_YYYYMMDD_HHMMSS`

2. **增量备份**
   - 执行时间：每6小时执行一次（0:00, 6:00, 12:00, 18:00）
   - 保留时间：2天
   - 备份位置：`/var/backup/mysql/incremental/backup_YYYYMMDD_HHMMSS`

## 手动执行备份

1. **执行全量备份**
   ```bash
   sudo /usr/local/bin/mysql-backup-full
   ```

2. **执行增量备份**
   ```bash
   sudo /usr/local/bin/mysql-backup-incremental
   ```

## 备份恢复流程

### 1. 全量备份恢复

1. 停止 MySQL 服务：
   ```bash
   sudo systemctl stop mysql
   ```

2. 清空数据目录：
   ```bash
   sudo rm -rf /var/lib/mysql/*
   ```

3. 复制备份到数据目录：
   ```bash
   sudo xtrabackup --copy-back --target-dir=/var/backup/mysql/full/backup_YYYYMMDD_HHMMSS
   ```

4. 修复权限：
   ```bash
   sudo chown -R mysql:mysql /var/lib/mysql
   ```

5. 启动 MySQL 服务：
   ```bash
   sudo systemctl start mysql
   ```

### 2. 增量备份恢复

1. 准备全量备份：
   ```bash
   sudo xtrabackup --prepare --apply-log-only --target-dir=/var/backup/mysql/full/backup_YYYYMMDD_HHMMSS
   ```

2. 应用增量备份（按时间顺序应用每个增量备份）：
   ```bash
   sudo xtrabackup --prepare --apply-log-only --target-dir=/var/backup/mysql/full/backup_YYYYMMDD_HHMMSS \
     --incremental-dir=/var/backup/mysql/incremental/backup_YYYYMMDD_HHMMSS
   ```

3. 最后一个增量备份不需要 --apply-log-only：
   ```bash
   sudo xtrabackup --prepare --target-dir=/var/backup/mysql/full/backup_YYYYMMDD_HHMMSS \
     --incremental-dir=/var/backup/mysql/incremental/最后一个增量备份目录
   ```

4. 按照全量备份恢复的步骤 1-5 进行恢复。

## 注意事项

1. 备份文件存储
   - 全量备份位于 `/var/backup/mysql/full/`
   - 增量备份位于 `/var/backup/mysql/incremental/`
   - 建议定期将备份文件复制到其他存储设备

2. 权限管理
   - 备份目录权限为 750
   - 所有者为 mysql:mysql
   - 备份脚本需要 root 权限执行

3. 监控
   - 备份日志记录在系统日志中
   - 可以通过 cron 的邮件功能接收备份状态通知

## 常见问题

1. **备份失败**
   - 检查磁盘空间
   - 检查 MySQL 服务状态
   - 检查备份目录权限

2. **恢复失败**
   - 确保按照正确的顺序应用增量备份
   - 检查数据目录权限
   - 检查 MySQL 服务是否完全停止

3. **空间管理**
   - 定期检查备份目录空间使用情况
   - 可以调整备份保留时间
   - 考虑使用压缩选项减小备份大小

## 最佳实践

1. 定期测试备份恢复流程
2. 监控备份任务的执行状态
3. 将备份文件异地存储
4. 记录所有手动备份和恢复操作
5. 在恢复之前先备份当前数据 