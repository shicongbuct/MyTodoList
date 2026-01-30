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

应用分为两个主要分区：**生活**和**学习**，通过底部 TabBar 切换。学习分区支持自定义分类管理。

### 数据模型

`Item.swift` 定义核心数据结构：
- `Item` 类（@Model）- 任务模型
  - `title`、`notes`、`isCompleted`、`createdAt`、`dueDate`
  - `priorityRaw` / `priority` - 优先级（低/中/高）
  - `sectionRaw` / `section` - 分区（生活=0 / 学习=1）
  - `category` - 关联的学习分类（可选）
- `Priority` 枚举 - 低/中/高
- `Section` 枚举 - 生活/学习

`StudyCategory.swift` 定义学习分类：
- `StudyCategory` 类（@Model）- 分类模型
  - `name`、`icon`（emoji）、`colorHex`、`createdAt`
  - `items` - 关联的任务列表（级联删除）

### 视图结构

| 文件 | 说明 |
|------|------|
| `MyTodoListApp.swift` | 应用入口，配置 ModelContainer，初始化预设分类 |
| `MainTabView.swift` | 主框架：TabBar（生活/学习）+ FAB 按钮 + NavigationState |
| `ContentView.swift` | 生活任务列表，含 `TodoCardView`、`CompletedCardView` |
| `StudyView.swift` | 学习分类网格，含 `CategoryCardView` |
| `CategoryDetailView.swift` | 分类详情页，含 `StudyTodoCardView`、`StudyCompletedCardView` |
| `AddTodoView.swift` | 新建任务表单（支持选择分区和分类） |
| `EditTodoView.swift` | 编辑任务表单 |
| `AddCategoryView.swift` | 新建/编辑学习分类表单 |

### 数据流

- SwiftData 自动处理持久化
- 视图通过 `@Query` 访问数据，通过 `@Environment(\.modelContext)` 修改
- `NavigationState`（@Observable）跟踪当前选中的学习分类，用于 FAB 按钮判断上下文

### UI 交互

- 任务卡片支持左滑显示删除按钮
- 已完成任务区域有"清空全部"功能
- 学习分类卡片通过 Menu 提供编辑/删除选项

## 语言

所有界面文字使用简体中文。
