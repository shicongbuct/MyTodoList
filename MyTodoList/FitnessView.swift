//
//  FitnessView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import SwiftUI
import SwiftData

struct FitnessView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExercisePreset.createdAt) private var presets: [ExercisePreset]
    @Query(sort: \TodayExercise.createdAt) private var allExercises: [TodayExercise]
    @Query(sort: \FitnessPlan.updatedAt) private var allPlans: [FitnessPlan]

    @State private var weeklyPlanText: String = ""
    @State private var monthlyPlanText: String = ""
    @State private var isEditingWeekly = false
    @State private var isEditingMonthly = false
    @State private var showingAddExercise = false

    // 隐藏功能相关状态
    @State private var pullOffset: CGFloat = 0
    @State private var showingPassword = false
    @State private var showingHiddenView = false

    @Binding var selectedTab: Int

    private var todayExercises: [TodayExercise] {
        let today = Calendar.current.startOfDay(for: Date())
        return allExercises.filter { $0.date == today }
    }

    private var currentWeeklyPlan: FitnessPlan? {
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return allPlans.first { $0.planType == .weekly && $0.startDate == weekStart }
    }

    private var currentMonthlyPlan: FitnessPlan? {
        let monthStart = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        return allPlans.first { $0.planType == .monthly && $0.startDate == monthStart }
    }

    var body: some View {
        ZStack {
            if showingHiddenView {
                HiddenTodoView {
                    showingHiddenView = false
                    selectedTab = 0
                }
            } else {
                mainContent
            }
        }
    }

    private var mainContent: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.12, blue: 0.08),
                        Color(red: 0.10, green: 0.14, blue: 0.10)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 隐藏的检测区域
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { _, newValue in
                                    let offset = newValue - 100 // 调整基准值
                                    pullOffset = max(0, offset)

                                    // 当下拉超过阈值且松开时触发
                                    if offset > 180 && !showingPassword {
                                        showingPassword = true
                                    }
                                }
                        }
                        .frame(height: 1)

                        headerView

                        todaySection

                        weeklyPlanSection

                        monthlyPlanSection

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                }

                // 右下角 FAB 按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingAddExercise = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.green,
                                                Color.green.opacity(0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                    .shadow(color: Color.green.opacity(0.5), radius: 15, x: 0, y: 8)

                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadPlans()
                pullOffset = 0
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
        .fullScreenCover(isPresented: $showingPassword) {
            PasswordView(
                onSuccess: {
                    showingPassword = false
                    showingHiddenView = true
                },
                onFailure: {
                    showingPassword = false
                    selectedTab = 0
                }
            )
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Date(), format: .dateTime.weekday(.wide).month().day())
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("健身")
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

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("今日计划")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                if !todayExercises.isEmpty {
                    let completed = todayExercises.filter { $0.isCompleted }.count
                    Text("\(completed)/\(todayExercises.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green.opacity(0.8))
                }
            }

            if todayExercises.isEmpty {
                emptyTodayView
            } else {
                VStack(spacing: 12) {
                    ForEach(todayExercises) { exercise in
                        TodayExerciseCard(exercise: exercise) {
                            toggleExercise(exercise)
                        } onDelete: {
                            deleteExercise(exercise)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(sectionBackground)
    }

    private var emptyTodayView: some View {
        Button {
            showingAddExercise = true
        } label: {
            VStack(spacing: 12) {
                Image(systemName: "figure.run")
                    .font(.system(size: 32))
                    .foregroundColor(.green.opacity(0.5))

                Text("点击 + 添加今日运动")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
        .buttonStyle(.plain)
    }

    private var weeklyPlanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("本周计划")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    if isEditingWeekly {
                        saveWeeklyPlan()
                    }
                    isEditingWeekly.toggle()
                } label: {
                    Text(isEditingWeekly ? "保存" : "编辑")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
            }

            if isEditingWeekly {
                TextEditor(text: $weeklyPlanText)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
            } else {
                Text(weeklyPlanText.isEmpty ? "点击编辑添加本周计划..." : weeklyPlanText)
                    .font(.system(size: 15))
                    .foregroundColor(weeklyPlanText.isEmpty ? .secondary : .white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
        }
        .padding(20)
        .background(sectionBackground)
    }

    private var monthlyPlanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("本月计划")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    if isEditingMonthly {
                        saveMonthlyPlan()
                    }
                    isEditingMonthly.toggle()
                } label: {
                    Text(isEditingMonthly ? "保存" : "编辑")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
            }

            if isEditingMonthly {
                TextEditor(text: $monthlyPlanText)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
            } else {
                Text(monthlyPlanText.isEmpty ? "点击编辑添加本月计划..." : monthlyPlanText)
                    .font(.system(size: 15))
                    .foregroundColor(monthlyPlanText.isEmpty ? .secondary : .white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
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

    private func loadPlans() {
        weeklyPlanText = currentWeeklyPlan?.content ?? ""
        monthlyPlanText = currentMonthlyPlan?.content ?? ""
    }

    private func saveWeeklyPlan() {
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()

        if let plan = currentWeeklyPlan {
            plan.content = weeklyPlanText
            plan.updatedAt = Date()
        } else {
            let newPlan = FitnessPlan(content: weeklyPlanText, planType: .weekly, startDate: weekStart)
            modelContext.insert(newPlan)
        }
    }

    private func saveMonthlyPlan() {
        let monthStart = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()

        if let plan = currentMonthlyPlan {
            plan.content = monthlyPlanText
            plan.updatedAt = Date()
        } else {
            let newPlan = FitnessPlan(content: monthlyPlanText, planType: .monthly, startDate: monthStart)
            modelContext.insert(newPlan)
        }
    }

    private func toggleExercise(_ exercise: TodayExercise) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            exercise.isCompleted.toggle()
        }
    }

    private func deleteExercise(_ exercise: TodayExercise) {
        withAnimation(.easeOut(duration: 0.3)) {
            modelContext.delete(exercise)
        }
    }
}

struct TodayExerciseCard: View {
    let exercise: TodayExercise
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showDeleteButton = false

    var body: some View {
        ZStack(alignment: .trailing) {
            // 删除按钮
            if showDeleteButton {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 56)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }

            // 主卡片
            HStack(spacing: 16) {
                Button {
                    onToggle()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(exercise.isCompleted ? Color.green : Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 28, height: 28)

                        if exercise.isCompleted {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 28, height: 28)

                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)

                if let preset = exercise.preset {
                    Text(preset.icon)
                        .font(.system(size: 24))

                    Text(preset.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(exercise.isCompleted ? .secondary : .white)
                        .strikethrough(exercise.isCompleted)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -70)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if value.translation.width < -40 {
                                offset = -70
                                showDeleteButton = true
                            } else {
                                offset = 0
                                showDeleteButton = false
                            }
                        }
                    }
            )
        }
    }
}

// 用于检测滚动偏移的 PreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    FitnessView(selectedTab: .constant(2))
        .modelContainer(for: [ExercisePreset.self, TodayExercise.self, FitnessPlan.self, Item.self], inMemory: true)
}
