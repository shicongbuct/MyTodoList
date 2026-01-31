---
name: 提交新版本代码
description: 发布新版本：更新文档、提交代码、推送远端
argument-hint: [版本号，如 1.02]
allowed-tools: Bash, Write, Read, Edit, Glob, Grep
---

# 版本发布流程

发布版本 $ARGUMENTS，按顺序执行以下步骤：

## 1. 更新项目文档

### 更新 CLAUDE.md
- 确保文档反映当前项目结构和功能
- 添加新增的视图、模型说明

### 更新 README.md
- 更新版本号为 $ARGUMENTS
- 添加本次更新的功能说明

### 更新 .claudeignore（如需要）
- 确保忽略不需要的文件

## 2. 提交代码

```bash
# 查看当前修改
git status
git diff --stat

# 查看最近提交记录了解提交风格
git log --oneline -5

# 暂存所有修改
git add .

# 创建提交
git commit -m "v$ARGUMENTS: 版本发布"

# 推送到远端当前分支
git push origin $(git rev-parse --abbrev-ref HEAD)
```

## 3. 更新 Xcode 版本号

更新 `MyTodoList.xcodeproj/project.pbxproj` 中的 `MARKETING_VERSION` 为 $ARGUMENTS

## 验证
- 确认 git log 显示新提交
- 确认远端分支已同步
