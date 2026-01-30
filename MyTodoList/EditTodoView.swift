//
//  EditTodoView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//
//  文件说明：
//  本文件定义了编辑任务的表单视图
//  与 AddTodoView 结构相似，但用于修改已存在的任务
//  支持编辑任务的分区、分类、标题、备注、优先级和截止日期
//

import SwiftUI
import SwiftData

// MARK: - EditTodoView 编辑任务表单
/// 编辑任务的表单视图
/// 以模态表单形式呈现，允许用户修改已存在的待办任务
/// 支持修改分区（生活/学习）、学习分类、优先级和截止日期
struct EditTodoView: View {
    // MARK: 环境属性
    
    /// 关闭当前视图的环境操作
    @Environment(\.dismiss) private var dismiss
    
    // MARK: 绑定属性
    
    /// 要编辑的任务对象
    /// 使用 @Bindable 使其可以双向绑定
    @Bindable var item: Item
    
    // MARK: 查询属性
    
    /// 查询所有学习分类，按创建时间排序
    /// 用于在学习分区时显示可选的分类列表
    @Query(sort: \StudyCategory.createdAt) private var categories: [StudyCategory]

    // MARK: 表单状态属性
    // 使用 @State 存储表单数据，保存时再写回 item
    // 这样可以支持"取消"操作，不会立即修改原数据
    
    /// 任务标题（从 item 初始化）
    @State private var title: String
    
    /// 任务备注（从 item 初始化）
    @State private var notes: String
    
    /// 任务优先级（从 item 初始化）
    @State private var priority: Priority
    
    /// 是否设置截止日期（根据 item.dueDate 是否为 nil 判断）
    @State private var hasDueDate: Bool
    
    /// 截止日期（从 item 初始化，如果为 nil 则使用当前日期）
    @State private var dueDate: Date
    
    /// 选中的分区（从 item 初始化）
    @State private var selectedSection: Section
    
    /// 选中的学习分类（从 item 初始化，可选）
    @State private var selectedCategory: StudyCategory?

    // MARK: 初始化方法
    
    /// 使用任务对象初始化编辑表单
    /// 将任务的各个属性值复制到表单状态中
    /// - Parameter item: 要编辑的任务对象
    init(item: Item) {
        self.item = item
        // 使用 State(initialValue:) 初始化各个状态属性
        _title = State(initialValue: item.title)
        _notes = State(initialValue: item.notes)
        _priority = State(initialValue: item.priority)
        _hasDueDate = State(initialValue: item.dueDate != nil)
        _dueDate = State(initialValue: item.dueDate ?? Date())
        _selectedSection = State(initialValue: item.section)
        _selectedCategory = State(initialValue: item.category)
    }

    // MARK: 计算属性
    
    /// 判断是否可以保存任务
    /// - 必须有标题（去除空白后非空）
    /// - 如果是学习分区，必须选择分类
    private var canSave: Bool {
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
            .navigationTitle("编辑任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 取消按钮
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                // 保存按钮
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTask()
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
                    .disabled(!canSave)
                }
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
    /// 复用 AddTodoView 中定义的 PriorityButton 组件
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
    /// 注意：编辑时允许选择过去的日期（与新建不同）
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
                        // 注意：编辑时不限制日期范围，允许查看和保留过去的截止日期
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
    
    /// 保存任务修改
    /// 将表单状态数据写回到原始 item 对象
    /// SwiftData 会自动处理持久化
    private func saveTask() {
        item.title = title.trimmingCharacters(in: .whitespaces)
        item.notes = notes.trimmingCharacters(in: .whitespaces)
        item.priority = priority
        item.dueDate = hasDueDate ? dueDate : nil
        item.section = selectedSection
        item.category = selectedCategory
        dismiss()
    }
}

// MARK: - 预览
#Preview {
    EditTodoView(item: Item(title: "测试任务", notes: "这是备注", priority: .high))
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
