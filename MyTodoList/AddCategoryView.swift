//
//  AddCategoryView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//
//  文件说明：
//  本文件定义了新建/编辑学习分类的表单视图
//  支持设置分类的名称、图标（emoji）和主题颜色
//  可用于创建新分类或编辑已存在的分类
//

import SwiftUI
import SwiftData

// MARK: - AddCategoryView 新建/编辑分类表单
/// 新建或编辑学习分类的表单视图
/// 以模态表单形式呈现
/// 如果传入 editingCategory，则进入编辑模式；否则为新建模式
struct AddCategoryView: View {
    // MARK: 环境属性
    
    /// SwiftData 模型上下文，用于插入新分类
    @Environment(\.modelContext) private var modelContext
    
    /// 关闭当前视图的环境操作
    @Environment(\.dismiss) private var dismiss

    // MARK: 初始化属性
    
    /// 要编辑的分类对象（可选）
    /// 如果传入，则为编辑模式；如果为 nil，则为新建模式
    var editingCategory: StudyCategory?

    // MARK: 表单状态属性
    
    /// 分类名称
    @State private var name: String = ""
    
    /// 分类图标（emoji）
    @State private var icon: String = ""
    
    /// 选中的主题颜色（十六进制代码）
    /// 默认为第一个预设颜色（蓝色）
    @State private var selectedColorHex: String = "#63B3FF"

    // MARK: 焦点状态
    
    /// 名称输入框的焦点状态
    /// 用于在表单出现时自动聚焦
    @FocusState private var nameFocused: Bool

    // MARK: 预设数据
    
    /// 预设的颜色列表
    /// 提供 8 种常用颜色供用户选择
    private let presetColors: [String] = [
        "#63B3FF",  // 蓝色
        "#FF9F63",  // 橙色
        "#63FFB3",  // 绿色
        "#FF63B3",  // 粉色
        "#FFD663",  // 黄色
        "#63FFF5",  // 青色
        "#B363FF",  // 紫色
        "#FF6363"   // 红色
    ]

    /// 预设的图标列表
    /// 提供 16 种常用 emoji 供用户选择
    private let presetIcons: [String] = [
        "🤖", "💡", "🐍", "📖", "🎯", "🧠", "💻", "🔬",
        "📊", "🎨", "🎵", "🌍", "📚", "✏️", "🔧", "⚡️"
    ]

    // MARK: 计算属性
    
    /// 判断是否为编辑模式
    private var isEditing: Bool {
        editingCategory != nil
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
                    VStack(spacing: 28) {
                        // 实时预览区域
                        previewSection
                        
                        // 名称输入区域
                        nameSection
                        
                        // 图标选择区域
                        iconSection
                        
                        // 颜色选择区域
                        colorSection

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            // 导航栏配置（根据模式显示不同标题）
            .navigationTitle(isEditing ? "编辑分类" : "新建分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 取消按钮
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                // 保存/添加按钮
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "保存" : "添加") {
                        saveCategory()
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
                    // 名称为空或未选择图标时禁用
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || icon.isEmpty)
                }
            }
            // 视图出现时初始化
            .onAppear {
                // 如果是编辑模式，加载现有分类的数据
                if let category = editingCategory {
                    name = category.name
                    icon = category.icon
                    selectedColorHex = category.colorHex
                }
                // 自动聚焦到名称输入框
                nameFocused = true
            }
        }
        // 强制使用深色模式
        .preferredColorScheme(.dark)
    }

    // MARK: 预览区域
    
    /// 分类卡片实时预览
    /// 根据当前输入的名称、图标和颜色实时显示效果
    private var previewSection: some View {
        VStack(spacing: 16) {
            // 预览卡片
            ZStack {
                // 卡片背景（使用选中的颜色）
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                (Color(hex: selectedColorHex) ?? .blue).opacity(0.3),
                                (Color(hex: selectedColorHex) ?? .blue).opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke((Color(hex: selectedColorHex) ?? .blue).opacity(0.3), lineWidth: 1)
                    )
                    .frame(height: 120)

                // 预览内容（图标和名称）
                VStack(spacing: 8) {
                    // 图标（未选择时显示默认图标）
                    Text(icon.isEmpty ? "📝" : icon)
                        .font(.system(size: 40))

                    // 名称（未输入时显示占位文字）
                    Text(name.isEmpty ? "分类名称" : name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(name.isEmpty ? .secondary : .white)
                }
            }

            // 预览标签
            Text("预览")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: 名称输入区域
    
    /// 分类名称输入区域
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("名称")

            TextField("输入分类名称", text: $name)
                .font(.system(size: 17))
                .padding(16)
                .background(inputBackground)
                .focused($nameFocused)  // 绑定焦点状态
        }
    }

    // MARK: 图标选择区域
    
    /// 分类图标选择区域
    /// 以网格形式显示所有预设的 emoji 图标
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("图标")

            // 8 列网格布局
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 8), spacing: 12) {
                ForEach(presetIcons, id: \.self) { emoji in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            icon = emoji
                        }
                    } label: {
                        Text(emoji)
                            .font(.system(size: 24))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    // 选中的图标显示高亮背景
                                    .fill(icon == emoji ? Color.white.opacity(0.15) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            // 选中的图标显示更明显的边框
                                            .stroke(icon == emoji ? Color.white.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(inputBackground)
        }
    }

    // MARK: 颜色选择区域
    
    /// 分类主题颜色选择区域
    /// 以网格形式显示所有预设的颜色
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("颜色")

            // 8 列网格布局
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 8), spacing: 12) {
                ForEach(presetColors, id: \.self) { colorHex in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedColorHex = colorHex
                        }
                    } label: {
                        ZStack {
                            // 颜色圆点
                            Circle()
                                .fill(Color(hex: colorHex) ?? .blue)
                                .frame(width: 36, height: 36)

                            // 选中状态显示白色边框
                            if selectedColorHex == colorHex {
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(inputBackground)
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
    
    /// 保存分类
    /// 根据模式执行不同操作：
    /// - 编辑模式：更新现有分类的属性
    /// - 新建模式：创建新分类并插入到数据上下文
    private func saveCategory() {
        // 去除名称两端的空白字符
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        if let category = editingCategory {
            // 编辑模式：更新现有分类
            category.name = trimmedName
            category.icon = icon
            category.colorHex = selectedColorHex
        } else {
            // 新建模式：创建并插入新分类
            let newCategory = StudyCategory(
                name: trimmedName,
                icon: icon,
                colorHex: selectedColorHex
            )
            modelContext.insert(newCategory)
        }

        // 关闭表单
        dismiss()
    }
}

// MARK: - 预览
#Preview {
    AddCategoryView()
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}

#Preview("Edit Mode") {
    AddCategoryView(editingCategory: StudyCategory(name: "AI 学习", icon: "🤖", colorHex: "#63B3FF"))
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
