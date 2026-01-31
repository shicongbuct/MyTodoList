//
//  AddIngredientCategoryView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import SwiftUI
import SwiftData

struct AddIngredientCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedIcon: String = "🥩"
    @State private var selectedColorHex: String = "#FF6B6B"

    private let iconOptions = [
        "🥩", "🥬", "🍚", "🍎", "🍪", "🥛", "🧀", "🥚",
        "🍞", "🍝", "🍜", "🥗", "🍖", "🐟", "🦐", "🥕"
    ]

    private let colorOptions = [
        "#FF6B6B", "#FF9F63", "#FFD93D", "#6BCB77",
        "#4D96FF", "#9B59B6", "#FF63B3", "#63B3FF"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.10, blue: 0.08),
                        Color(red: 0.18, green: 0.12, blue: 0.10)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 预览
                        previewCard

                        // 名称输入
                        nameSection

                        // 图标选择
                        iconSection

                        // 颜色选择
                        colorSection

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("添加分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addCategory()
                    }
                    .foregroundColor(.orange)
                    .disabled(name.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var previewCard: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill((Color(hex: selectedColorHex) ?? .orange).opacity(0.2))
                    .frame(width: 80, height: 80)

                Text(selectedIcon)
                    .font(.system(size: 40))
            }

            Text(name.isEmpty ? "分类名称" : name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.vertical, 20)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分类名称")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            TextField("输入分类名称", text: $name)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                )
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择图标")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 8), spacing: 12) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                    } label: {
                        Text(icon)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedIcon == icon ? Color.orange.opacity(0.3) : Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedIcon == icon ? Color.orange : Color.clear, lineWidth: 2)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择颜色")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            HStack(spacing: 12) {
                ForEach(colorOptions, id: \.self) { colorHex in
                    Button {
                        selectedColorHex = colorHex
                    } label: {
                        Circle()
                            .fill(Color(hex: colorHex) ?? .orange)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColorHex == colorHex ? 3 : 0)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func addCategory() {
        let category = IngredientCategory(
            name: name,
            icon: selectedIcon,
            colorHex: selectedColorHex
        )
        modelContext.insert(category)
        dismiss()
    }
}

#Preview {
    AddIngredientCategoryView()
        .modelContainer(for: IngredientCategory.self, inMemory: true)
}
