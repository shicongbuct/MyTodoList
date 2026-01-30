//
//  MainTabView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//
//  文件说明：
//  本文件定义了应用的主框架视图，包括：
//  - NavigationState：全局导航状态管理类
//  - MainTabView：主视图，包含底部 TabBar 和悬浮添加按钮(FAB)
//  该视图是应用启动后的根视图，负责在"生活"和"学习"两个分区之间切换
//

import SwiftUI
import SwiftData

// MARK: - NavigationState 导航状态管理类
/// 全局导航状态管理类
/// 使用 @Observable 宏使其成为可观察对象
/// 用于在不同视图之间共享导航状态信息
@Observable
class NavigationState {
    /// 当前选中的学习分类
    /// 当用户进入某个学习分类的详情页时，该属性会被设置
    /// 用于判断 FAB 按钮点击时应该创建哪种类型的任务
    var selectedStudyCategory: StudyCategory?
}

// MARK: - MainTabView 主视图
/// 应用的主框架视图
/// 包含自定义的底部 TabBar 和中央的悬浮添加按钮(FAB)
/// 管理"生活"和"学习"两个主要分区的切换
struct MainTabView: View {
    // MARK: 状态属性
    
    /// 当前选中的 Tab 索引
    /// 0 = 生活分区，1 = 学习分区
    @State private var selectedTab = 0
    
    /// 控制添加任务表单的显示状态
    @State private var showingAddSheet = false
    
    /// 新建任务时的目标分区
    /// 由 FAB 按钮点击时根据当前上下文设置
    @State private var addSection: Section = .life
    
    /// 新建任务时的目标学习分类（可选）
    /// 仅在学习分区的分类详情页创建任务时使用
    @State private var addCategory: StudyCategory?
    
    /// 全局导航状态对象
    /// 通过环境传递给子视图，用于跟踪当前所在的学习分类
    @State private var navigationState = NavigationState()

    // MARK: 视图主体
    
    var body: some View {
        // 使用 ZStack 将 TabBar 和 FAB 叠加在内容上方
        ZStack(alignment: .bottom) {
            // TabView 管理两个主要分区的内容
            TabView(selection: $selectedTab) {
                // 生活分区 - 显示日常任务列表
                ContentView()
                    .tag(0)

                // 学习分区 - 显示学习分类网格
                // 将导航状态注入环境，供子视图使用
                StudyView()
                    .environment(navigationState)
                    .tag(1)
            }

            // 自定义底部 TabBar
            customTabBar

            // 悬浮添加按钮(FAB)
            // 向上偏移使其位于 TabBar 上方
            fabButton
                .offset(y: -12)
        }
        // 忽略键盘对布局的影响
        .ignoresSafeArea(.keyboard)
        // 添加任务的模态表单
        .sheet(isPresented: $showingAddSheet) {
            AddTodoView(initialSection: addSection, initialCategory: addCategory)
        }
        // 强制使用深色模式
        .preferredColorScheme(.dark)
    }

    // MARK: 自定义 TabBar
    
    /// 自定义底部导航栏
    /// 包含"生活"和"学习"两个 Tab 按钮，中间留出空间给 FAB
    private var customTabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // 生活 Tab 按钮（左侧）
                tabButton(icon: "house.fill", label: "生活", tag: 0)

                // 中间空白区域，为 FAB 按钮留出位置
                Spacer()
                    .frame(width: 80)

                // 学习 Tab 按钮（右侧）
                tabButton(icon: "book.fill", label: "学习", tag: 1)
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        // TabBar 背景样式
        .background(
            Rectangle()
                .fill(
                    // 深色背景
                    Color(red: 0.06, green: 0.06, blue: 0.10)
                )
                .overlay(
                    // 顶部细线装饰
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 0.5),
                    alignment: .top
                )
                // 延伸到安全区域底部
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: Tab 按钮生成器
    
    /// 创建单个 Tab 按钮
    /// - Parameters:
    ///   - icon: SF Symbols 图标名称
    ///   - label: 按钮文字标签
    ///   - tag: Tab 的索引标识
    /// - Returns: 配置好的 Tab 按钮视图
    private func tabButton(icon: String, label: String, tag: Int) -> some View {
        // 判断当前 Tab 是否被选中
        let isSelected = selectedTab == tag
        // 根据 Tab 类型设置活跃状态的颜色
        // 生活分区使用青色，学习分区使用紫色
        let activeColor = tag == 0 ? Color.cyan : Color.purple

        return Button {
            // 点击时切换 Tab，带弹簧动画效果
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    // 选中状态时显示圆形背景
                    if isSelected {
                        Circle()
                            .fill(activeColor.opacity(0.2))
                            .frame(width: 44, height: 44)
                    }

                    // Tab 图标
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            // 选中时使用渐变色，未选中时使用灰色
                            isSelected
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [activeColor, activeColor.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                  ))
                                : AnyShapeStyle(Color.secondary.opacity(0.6))
                        )
                }
                .frame(height: 44)

                // Tab 文字标签
                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? activeColor : .secondary.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: FAB 悬浮添加按钮
    
    /// 悬浮添加按钮(Floating Action Button)
    /// 位于屏幕底部中央，点击后打开新建任务表单
    /// 根据当前所在页面自动设置新任务的分区和分类
    private var fabButton: some View {
        Button {
            // 根据当前上下文决定新任务的分区和分类
            if let category = navigationState.selectedStudyCategory {
                // 情况1：在学习分类详情页
                // 新任务属于学习分区，并关联当前分类
                addSection = .study
                addCategory = category
            } else if selectedTab == 1 {
                // 情况2：在学习主页（分类列表页）
                // 新任务属于学习分区，但不预选分类
                addSection = .study
                addCategory = nil
            } else {
                // 情况3：在生活页
                // 新任务属于生活分区
                addSection = .life
                addCategory = nil
            }
            // 显示添加任务表单
            showingAddSheet = true
        } label: {
            ZStack {
                // 圆形按钮背景，带渐变色
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.35, blue: 1.0),  // 亮紫色
                                Color(red: 0.40, green: 0.25, blue: 0.95) // 深紫色
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    // 添加紫色阴影增加立体感
                    .shadow(color: Color.purple.opacity(0.5), radius: 15, x: 0, y: 8)

                // 加号图标
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - 预览
#Preview {
    MainTabView()
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
