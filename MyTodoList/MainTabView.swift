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
            }

            customTabBar

            fabButton
                .offset(y: -12)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingAddSheet) {
            AddTodoView(initialSection: addSection, initialCategory: addCategory)
        }
        .preferredColorScheme(.dark)
    }

    private var customTabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabButton(icon: "house.fill", label: "生活", tag: 0)

                Spacer()
                    .frame(width: 80)

                tabButton(icon: "book.fill", label: "学习", tag: 1)
            }
            .padding(.horizontal, 40)
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
        let activeColor = tag == 0 ? Color.cyan : Color.purple

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
            if let category = navigationState.selectedStudyCategory {
                // 在学习分类详情页
                addSection = .study
                addCategory = category
            } else if selectedTab == 1 {
                // 在学习主页
                addSection = .study
                addCategory = nil
            } else {
                // 在生活页
                addSection = .life
                addCategory = nil
            }
            showingAddSheet = true
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
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
