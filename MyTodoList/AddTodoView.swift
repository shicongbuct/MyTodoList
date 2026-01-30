//
//  AddTodoView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//
//  文件说明：
//  本文件定义了新建任务的表单视图，包括：
//  - AddTodoView：新建任务表单主视图
//  - PriorityButton：优先级选择按钮组件
//  支持设置任务的分区、分类、标题、备注、优先级和截止日期
//

import SwiftUI
import SwiftData

// MARK: - AddTodoView 新建任务表单
/// 新建任务的表单视图
/// 以模态表单形式呈现，允许用户创建新的待办任务
/// 支持选择分区（生活/学习）、学习分类、设置优先级和截止日期
struct AddTodoView: View {
    // MARK: 环境和查询属性
    
    /// SwiftData 模型上下文，用于插入新任务
    @Environment(\.modelContext) private var modelContext
    
    /// 关闭当前视图的环境操作
    @Environment(\.dismiss) private var dismiss
    
    /// 查询所有学习分类，按创建时间排序
    /// 用于在学习分区时显示可选的分类列表
    @Query(sort: \StudyCategory.createdAt) private var categories: [StudyCategory]

    // MARK: 初始化属性
    
    /// 初始分区设置（从调用处传入）
    /// 用于预设任务的分区（生活或学习）
    var initialSection: Section = .life
    
    /// 初始分类设置（从调用处传入，可选）
    /// 仅在学习分区有效，用于预选分类
    var initialCategory: StudyCategory?

    // MARK: 表单状态属性
    
    /// 任务标题
    @State private var title = ""
    
    /// 任务备注
    @State private var notes = ""
    
    /// 任务优先级，默认为中
    @State private var priority: Priority = .medium
    
    /// 是否设置截止日期
    @State private var hasDueDate = false
    
    /// 截止日期，默认为当前日期
    @State private var dueDate = Date()
    
    /// 选中的分区
    @State private var selectedSection: Section = .life
    
    /// 选中的学习分类（仅在学习分区有效）
    @State private var selectedCategory: StudyCategory?

    // MARK: 焦点状态
    
    /// 标题输入框的焦点状态
    /// 用于在表单出现时自动聚焦到标题输入框
    @FocusState private var titleFocused: Bool

    // MARK: 计算属性
    
    /// 判断是否可以添加任务
    /// - 必须有标题（去除空白后非空）
    /// - 如果是学习分区，必须选择分类
    private var canAdd: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespaces).isEmpty
        if selectedSection == .study {
            return hasTitle && selectedCategory != nil
        }
        return hasTitle
    }

    // MARK: 视图主体
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变色（深紫色调）
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.12),
                        Color(red: 0.10, green: 0.08, blue: 0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // 表单内容
                ScrollView {
                    VStack(spacing: 24) {
                        // 分区选择（生活/学习）
                        sectionPickerSection
                        
                        // 学习分类选择（仅在学习分区显示）
                        if selectedSection == .study {
                            categorySection
                        }
                        
                        // 任务标题输入
                        titleSection
                        
                        // 任务备注输入
                        notesSection
                        
                        // 优先级选择
                        prioritySection
                        
                        // 截止日期设置
                        dueDateSection

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            // 导航栏配置
            .navigationTitle("新建任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 取消按钮
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                // 添加按钮
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addTask()
                    }
                    .fontWeight(.semibold)
                    // 渐变色文字
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    // 不满足条件时禁用
                    .disabled(!canAdd)
                }
            }
            // 视图出现时初始化
            .onAppear {
                // 设置初始分区和分类
                selectedSection = initialSection
                selectedCategory = initialCategory
                // 自动聚焦到标题输入框
                titleFocused = true
            }
        }
        // 强制使用深色模式
        .preferredColorScheme(.dark)
    }

    // MARK: 分区选择区域
    
    /// 分区选择器
    /// 包含"生活"和"学习"两个选项按钮
    private var sectionPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("分区")

            HStack(spacing: 12) {
                // 生活分区按钮
                sectionButton(section: .life, icon: "house.fill", label: "生活")
                // 学习分区按钮
                sectionButton(section: .study, icon: "book.fill", label: "学习")
            }
        }
    }

    /// 创建分区选择按钮
    /// - Parameters:
    ///   - section: 分区类型
    ///   - icon: SF Symbols 图标名称
    ///   - label: 按钮文字标签
    /// - Returns: 配置好的分区按钮视图
    private func sectionButton(section: Section, icon: String, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedSection = section
                // 切换到生活分区时清除已选分类
                if section == .life {
                    selectedCategory = nil
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 15, weight: .medium))
            }
            // 选中状态使用白色文字，未选中使用灰色
            .foregroundColor(selectedSection == section ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    // 选中状态使用紫色背景
                    .fill(selectedSection == section ? Color.purple.opacity(0.3) : Color(white: 0.15).opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            // 选中状态使用紫色边框
                            .stroke(selectedSection == section ? Color.purple.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: 学习分类选择区域
    
    /// 学习分类选择器
    /// 以水平滚动的标签形式显示所有分类
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionLabel("学习分类")
                // 未选择分类时显示必选提示
                if selectedCategory == nil {
                    Text("(必选)")
                        .font(.system(size: 11))
                        .foregroundColor(.red.opacity(0.8))
                }
            }

            // 如果没有分类，显示提示信息
            if categories.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("暂无分类，请先创建学习分类")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(inputBackground)
            } else {
                // 水平滚动显示分类标签
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories) { category in
                            categoryChip(category)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }

    /// 创建分类选择标签
    /// - Parameter category: 学习分类对象
    /// - Returns: 配置好的分类标签视图
    private func categoryChip(_ category: StudyCategory) -> some View {
        // 判断是否为当前选中的分类
        let isSelected = selectedCategory?.persistentModelID == category.persistentModelID
        // 获取分类主题色
        let color = Color(hex: category.colorHex) ?? .blue

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                // 分类图标
                Text(category.icon)
                    .font(.system(size: 16))
                // 分类名称
                Text(category.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    // 选中时使用分类主题色背景
                    .fill(isSelected ? color.opacity(0.3) : Color(white: 0.15).opacity(0.9))
                    .overlay(
                        Capsule()
                            // 选中时使用分类主题色边框
                            .stroke(isSelected ? color.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: 标题输入区域
    
    /// 任务标题输入区域
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("标题")

            TextField("需要做什么？", text: $title)
                .font(.system(size: 17))
                .padding(16)
                .background(inputBackground)
                .focused($titleFocused)  // 绑定焦点状态
        }
    }

    // MARK: 备注输入区域
    
    /// 任务备注输入区域
    /// 支持多行输入（3-6行）
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("备注")

            TextField("添加详情...", text: $notes, axis: .vertical)
                .font(.system(size: 16))
                .lineLimit(3...6)  // 最少3行，最多6行
                .padding(16)
                .background(inputBackground)
        }
    }

    // MARK: 优先级选择区域
    
    /// 任务优先级选择区域
    /// 以三个按钮形式显示低、中、高三个优先级选项
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("优先级")

            HStack(spacing: 12) {
                // 遍历所有优先级选项
                ForEach(Priority.allCases, id: \.self) { p in
                    PriorityButton(
                        priority: p,
                        isSelected: priority == p
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            priority = p
                        }
                    }
                }
            }
        }
    }

    // MARK: 截止日期设置区域
    
    /// 截止日期设置区域
    /// 包含开关和日期选择器
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("截止日期")

            VStack(spacing: 16) {
                // 开关：是否设置截止日期
                Toggle(isOn: $hasDueDate.animation(.spring(response: 0.3))) {
                    HStack(spacing: 12) {
                        // 日历图标背景
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: hasDueDate
                                            ? [.purple.opacity(0.3), .blue.opacity(0.3)]  // 开启时紫蓝渐变
                                            : [.white.opacity(0.1), .white.opacity(0.05)], // 关闭时灰色
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)

                            Image(systemName: "calendar")
                                .font(.system(size: 16))
                                .foregroundColor(hasDueDate ? .purple : .secondary)
                        }

                        Text("设置截止日期")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
                .tint(.purple)  // 开关使用紫色
                .padding(16)
                .background(inputBackground)

                // 日期选择器（仅在开启时显示）
                if hasDueDate {
                    DatePicker(
                        "截止日期",
                        selection: $dueDate,
                        in: Date()...,  // 只能选择今天及以后的日期
                        displayedComponents: [.date]  // 只显示日期，不显示时间
                    )
                    .datePickerStyle(.graphical)  // 使用图形化日历样式
                    .tint(.purple)
                    .padding(16)
                    .background(inputBackground)
                    // 进入/退出动画
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
                }
            }
        }
    }

    // MARK: 辅助视图组件
    
    /// 创建区域标签文字
    /// - Parameter text: 标签文字
    /// - Returns: 格式化的标签视图
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)  // 大写字母
            .tracking(0.5)  // 字间距
    }

    /// 输入框通用背景样式
    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color(white: 0.15).opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    // MARK: 操作方法
    
    /// 添加新任务
    /// 创建 Item 对象并插入到数据上下文，然后关闭表单
    private func addTask() {
        let newItem = Item(
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces),
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority,
            section: selectedSection,
            category: selectedCategory
        )
        modelContext.insert(newItem)
        dismiss()
    }
}

// MARK: - PriorityButton 优先级选择按钮
/// 优先级选择按钮组件
/// 显示优先级图标和标签，支持选中状态样式
struct PriorityButton: View {
    // MARK: 属性
    
    /// 按钮代表的优先级
    let priority: Priority
    
    /// 是否为当前选中状态
    let isSelected: Bool
    
    /// 点击回调
    let action: () -> Void

    // MARK: 计算属性
    
    /// 根据优先级返回对应的颜色
    private var color: Color {
        switch priority {
        case .high: return .red      // 高优先级 - 红色
        case .medium: return .orange // 中优先级 - 橙色
        case .low: return .blue      // 低优先级 - 蓝色
        }
    }

    /// 根据优先级返回对应的图标
    private var icon: String {
        switch priority {
        case .high: return "exclamationmark.2"   // 双感叹号
        case .medium: return "exclamationmark"   // 单感叹号
        case .low: return "minus"                // 横线
        }
    }

    // MARK: 视图主体
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // 图标区域
                ZStack {
                    // 圆形背景
                    Circle()
                        .fill(
                            isSelected
                                ? color.opacity(0.2)      // 选中时使用优先级颜色
                                : Color.white.opacity(0.05) // 未选中时使用淡灰色
                        )
                        .frame(width: 44, height: 44)

                    // 选中时显示边框
                    if isSelected {
                        Circle()
                            .stroke(color, lineWidth: 2)
                            .frame(width: 44, height: 44)
                    }

                    // 优先级图标
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? color : .secondary)
                }

                // 优先级标签
                Text(priority.label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(white: 0.15).opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                // 选中时使用优先级颜色边框
                                isSelected ? color.opacity(0.5) : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 预览
#Preview {
    AddTodoView()
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}

#Preview("Study Section") {
    AddTodoView(initialSection: .study)
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
