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
    @State private var showingAddExerciseSheet = false
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
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingAddExerciseSheet) {
            AddExerciseView()
        }
        .preferredColorScheme(.dark)
    }

    private var customTabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabButton(icon: "house.fill", label: "生活", tag: 0)
                tabButton(icon: "book.fill", label: "学习", tag: 1)
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
}

#Preview {
    MainTabView()
        .modelContainer(for: [Item.self, StudyCategory.self, ExercisePreset.self, TodayExercise.self, FitnessPlan.self, IngredientCategory.self, Ingredient.self, MealPlan.self], inMemory: true)
}
