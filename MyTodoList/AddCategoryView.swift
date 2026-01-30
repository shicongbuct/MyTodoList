//
//  AddCategoryView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//

import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var editingCategory: StudyCategory?

    @State private var name: String = ""
    @State private var icon: String = ""
    @State private var selectedColorHex: String = "#63B3FF"

    @FocusState private var nameFocused: Bool

    private let presetColors: [String] = [
        "#63B3FF", "#FF9F63", "#63FFB3", "#FF63B3",
        "#FFD663", "#63FFF5", "#B363FF", "#FF6363"
    ]

    private let presetIcons: [String] = [
        "🤖", "💡", "🐍", "📖", "🎯", "🧠", "💻", "🔬",
        "📊", "🎨", "🎵", "🌍", "📚", "✏️", "🔧", "⚡️"
    ]

    private var isEditing: Bool {
        editingCategory != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.12),
                        Color(red: 0.10, green: 0.08, blue: 0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        previewSection
                        nameSection
                        iconSection
                        colorSection

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(isEditing ? "编辑分类" : "新建分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "保存" : "添加") {
                        saveCategory()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || icon.isEmpty)
                }
            }
            .onAppear {
                if let category = editingCategory {
                    name = category.name
                    icon = category.icon
                    selectedColorHex = category.colorHex
                }
                nameFocused = true
            }
        }
        .preferredColorScheme(.dark)
    }

    private var previewSection: some View {
        VStack(spacing: 16) {
            ZStack {
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

                VStack(spacing: 8) {
                    Text(icon.isEmpty ? "📝" : icon)
                        .font(.system(size: 40))

                    Text(name.isEmpty ? "分类名称" : name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(name.isEmpty ? .secondary : .white)
                }
            }

            Text("预览")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("名称")

            TextField("输入分类名称", text: $name)
                .font(.system(size: 17))
                .padding(16)
                .background(inputBackground)
                .focused($nameFocused)
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("图标")

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
                                    .fill(icon == emoji ? Color.white.opacity(0.15) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
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

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("颜色")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 8), spacing: 12) {
                ForEach(presetColors, id: \.self) { colorHex in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedColorHex = colorHex
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: colorHex) ?? .blue)
                                .frame(width: 36, height: 36)

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

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }

    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color(white: 0.15).opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        if let category = editingCategory {
            category.name = trimmedName
            category.icon = icon
            category.colorHex = selectedColorHex
        } else {
            let newCategory = StudyCategory(
                name: trimmedName,
                icon: icon,
                colorHex: selectedColorHex
            )
            modelContext.insert(newCategory)
        }

        dismiss()
    }
}

#Preview {
    AddCategoryView()
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}

#Preview("Edit Mode") {
    AddCategoryView(editingCategory: StudyCategory(name: "AI 学习", icon: "🤖", colorHex: "#63B3FF"))
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
