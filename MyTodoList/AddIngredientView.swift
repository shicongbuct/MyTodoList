//
//  AddIngredientView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import SwiftUI
import SwiftData

struct AddIngredientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let category: IngredientCategory

    @State private var name: String = ""
    @State private var selectedIcon: String = "🍎"

    private var iconOptions: [String] {
        switch category.name {
        case "肉类":
            return ["🥩", "🍖", "🥓", "🍗", "🦴", "🌭", "🥪", "🍔"]
        case "蔬菜":
            return ["🥬", "🥦", "🥒", "🍅", "🥕", "🌽", "🥔", "🧄", "🧅", "🍆", "🌶️", "🫑"]
        case "主食":
            return ["🍚", "🍞", "🥖", "🥐", "🥯", "🍝", "🍜", "🥟", "🫓", "🧇"]
        case "水果":
            return ["🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍑", "🥝", "🥭", "🍍", "🍒"]
        case "零食":
            return ["🍪", "🍩", "🍰", "🧁", "🍫", "🍬", "🍭", "🥜", "🌰"]
        default:
            return ["🍽️", "🥗", "🍲", "🥘", "🫕", "🍱", "🥡", "🧆"]
        }
    }

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

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("添加\(category.name)")
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
                        addIngredient()
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
            Text(selectedIcon)
                .font(.system(size: 56))

            Text(name.isEmpty ? "食材名称" : name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.vertical, 20)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("食材名称")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            TextField("输入食材名称", text: $name)
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

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                    } label: {
                        Text(icon)
                            .font(.system(size: 32))
                            .frame(width: 52, height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIcon == icon ? category.color.opacity(0.3) : Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedIcon == icon ? category.color : Color.clear, lineWidth: 2)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func addIngredient() {
        let ingredient = Ingredient(
            name: name,
            icon: selectedIcon,
            category: category
        )
        modelContext.insert(ingredient)
        dismiss()
    }
}

#Preview {
    let category = IngredientCategory(name: "水果", icon: "🍎", colorHex: "#FF6B6B")
    return AddIngredientView(category: category)
        .modelContainer(for: [IngredientCategory.self, Ingredient.self], inMemory: true)
}
