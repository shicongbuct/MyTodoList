# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此仓库中工作时提供指导。

## 构建与运行

这是一个 iOS 应用，必须通过 Xcode 构建和运行：

```bash
# 在 Xcode 中打开
open MyTodoList.xcodeproj
```

在 Xcode 中构建运行（Cmd+R），选择模拟器或已连接的 iOS 设备。`xcodebuild` 命令行可用于构建，但设备部署需要 Xcode。

**运行测试：**
```bash
xcodebuild test -scheme MyTodoList -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 架构

**SwiftUI + SwiftData 应用**，数据仅存储在本地（无后端）。

### 核心文件

- `MyTodoListApp.swift` - 应用入口，配置 SwiftData ModelContainer
- `Item.swift` - 数据模型：`Item` 类与 `Priority` 枚举（低/中/高）
- `ContentView.swift` - 主视图，包含任务列表、搜索、待办/已完成分区
- `AddTodoView.swift` - 新建任务的弹出表单

### 数据流

SwiftData 自动处理持久化。`Item` 模型使用 `@Model` 宏，存储字段：
- `title`、`notes`、`isCompleted`、`createdAt`、`dueDate`、`priorityRaw`

视图通过 `@Query` 访问数据，通过 `@Environment(\.modelContext)` 修改数据。

### UI 组件

`ContentView.swift` 包含三个视图结构体：
- `ContentView` - 主列表，分待办和已完成两个区域
- `TodoCardView` - 待办任务卡片，支持左滑删除手势
- `CompletedCardView` - 已完成任务卡片，带可见的删除按钮

## 语言

所有界面文字使用简体中文。
