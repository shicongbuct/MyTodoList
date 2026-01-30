//
//  StudyView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//
//  文件说明：
//  本文件定义了"学习"分区的主视图，包括：
//  - StudyView：学习分类网格主视图
//  - CategoryCardView：分类卡片组件
//  - Color 扩展：十六进制颜色转换
//  展示所有学习分类，支持分类的创建、编辑和删除
//

import SwiftUI
import SwiftData

// MARK: - StudyView 学习分类网格主视图
/// 学习分区的主视图
/// 以网格形式显示所有学习分类
/// 点击分类卡片可进入该分类的任务详情页
struct StudyView: View {
    // MARK: 环境和查询属性
    
    /// SwiftData 模型上下文，用于数据的增删改操作
    @Environment(\.modelContext) private var modelContext
    
    /// 从父视图传入的导航状态（可选）
    /// 用于跟踪当前选中的学习分类
    @Environment(NavigationState.self) private var navigationState: NavigationState?
    
    /// 查询所有学习分类，按创建时间排序
    @Query(sort: \StudyCategory.createdAt) private var categories: [StudyCategory]
    
    // MARK: 状态属性
    
    /// 控制新建分类表单的显示
    @State private var showingAddCategory = false
    
    /// 当前正在编辑的分类（用于打开编辑表单）
    @State private var editingCategory: StudyCategory?

    // MARK: 网格布局配置
    
    /// 两列自适应网格布局
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

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

                    // 根据分类数量显示不同内容
                    if categories.isEmpty {
                        // 无分类时显示空状态视图
                        emptyStateView
                    } else {
                        // 有分类时显示分类网格
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                // 遍历显示所有分类卡片
                                ForEach(categories) { category in
                                    // 点击卡片导航到分类详情页
                                    NavigationLink {
                                        CategoryDetailView(category: category, navigationState: navigationState)
                                    } label: {
                                        CategoryCardView(
                                            category: category,
                                            onEdit: {
                                                // 打开编辑表单
                                                editingCategory = category
                                            },
                                            onDelete: {
                                                // 删除分类
                                                deleteCategory(category)
                                            }
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }

                                // 添加分类按钮卡片
                                addCategoryCard
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)  // 为底部 TabBar 留出空间
                        }
                    }
                }
            }
            // 隐藏默认导航栏，使用自定义头部
            .navigationBarHidden(true)
            // 新建分类的模态表单
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
            // 编辑分类的模态表单
            .sheet(item: $editingCategory) { category in
                AddCategoryView(editingCategory: category)
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
            Text("学习")
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
    
    /// 当没有学习分类时显示的占位视图
    /// 包含图标、提示文字和创建分类按钮
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
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                // 书本图标
                Image(systemName: "book.closed")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // 提示文字
            VStack(spacing: 8) {
                Text("暂无学习分类")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("创建分类来组织你的学习任务")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // 添加分类按钮
            Button {
                showingAddCategory = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("添加分类")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: 添加分类卡片
    
    /// 网格中的"添加分类"占位卡片
    /// 点击后打开新建分类表单
    private var addCategoryCard: some View {
        Button {
            showingAddCategory = true
        } label: {
            VStack(spacing: 12) {
                // 虚线圆形图标
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .frame(width: 50, height: 50)

                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }

                // 文字标签
                Text("添加分类")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            // 虚线边框
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [8, 4]))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: 操作方法
    
    /// 删除学习分类
    /// 注意：关联的任务会被级联删除（由 @Relationship 的 deleteRule 定义）
    /// - Parameter category: 要删除的分类
    private func deleteCategory(_ category: StudyCategory) {
        withAnimation(.easeOut(duration: 0.3)) {
            modelContext.delete(category)
        }
    }
}

// MARK: - CategoryCardView 分类卡片组件
/// 显示单个学习分类的卡片
/// 展示分类图标、名称和任务数量
/// 通过 Menu 提供编辑和删除选项
struct CategoryCardView: View {
    // MARK: 属性
    
    /// 要显示的分类对象
    let category: StudyCategory
    
    /// 编辑分类的回调
    let onEdit: () -> Void
    
    /// 删除分类的回调
    let onDelete: () -> Void

    // MARK: 查询属性
    
    /// 查询所有任务（用于计算该分类的任务数量）
    @Query private var allItems: [Item]

    // MARK: 计算属性
    
    /// 该分类下未完成的任务数量
    private var itemCount: Int {
        allItems.filter { $0.category?.persistentModelID == category.persistentModelID && !$0.isCompleted }.count
    }

    /// 分类的主题颜色（从十六进制转换）
    private var categoryColor: Color {
        Color(hex: category.colorHex) ?? .blue
    }

    // MARK: 视图主体
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 顶部：图标和菜单按钮
            HStack {
                // 分类图标（emoji）
                Text(category.icon)
                    .font(.system(size: 32))

                Spacer()

                // 更多选项菜单
                Menu {
                    // 编辑选项
                    Button {
                        onEdit()
                    } label: {
                        Label("编辑", systemImage: "pencil")
                    }

                    // 删除选项（标记为破坏性操作）
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    // 省略号按钮
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }

            Spacer()

            // 底部：分类名称和任务数量
            VStack(alignment: .leading, spacing: 4) {
                // 分类名称
                Text(category.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // 任务数量
                Text("\(itemCount) 个任务")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        // 卡片背景样式（使用分类主题色）
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            categoryColor.opacity(0.3),  // 较亮
                            categoryColor.opacity(0.15)  // 较暗
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // 主题色边框
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(categoryColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Color 扩展
/// 为 Color 类型添加十六进制颜色支持
extension Color {
    /// 从十六进制字符串创建颜色
    /// - Parameter hex: 十六进制颜色代码（可带或不带 # 前缀）
    /// - Returns: 对应的 Color 对象，如果解析失败返回 nil
    ///
    /// 使用示例:
    /// ```
    /// let blue = Color(hex: "#63B3FF")
    /// let red = Color(hex: "FF6363")
    /// ```
    init?(hex: String) {
        // 清理输入字符串
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        // 移除 # 前缀（如果有）
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        // 存储解析后的 RGB 值
        var rgb: UInt64 = 0

        // 使用 Scanner 解析十六进制字符串
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        // 提取 RGB 分量并转换为 0-1 范围
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0  // 红色分量
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0   // 绿色分量
        let b = Double(rgb & 0x0000FF) / 255.0          // 蓝色分量

        // 使用 RGB 值初始化颜色
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - 预览
#Preview {
    StudyView()
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
