//
//  CategoryDetailView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//
//  文件说明：
//  本文件定义了学习分类的详情页视图，包括：
//  - CategoryDetailView：分类详情主视图，显示该分类下的所有任务
//  - StudyTodoCardView：学习任务卡片组件（待办状态）
//  - StudyCompletedCardView：学习任务卡片组件（已完成状态）
//  展示特定学习分类下的任务列表，支持任务的完成状态切换和删除
//

import SwiftUI
import SwiftData

// MARK: - CategoryDetailView 分类详情主视图
/// 学习分类的详情页视图
/// 显示该分类下的所有待办任务和已完成任务
/// 通过导航栏显示分类图标和名称
struct CategoryDetailView: View {
    // MARK: 环境属性
    
    /// SwiftData 模型上下文，用于数据的增删改操作
    @Environment(\.modelContext) private var modelContext
    
    /// 关闭当前视图的环境操作
    @Environment(\.dismiss) private var dismiss
    
    // MARK: 属性
    
    /// 当前显示的学习分类
    let category: StudyCategory
    
    /// 导航状态对象（可选），用于追踪当前选中的分类
    /// 当进入此页面时设置，离开时清除
    var navigationState: NavigationState?

    // MARK: 查询和状态属性
    
    /// 查询所有任务（后续通过计算属性过滤当前分类的任务）
    @Query private var allItems: [Item]
    
    /// 控制清空已完成任务确认弹窗的显示
    @State private var showingClearAlert = false
    
    /// 当前正在编辑的任务（用于打开编辑表单）
    @State private var editingItem: Item?

    // MARK: 计算属性
    
    /// 当前分类下的所有任务
    /// 通过比较 category 的 persistentModelID 来筛选
    /// 按创建时间倒序排列（最新的在前）
    private var categoryItems: [Item] {
        allItems.filter { $0.category?.persistentModelID == category.persistentModelID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// 当前分类下的待办任务（未完成）
    private var pendingItems: [Item] {
        categoryItems.filter { !$0.isCompleted }
    }

    /// 当前分类下的已完成任务
    private var completedItems: [Item] {
        categoryItems.filter { $0.isCompleted }
    }

    /// 分类的主题颜色（从十六进制转换）
    private var categoryColor: Color {
        Color(hex: category.colorHex) ?? .blue
    }

    // MARK: 视图主体
    
    var body: some View {
        ZStack {
            // 背景渐变色
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.15, blue: 0.12),  // 深绿色调
                    Color(red: 0.10, green: 0.18, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 根据任务数量显示不同内容
                if categoryItems.isEmpty {
                    // 无任务时显示空状态视图
                    emptyStateView
                } else {
                    // 有任务时显示任务列表
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // 待办任务区域
                            if !pendingItems.isEmpty {
                                sectionHeader("待办", count: pendingItems.count)
                                ForEach(pendingItems) { item in
                                    StudyTodoCardView(item: item, categoryColor: categoryColor) {
                                        // 切换完成状态
                                        toggleComplete(item)
                                    } onDelete: {
                                        // 删除任务
                                        deleteItem(item)
                                    } onTap: {
                                        // 打开编辑表单
                                        editingItem = item
                                    }
                                    .id("\(item.persistentModelID)-pending")
                                }
                            }

                            // 已完成任务区域
                            if !completedItems.isEmpty {
                                completedSectionHeader
                                    .padding(.top, pendingItems.isEmpty ? 0 : 20)
                                ForEach(completedItems) { item in
                                    StudyCompletedCardView(item: item, categoryColor: categoryColor) {
                                        // 切换完成状态（恢复为未完成）
                                        toggleComplete(item)
                                    } onDelete: {
                                        // 删除任务
                                        deleteItem(item)
                                    }
                                    .id("\(item.persistentModelID)-completed")
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)  // 为底部 TabBar 留出空间
                    }
                }
            }
        }
        // 隐藏默认导航标题
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        // 自定义导航栏标题（显示分类图标和名称）
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Text(category.icon)
                        .font(.system(size: 20))
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        // 编辑任务的模态表单
        .sheet(item: $editingItem) { item in
            EditTodoView(item: item)
        }
        // 页面出现时设置导航状态
        .onAppear {
            navigationState?.selectedStudyCategory = category
        }
        // 页面消失时清除导航状态
        .onDisappear {
            navigationState?.selectedStudyCategory = nil
        }
        // 清空已完成任务的确认弹窗
        .alert("清空已完成", isPresented: $showingClearAlert) {
            Button("取消", role: .cancel) { }
            Button("清空", role: .destructive) {
                deleteAllCompleted()
            }
        } message: {
            Text("确定要删除所有已完成的任务吗？此操作无法撤销。")
        }
        // 强制使用深色模式
        .preferredColorScheme(.dark)
    }

    // MARK: 空状态视图
    
    /// 当分类下没有任务时显示的占位视图
    /// 显示分类图标和提示文字
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            // 带模糊背景的分类图标
            ZStack {
                // 使用分类主题色的模糊背景
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                categoryColor.opacity(0.3),
                                categoryColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 15)

                // 分类图标
                Text(category.icon)
                    .font(.system(size: 48))
            }

            // 提示文字
            VStack(spacing: 8) {
                Text("暂无任务")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                // 提示用户如何添加任务
                Text("点击下方 + 按钮添加\(category.name)任务")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: 区域标题组件
    
    /// 创建区域标题视图
    /// - Parameters:
    ///   - title: 区域名称（如"待办"）
    ///   - count: 该区域的任务数量
    /// - Returns: 配置好的区域标题视图
    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            // 区域名称
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))

            // 任务数量徽章
            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.1))
                )

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: 已完成区域标题
    
    /// 已完成任务区域的标题
    /// 包含"清空全部"按钮
    private var completedSectionHeader: some View {
        HStack {
            // 区域名称
            Text("已完成")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))

            // 任务数量徽章
            Text("\(completedItems.count)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.1))
                )

            Spacer()

            // 清空全部按钮
            Button {
                showingClearAlert = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                    Text("清空全部")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.red.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.15))
                )
            }
        }
        .padding(.top, 8)
    }

    // MARK: 操作方法
    
    /// 切换任务的完成状态
    /// - Parameter item: 要切换状态的任务
    private func toggleComplete(_ item: Item) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            item.isCompleted.toggle()
        }
    }

    /// 删除单个任务
    /// - Parameter item: 要删除的任务
    private func deleteItem(_ item: Item) {
        withAnimation(.easeOut(duration: 0.3)) {
            modelContext.delete(item)
        }
    }

    /// 删除所有已完成的任务
    private func deleteAllCompleted() {
        withAnimation(.easeOut(duration: 0.3)) {
            for item in completedItems {
                modelContext.delete(item)
            }
        }
    }
}

// MARK: - StudyTodoCardView 学习待办任务卡片
/// 显示学习分类中单个待办任务的卡片组件
/// 与 ContentView 中的 TodoCardView 类似，但使用分类主题色
/// 支持点击切换完成状态、左滑显示删除按钮、点击箭头进入编辑
struct StudyTodoCardView: View {
    // MARK: 属性
    
    /// 要显示的任务对象
    let item: Item
    
    /// 分类的主题颜色，用于卡片边框和完成按钮
    let categoryColor: Color
    
    /// 切换完成状态的回调
    let onToggle: () -> Void
    
    /// 删除任务的回调
    let onDelete: () -> Void
    
    /// 点击进入编辑的回调
    let onTap: () -> Void

    // MARK: 状态属性
    
    /// 卡片的水平偏移量（用于滑动删除手势）
    @State private var offset: CGFloat = 0
    
    /// 是否显示删除按钮
    @State private var showDeleteButton = false

    // MARK: 视图主体
    
    var body: some View {
        // 使用 ZStack 将删除按钮放在卡片下方
        ZStack(alignment: .trailing) {
            // 删除按钮背景（滑动后显示）
            deleteBackground
                .zIndex(showDeleteButton ? 1 : 0)

            // 卡片主体内容
            cardContent
                .offset(x: offset)
                .contentShape(Rectangle())
                // 点击收起删除按钮
                .onTapGesture {
                    if showDeleteButton {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            offset = 0
                            showDeleteButton = false
                        }
                    }
                }
                // 左滑手势处理
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // 向左滑动
                            if value.translation.width < 0 {
                                // 限制最大滑动距离为 80
                                offset = max(value.translation.width, -80)
                            } else if showDeleteButton {
                                // 如果删除按钮已显示，允许向右滑动收起
                                offset = min(0, -80 + value.translation.width)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                // 滑动超过 50 则显示删除按钮
                                if value.translation.width < -50 {
                                    offset = -80
                                    showDeleteButton = true
                                } else {
                                    // 否则恢复原位
                                    offset = 0
                                    showDeleteButton = false
                                }
                            }
                        }
                )
        }
    }

    // MARK: 删除按钮背景
    
    /// 滑动后显示的删除按钮
    private var deleteBackground: some View {
        HStack {
            Spacer()
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red.gradient)
                    )
            }
        }
        .padding(.trailing, 4)
        .opacity(showDeleteButton ? 1 : 0)
    }

    // MARK: 卡片主体内容
    
    /// 任务卡片的主要内容
    private var cardContent: some View {
        HStack(spacing: 16) {
            // 完成状态切换按钮（使用分类主题色）
            Button {
                onToggle()
            } label: {
                Circle()
                    .stroke(categoryColor.opacity(0.6), lineWidth: 2)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            // 任务信息区域
            VStack(alignment: .leading, spacing: 6) {
                // 任务标题
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                // 任务元信息（备注、截止日期、优先级）
                HStack(spacing: 12) {
                    // 备注指示器
                    if !item.notes.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 10))
                            Text("备注")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary)
                    }

                    // 截止日期显示
                    if let dueDate = item.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(dueDate, format: .dateTime.month(.abbreviated).day())
                                .font(.system(size: 11))
                        }
                        // 过期显示红色
                        .foregroundColor(isOverdue(dueDate) ? .red.opacity(0.8) : .secondary)
                    }

                    // 优先级徽章
                    priorityBadge
                }
            }
            // 点击信息区域也能切换完成状态
            .contentShape(Rectangle())
            .onTapGesture {
                onToggle()
            }

            Spacer()

            // 进入编辑的箭头按钮
            Button {
                onTap()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.5))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        // 卡片背景样式（带分类主题色边框）
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.15).opacity(0.9),
                            Color(white: 0.12).opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // 使用分类主题色的边框
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(categoryColor.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: 计算属性和辅助方法
    
    /// 根据优先级返回对应的颜色
    private var priorityColor: Color {
        switch item.priority {
        case .high: return .red      // 高优先级 - 红色
        case .medium: return .orange // 中优先级 - 橙色
        case .low: return .blue      // 低优先级 - 蓝色
        }
    }

    /// 优先级徽章视图
    private var priorityBadge: some View {
        Text(item.priority.label)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(priorityColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(priorityColor.opacity(0.15))
            )
    }

    /// 判断任务是否已过期
    /// - Parameter date: 截止日期
    /// - Returns: 如果截止日期已过，返回 true
    private func isOverdue(_ date: Date) -> Bool {
        date < Date()
    }
}

// MARK: - StudyCompletedCardView 学习已完成任务卡片
/// 显示学习分类中已完成任务的卡片组件
/// 与 ContentView 中的 CompletedCardView 类似
/// 样式更淡，标题带删除线
struct StudyCompletedCardView: View {
    // MARK: 属性
    
    /// 要显示的任务对象
    let item: Item
    
    /// 分类的主题颜色（目前未使用，保留用于未来扩展）
    let categoryColor: Color
    
    /// 切换完成状态的回调（恢复为未完成）
    let onToggle: () -> Void
    
    /// 删除任务的回调
    let onDelete: () -> Void

    // MARK: 视图主体
    
    var body: some View {
        HStack(spacing: 16) {
            // 完成状态按钮（绿色勾选）
            Button {
                onToggle()
            } label: {
                ZStack {
                    // 绿色圆形背景
                    Circle()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 28, height: 28)

                    // 勾选图标
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)

            // 任务信息区域
            VStack(alignment: .leading, spacing: 6) {
                // 任务标题（带删除线）
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .strikethrough(true, color: .secondary)

                // 任务元信息
                HStack(spacing: 12) {
                    // 备注指示器
                    if !item.notes.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 10))
                            Text("备注")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary.opacity(0.7))
                    }

                    // 截止日期显示
                    if let dueDate = item.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(dueDate, format: .dateTime.month(.abbreviated).day())
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary.opacity(0.7))
                    }
                }
            }

            Spacer()

            // 删除按钮
            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.secondary.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        // 卡片背景样式（比待办卡片更淡）
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.12).opacity(0.7),
                            Color(white: 0.10).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        // 整体透明度降低，表示已完成
        .opacity(0.8)
    }
}

// MARK: - 预览
#Preview {
    NavigationStack {
        CategoryDetailView(category: StudyCategory(name: "AI 学习", icon: "🤖", colorHex: "#63B3FF"), navigationState: nil)
    }
    .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
