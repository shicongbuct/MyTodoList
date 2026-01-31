//
//  MainTabView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//

import SwiftUI
import SwiftData

@Observable
class NavigationState {
    var selectedStudyCategory: StudyCategory?
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingAddSheet = false
    @State private var showingAddExerciseSheet = false
    @State private var addSection: Section = .life
    @State private var addCategory: StudyCategory?
    @State private var navigationState = NavigationState()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ContentView()
                    .tag(0)

                StudyView()
                    .environment(navigationState)
                    .tag(1)

                FitnessView(selectedTab: $selectedTab)
                    .tag(2)

                CookView()
                    .tag(3)
            }

            customTabBar

            fabButton
                .offset(y: -12)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingAddSheet) {
            AddTodoView(initialSection: addSection, initialCategory: addCategory)
        }
        .sheet(isPresented: $showingAddExerciseSheet) {
            AddExerciseView()
        }
        .preferredColorScheme(.dark)
    }

    private var customTabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // 左侧两个 tab
                tabButton(icon: "house.fill", label: "生活", tag: 0)
                tabButton(icon: "book.fill", label: "学习", tag: 1)

                // 中间 FAB 占位
                Spacer()
                    .frame(width: 72)

                // 右侧两个 tab
                tabButton(icon: "figure.run", label: "健身", tag: 2)
                tabButton(icon: "fork.knife", label: "Cook", tag: 3)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .background(
            Rectangle()
                .fill(
                    Color(red: 0.06, green: 0.06, blue: 0.10)
                )
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 0.5),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(icon: String, label: String, tag: Int) -> some View {
        let isSelected = selectedTab == tag
        let activeColor: Color = {
            switch tag {
            case 0: return .cyan
            case 1: return .purple
            case 2: return .green
            case 3: return .orange
            default: return .blue
            }
        }()

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(activeColor.opacity(0.2))
                            .frame(width: 44, height: 44)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
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

                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? activeColor : .secondary.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var fabButton: some View {
        Button {
            if selectedTab == 2 {
                // 健身 tab: 弹出添加运动
                showingAddExerciseSheet = true
            } else if let category = navigationState.selectedStudyCategory {
                // 在学习分类详情页
                addSection = .study
                addCategory = category
                showingAddSheet = true
            } else if selectedTab == 1 {
                // 在学习主页
                addSection = .study
                addCategory = nil
                showingAddSheet = true
            } else if selectedTab == 0 {
                // 在生活页
                addSection = .life
                addCategory = nil
                showingAddSheet = true
            }
            // Cook tab (3) 不响应 FAB
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.35, blue: 1.0),
                                Color(red: 0.40, green: 0.25, blue: 0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.purple.opacity(0.5), radius: 15, x: 0, y: 8)

                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Item.self, StudyCategory.self, ExercisePreset.self, TodayExercise.self, FitnessPlan.self, IngredientCategory.self, Ingredient.self, MealPlan.self], inMemory: true)
}
