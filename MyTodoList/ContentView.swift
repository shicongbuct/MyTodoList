//
//  ContentView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//
//  文件说明：
//  本文件定义了"生活"分区的主视图，包括：
//  - ContentView：生活任务列表主视图
//  - TodoCardView：待办任务卡片组件
//  - CompletedCardView：已完成任务卡片组件
//  展示所有生活分区的待办任务，支持搜索、完成状态切换和删除操作
//

import SwiftUI
import SwiftData

// MARK: - ContentView 生活任务列表主视图
/// 生活分区的主视图
/// 显示所有属于"生活"分区的待办任务
/// 分为"待办"和"已完成"两个区域展示
struct ContentView: View {
    // MARK: 环境和查询属性
    
    /// SwiftData 模型上下文，用于数据的增删改操作
    @Environment(\.modelContext) private var modelContext
    
    /// 查询生活分区的所有任务
    /// - filter: sectionRaw == 0 筛选生活分区的任务
    /// - sort: 按创建时间排序
    /// - order: .reverse 最新创建的在前面
    @Query(
        filter: #Predicate<Item> { $0.sectionRaw == 0 },
        sort: \Item.createdAt,
        order: .reverse
    ) private var items: [Item]
    
    // MARK: 状态属性
    
    /// 搜索关键词
    @State private var searchText = ""
    
    /// 控制清空已完成任务确认弹窗的显示
    @State private var showingClearAlert = false
    
    /// 当前正在编辑的任务（用于打开编辑表单）
    @State private var editingItem: Item?

    // MARK: 计算属性
    
    /// 根据搜索关键词过滤后的任务列表
    /// 如果搜索框为空，返回所有任务
    /// 否则返回标题包含搜索关键词的任务（不区分大小写）
    private var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    /// 待办任务列表（未完成的任务）
    private var pendingItems: [Item] {
        filteredItems.filter { !$0.isCompleted }
    }

    /// 已完成任务列表
    private var completedItems: [Item] {
        filteredItems.filter { $0.isCompleted }
    }

    // MARK: 视图主体
    
    var body: some View {
        NavigationStack {
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
                    // 页面头部
                    headerView

                    // 根据任务数量显示不同内容
                    if items.isEmpty {
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
                                        TodoCardView(item: item) {
                                            // 切换完成状态
                                            toggleComplete(item)
                                        } onDelete: {
                                            // 删除任务
                                            deleteItem(item)
                                        } onTap: {
                                            // 打开编辑表单
                                            editingItem = item
                                        }
                                        // 使用复合 ID 确保动画正确
                                        .id("\(item.persistentModelID)-pending")
                                        // 添加进入/退出动画
                                        .transition(.asymmetric(
                                            insertion: .scale.combined(with: .opacity),
                                            removal: .slide.combined(with: .opacity)
                                        ))
                                    }
                                }

                                // 已完成任务区域
                                if !completedItems.isEmpty {
                                    completedSectionHeader
                                        .padding(.top, pendingItems.isEmpty ? 0 : 20)
                                    ForEach(completedItems) { item in
                                        CompletedCardView(item: item) {
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
                        // 添加搜索功能
                        .searchable(text: $searchText, prompt: "搜索任务...")
                    }
                }
            }
            // 隐藏默认导航栏，使用自定义头部
            .navigationBarHidden(true)
            // 编辑任务的模态表单
            .sheet(item: $editingItem) { item in
                EditTodoView(item: item)
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
        }
        // 强制使用深色模式
        .preferredColorScheme(.dark)
    }

    // MARK: 页面头部视图
    
    /// 页面顶部的日期和标题显示
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 显示当前日期（星期、月、日）
            Text(Date(), format: .dateTime.weekday(.wide).month().day())
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            // 页面标题
            Text("生活")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(
                    // 白色渐变效果
                    LinearGradient(
                        colors: [.white, Color(white: 0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    // MARK: 空状态视图
    
    /// 当没有任务时显示的占位视图
    /// 包含图标和提示文字，引导用户创建第一个任务
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            // 带模糊背景的图标
            ZStack {
                // 模糊圆形背景
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.3),
                                Color.blue.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                // 勾选图标
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // 提示文字
            VStack(spacing: 8) {
                Text("暂无任务")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("点击 + 按钮创建第一个任务")
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

// MARK: - TodoCardView 待办任务卡片
/// 显示单个待办任务的卡片组件
/// 支持点击切换完成状态、左滑显示删除按钮、点击箭头进入编辑
struct TodoCardView: View {
    // MARK: 属性
    
    /// 要显示的任务对象
    let item: Item
    
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
            // 完成状态切换按钮（圆形边框）
            Button {
                onToggle()
            } label: {
                Circle()
                    .stroke(priorityColor.opacity(0.6), lineWidth: 2)
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
        // 卡片背景样式
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
                    // 细微的边框
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
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
    /// - Returns: 如果任务未完成且截止日期已过，返回 true
    private func isOverdue(_ date: Date) -> Bool {
        !item.isCompleted && date < Date()
    }
}

// MARK: - CompletedCardView 已完成任务卡片
/// 显示已完成任务的卡片组件
/// 相比待办卡片，样式更淡，标题带删除线
struct CompletedCardView: View {
    // MARK: 属性
    
    /// 要显示的任务对象
    let item: Item
    
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
                    .foregroundColor(.secondary.opacity(0.6))
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
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
