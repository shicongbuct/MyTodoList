# MyTodoList

一款现代化的 iOS 待办事项应用，采用深色 UI 设计。

## 功能特性

### 双分区设计
- **生活** - 日常任务管理，支持搜索
- **学习** - 学习任务管理，支持自定义分类

### 任务管理
- 创建、编辑、完成、删除任务
- 三级优先级（低 / 中 / 高）
- 可选截止日期，逾期提醒
- 左滑删除待办任务
- 一键清空已完成任务

### 学习分类
- 自定义分类（名称、图标、颜色）
- 预设分类：AI 学习、产品学习、Python/大模型、文学阅读
- 分类内任务独立管理
- 删除分类时级联删除关联任务

### 界面设计
- 深紫色渐变主题
- 卡片式任务展示
- 底部 TabBar + 悬浮添加按钮
- 流畅的过渡动画

## 系统要求

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 安装运行

1. 克隆仓库
2. 用 Xcode 打开 `MyTodoList.xcodeproj`
3. 选择目标设备或模拟器
4. 构建运行（Cmd+R）

## 项目结构

```
MyTodoList/
├── MyTodoListApp.swift      # 应用入口，初始化 SwiftData
├── Item.swift               # 任务数据模型
├── StudyCategory.swift      # 学习分类数据模型
├── MainTabView.swift        # 主框架（TabBar + FAB）
├── ContentView.swift        # 生活任务列表
├── StudyView.swift          # 学习分类网格
├── CategoryDetailView.swift # 分类详情页
├── AddTodoView.swift        # 新建任务
├── EditTodoView.swift       # 编辑任务
├── AddCategoryView.swift    # 新建/编辑分类
└── Assets.xcassets/         # 图标和颜色资源
```

## 技术栈

- **SwiftUI** - 声明式 UI 框架
- **SwiftData** - 本地数据持久化
- **Swift 5.9** - 编程语言

## 许可证

MIT License
