//
//  CookView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import SwiftUI
import SwiftData

struct CookView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \IngredientCategory.createdAt) private var categories: [IngredientCategory]
    @Query private var allMealPlans: [MealPlan]

    @State private var showingAddCategory = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // 获取今日、明日、后天的日期
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
    }

    private var dayAfterTomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 2, to: today) ?? today
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
                        headerView

                        ingredientSection

                        mealPlanSection

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingAddCategory) {
            AddIngredientCategoryView()
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Date(), format: .dateTime.weekday(.wide).month().day())
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("食材")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(white: 0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
    }

    private var ingredientSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("已有食材")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Text("\(categories.count) 个分类")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            categoriesGrid
        }
        .padding(20)
        .background(sectionBackground)
    }

    private var categoriesGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories) { category in
                NavigationLink {
                    IngredientCategoryDetailView(category: category)
                } label: {
                    CategoryCard(category: category) {
                        deleteCategory(category)
                    }
                }
                .buttonStyle(.plain)
            }

            // 添加分类按钮
            Button {
                showingAddCategory = true
            } label: {
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 60, height: 60)

                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.orange)
                    }

                    VStack(spacing: 4) {
                        Text("添加分类")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.orange)

                        Text("")
                            .font(.system(size: 12))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var mealPlanSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("饮食计划")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            VStack(spacing: 16) {
                DayMealPlanView(
                    date: today,
                    dayLabel: "今日",
                    allMealPlans: allMealPlans,
                    modelContext: modelContext
                )

                DayMealPlanView(
                    date: tomorrow,
                    dayLabel: "明日",
                    allMealPlans: allMealPlans,
                    modelContext: modelContext
                )

                DayMealPlanView(
                    date: dayAfterTomorrow,
                    dayLabel: "后天",
                    allMealPlans: allMealPlans,
                    modelContext: modelContext
                )
            }
        }
        .padding(20)
        .background(sectionBackground)
    }

    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(white: 0.12).opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    private func deleteCategory(_ category: IngredientCategory) {
        withAnimation(.easeOut(duration: 0.3)) {
            modelContext.delete(category)
        }
    }
}

struct DayMealPlanView: View {
    let date: Date
    let dayLabel: String
    let allMealPlans: [MealPlan]
    let modelContext: ModelContext

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(dayLabel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text(dateString)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(MealType.allCases, id: \.rawValue) { mealType in
                    MealPlanRow(
                        date: date,
                        mealType: mealType,
                        allMealPlans: allMealPlans,
                        modelContext: modelContext
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct MealPlanRow: View {
    let date: Date
    let mealType: MealType
    let allMealPlans: [MealPlan]
    let modelContext: ModelContext

    @State private var isEditing = false
    @State private var editText = ""

    private var existingPlan: MealPlan? {
        let dayStart = Calendar.current.startOfDay(for: date)
        return allMealPlans.first { plan in
            plan.date == dayStart && plan.mealType == mealType
        }
    }

    private var planContent: String {
        existingPlan?.content ?? ""
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(mealType.icon)
                .font(.system(size: 16))
                .frame(width: 24)

            Text(mealType.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 40, alignment: .leading)

            if isEditing {
                TextField("输入计划...", text: $editText)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        savePlan()
                    }

                Button {
                    savePlan()
                } label: {
                    Text("保存")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                }
            } else {
                Text(planContent.isEmpty ? "点击编辑" : planContent)
                    .font(.system(size: 14))
                    .foregroundColor(planContent.isEmpty ? .secondary : .white.opacity(0.9))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editText = planContent
                        isEditing = true
                    }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
        )
    }

    private func savePlan() {
        let dayStart = Calendar.current.startOfDay(for: date)

        if let plan = existingPlan {
            plan.content = editText
            plan.updatedAt = Date()
        } else if !editText.isEmpty {
            let newPlan = MealPlan(date: dayStart, mealType: mealType, content: editText)
            modelContext.insert(newPlan)
        }

        isEditing = false
    }
}

struct CategoryCard: View {
    let category: IngredientCategory
    let onDelete: () -> Void

    private var ingredientCount: Int {
        category.ingredients?.count ?? 0
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(category.color.opacity(0.2))
                    .frame(width: 60, height: 60)

                Text(category.icon)
                    .font(.system(size: 32))
            }

            VStack(spacing: 4) {
                Text(category.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text("\(ingredientCount) 种")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(category.color.opacity(0.2), lineWidth: 1)
                )
        )
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("删除分类", systemImage: "trash")
            }
        }
    }
}

#Preview {
    CookView()
        .modelContainer(for: [IngredientCategory.self, Ingredient.self, MealPlan.self], inMemory: true)
}
