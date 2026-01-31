//
//  IngredientCategoryDetailView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import SwiftUI
import SwiftData

struct IngredientCategoryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let category: IngredientCategory

    @State private var showingAddIngredient = false

    private var ingredients: [Ingredient] {
        (category.ingredients ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
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
                    headerView

                    if ingredients.isEmpty {
                        emptyView
                    } else {
                        ingredientsGrid
                    }

                    Spacer(minLength: 40)
                }
                .padding(20)
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddIngredient = true
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showingAddIngredient) {
            AddIngredientView(category: category)
        }
        .preferredColorScheme(.dark)
    }

    private var headerView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.2))
                    .frame(width: 100, height: 100)

                Text(category.icon)
                    .font(.system(size: 48))
            }

            Text("\(ingredients.count) 种食材")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf")
                .font(.system(size: 40))
                .foregroundColor(.orange.opacity(0.5))

            Text("还没有食材")
                .font(.system(size: 16))
                .foregroundColor(.secondary)

            Text("点击右上角 + 添加")
                .font(.system(size: 14))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var ingredientsGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(ingredients) { ingredient in
                IngredientCard(ingredient: ingredient, categoryColor: category.color) {
                    deleteIngredient(ingredient)
                }
            }
        }
    }

    private func deleteIngredient(_ ingredient: Ingredient) {
        withAnimation(.easeOut(duration: 0.3)) {
            modelContext.delete(ingredient)
        }
    }
}

struct IngredientCard: View {
    let ingredient: Ingredient
    let categoryColor: Color
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(ingredient.icon)
                .font(.system(size: 32))

            Text(ingredient.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(categoryColor.opacity(0.3), lineWidth: 1)
                )
        )
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
}

#Preview {
    let category = IngredientCategory(name: "水果", icon: "🍎", colorHex: "#FF6B6B")
    return NavigationStack {
        IngredientCategoryDetailView(category: category)
    }
    .modelContainer(for: [IngredientCategory.self, Ingredient.self], inMemory: true)
}
