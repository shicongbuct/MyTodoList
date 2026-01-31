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

应用分为四个主要模块：**生活**、**学习**、**健身**、**Cook**，通过底部 TabBar 切换。

### 数据模型

#### Item.swift - 任务模型
- `Item` 类（@Model）- 任务模型
  - `title`、`notes`、`isCompleted`、`createdAt`、`dueDate`
  - `priorityRaw` / `priority` - 优先级（低/中/高）
  - `sectionRaw` / `section` - 分区（生活=0 / 学习=1 / 隐藏=2）
  - `category` - 关联的学习分类（可选）
- `Priority` 枚举 - 低/中/高
- `Section` 枚举 - 生活/学习/隐藏

#### StudyCategory.swift - 学习分类
- `StudyCategory` 类（@Model）
  - `name`、`icon`（emoji）、`colorHex`、`createdAt`
  - `items` - 关联的任务列表（级联删除）

#### FitnessModels.swift - 健身模型
- `ExercisePreset` - 运动预设选项
- `TodayExercise` - 今日运动计划条目
- `FitnessPlan` - 周/月计划

#### CookModels.swift - 食材模型
- `IngredientCategory` - 食材分类（肉类、蔬菜、主食等）
- `Ingredient` - 食材项
- `MealPlan` - 饮食计划（今日/明日/后天的三餐）
- `MealType` 枚举 - 早餐/中餐/晚餐

### 视图结构

| 文件 | 说明 |
|------|------|
| `MyTodoListApp.swift` | 应用入口，配置 ModelContainer，初始化预设数据 |
| `MainTabView.swift` | 主框架：TabBar（生活/学习/健身/Cook）+ FAB 按钮 |

**生活模块：**
| 文件 | 说明 |
|------|------|
| `ContentView.swift` | 生活任务列表 |
| `AddTodoView.swift` | 新建任务表单 |
| `EditTodoView.swift` | 编辑任务表单 |

**学习模块：**
| 文件 | 说明 |
|------|------|
| `StudyView.swift` | 学习分类网格 |
| `CategoryDetailView.swift` | 分类详情页 |
| `AddCategoryView.swift` | 新建/编辑学习分类 |

**健身模块：**
| 文件 | 说明 |
|------|------|
| `FitnessView.swift` | 健身主页（今日计划、周/月计划） |
| `AddExerciseView.swift` | 添加今日运动 |
| `AddExercisePresetView.swift` | 添加运动预设 |

**Cook 模块：**
| 文件 | 说明 |
|------|------|
| `CookView.swift` | 食材管理主页 + 饮食计划 |
| `IngredientCategoryDetailView.swift` | 食材分类详情 |
| `AddIngredientCategoryView.swift` | 添加食材分类 |
| `AddIngredientView.swift` | 添加食材 |

**隐藏事项模块（通过健身页下拉触发）：**
| 文件 | 说明 |
|------|------|
| `HiddenTodoView.swift` | 隐藏事项列表 |
| `AddHiddenTodoView.swift` | 添加/编辑隐藏事项 |
| `PasswordView.swift` | 密码输入页面 |

### 数据流

- SwiftData 自动处理持久化
- 视图通过 `@Query` 访问数据，通过 `@Environment(\.modelContext)` 修改
- `NavigationState`（@Observable）跟踪当前选中的学习分类

### UI 交互

- 任务卡片支持左滑显示删除按钮
- 已完成任务区域有"清空全部"功能
- 学习分类卡片通过 Menu 提供编辑/删除选项
- 健身页面下拉可进入隐藏事项（密码 1109）

## 语言

所有界面文字使用简体中文。
