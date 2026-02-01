# MyTodoList

一款现代化的 iOS 待办事项应用，采用深色 UI 设计。

**版本：1.03**

## 功能特性

### 四大模块

- **生活** - 日常任务管理，支持搜索
- **学习** - 学习任务管理，支持自定义分类
- **健身** - 运动计划管理，周/月计划
- **Cook** - 食材管理，饮食计划

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

### 健身模块
- 今日运动计划（可完成打卡）
- 运动预设管理（可添加/删除）
- 本周计划、本月计划编辑

### Cook 模块
- 食材分类管理（肉类、蔬菜、主食、水果、零食等）
- 各分类下食材管理
- 三日饮食计划（今日/明日/后天）
- 每日三餐计划编辑

### 隐藏事项
- 通过健身页面下拉触发
- 密码保护的私密待办事项

### 界面设计
- 深色渐变主题
- 卡片式任务展示
- 底部 TabBar，各模块独立添加按钮
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
├── MyTodoListApp.swift          # 应用入口
├── MainTabView.swift            # 主框架（TabBar）
│
├── 生活模块
│   ├── ContentView.swift        # 生活任务列表
│   ├── AddTodoView.swift        # 新建任务
│   └── EditTodoView.swift       # 编辑任务
│
├── 学习模块
│   ├── StudyView.swift          # 学习分类网格
│   ├── CategoryDetailView.swift # 分类详情页
│   └── AddCategoryView.swift    # 新建/编辑分类
│
├── 健身模块
│   ├── FitnessView.swift        # 健身主页
│   ├── FitnessModels.swift      # 健身数据模型
│   ├── AddExerciseView.swift    # 添加今日运动
│   └── AddExercisePresetView.swift # 添加运动预设
│
├── Cook 模块
│   ├── CookView.swift           # 食材管理 + 饮食计划
│   ├── CookModels.swift         # 食材数据模型
│   ├── IngredientCategoryDetailView.swift
│   ├── AddIngredientCategoryView.swift
│   └── AddIngredientView.swift
│
├── 隐藏事项
│   ├── HiddenTodoView.swift     # 隐藏事项列表
│   ├── AddHiddenTodoView.swift  # 添加隐藏事项
│   └── PasswordView.swift       # 密码输入
│
├── 数据模型
│   ├── Item.swift               # 任务模型
│   └── StudyCategory.swift      # 学习分类模型
│
└── Assets.xcassets/             # 图标和颜色资源
```

## 技术栈

- **SwiftUI** - 声明式 UI 框架
- **SwiftData** - 本地数据持久化
- **Swift 5.9** - 编程语言

## 更新日志

### v1.03 (2026-02-01)
- 清理学习模块待办卡片中无效的手势代码

### v1.02 (2026-02-01)
- 移除 TabBar 中间的统一添加按钮
- 生活页面右上角添加独立添加按钮
- 学习分类详情页右上角添加独立添加按钮
- 健身页面右下角添加悬浮添加按钮
- 修复数据保存延迟问题

### v1.01 (2026-01-31)
- 新增健身模块：今日运动计划、周/月计划
- 新增 Cook 模块：食材分类管理、三日饮食计划
- 新增隐藏事项功能（密码保护）
- 优化 TabBar 样式

### v1.0 (2026-01-30)
- 初始版本
- 生活/学习双分区
- 学习分类功能

## 许可证

MIT License
