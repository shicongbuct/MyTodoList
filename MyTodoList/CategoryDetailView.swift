//
//  CategoryDetailView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//

import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let category: StudyCategory
    var navigationState: NavigationState?

    @Query private var allItems: [Item]
    @State private var showingClearAlert = false
    @State private var editingItem: Item?

    private var categoryItems: [Item] {
        allItems.filter { $0.category?.persistentModelID == category.persistentModelID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var pendingItems: [Item] {
        categoryItems.filter { !$0.isCompleted }
    }

    private var completedItems: [Item] {
        categoryItems.filter { $0.isCompleted }
    }

    private var categoryColor: Color {
        Color(hex: category.colorHex) ?? .blue
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.15, blue: 0.12),
                    Color(red: 0.10, green: 0.18, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                if categoryItems.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if !pendingItems.isEmpty {
                                sectionHeader("待办", count: pendingItems.count)
                                ForEach(pendingItems) { item in
                                    StudyTodoCardView(item: item, categoryColor: categoryColor) {
                                        toggleComplete(item)
                                    } onDelete: {
                                        deleteItem(item)
                                    } onTap: {
                                        editingItem = item
                                    }
                                    .id("\(item.persistentModelID)-pending")
                                }
                            }

                            if !completedItems.isEmpty {
                                completedSectionHeader
                                    .padding(.top, pendingItems.isEmpty ? 0 : 20)
                                ForEach(completedItems) { item in
                                    StudyCompletedCardView(item: item, categoryColor: categoryColor) {
                                        toggleComplete(item)
                                    } onDelete: {
                                        deleteItem(item)
                                    }
                                    .id("\(item.persistentModelID)-completed")
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Text(category.icon)
                        .font(.system(size: 20))
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(item: $editingItem) { item in
            EditTodoView(item: item)
        }
        .onAppear {
            navigationState?.selectedStudyCategory = category
        }
        .onDisappear {
            navigationState?.selectedStudyCategory = nil
        }
        .alert("清空已完成", isPresented: $showingClearAlert) {
            Button("取消", role: .cancel) { }
            Button("清空", role: .destructive) {
                deleteAllCompleted()
            }
        } message: {
            Text("确定要删除所有已完成的任务吗？此操作无法撤销。")
        }
        .preferredColorScheme(.dark)
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                categoryColor.opacity(0.3),
                                categoryColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 15)

                Text(category.icon)
                    .font(.system(size: 48))
            }

            VStack(spacing: 8) {
                Text("暂无任务")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("点击下方 + 按钮添加\(category.name)任务")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))

            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.1))
                )

            Spacer()
        }
        .padding(.top, 8)
    }

    private var completedSectionHeader: some View {
        HStack {
            Text("已完成")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))

            Text("\(completedItems.count)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.1))
                )

            Spacer()

            Button {
                showingClearAlert = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                    Text("清空全部")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.red.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.15))
                )
            }
        }
        .padding(.top, 8)
    }

    private func toggleComplete(_ item: Item) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            item.isCompleted.toggle()
        }
    }

    private func deleteItem(_ item: Item) {
        withAnimation(.easeOut(duration: 0.3)) {
            modelContext.delete(item)
        }
    }

    private func deleteAllCompleted() {
        withAnimation(.easeOut(duration: 0.3)) {
            for item in completedItems {
                modelContext.delete(item)
            }
        }
    }
}

struct StudyTodoCardView: View {
    let item: Item
    let categoryColor: Color
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showDeleteButton = false

    var body: some View {
        ZStack(alignment: .trailing) {
            deleteBackground
                .zIndex(showDeleteButton ? 1 : 0)

            cardContent
                .offset(x: offset)
                .contentShape(Rectangle())
                .onTapGesture {
                    if showDeleteButton {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            offset = 0
                            showDeleteButton = false
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = max(value.translation.width, -80)
                            } else if showDeleteButton {
                                offset = min(0, -80 + value.translation.width)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if value.translation.width < -50 {
                                    offset = -80
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

    private var deleteBackground: some View {
        HStack {
            Spacer()
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red.gradient)
                    )
            }
        }
        .padding(.trailing, 4)
        .opacity(showDeleteButton ? 1 : 0)
    }

    private var cardContent: some View {
        HStack(spacing: 16) {
            Button {
                onToggle()
            } label: {
                Circle()
                    .stroke(categoryColor.opacity(0.6), lineWidth: 2)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    if !item.notes.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 10))
                            Text("备注")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary)
                    }

                    if let dueDate = item.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(dueDate, format: .dateTime.month(.abbreviated).day())
                                .font(.system(size: 11))
                        }
                        .foregroundColor(isOverdue(dueDate) ? .red.opacity(0.8) : .secondary)
                    }

                    priorityBadge
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onToggle()
            }

            Spacer()

            Button {
                onTap()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.5))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.15).opacity(0.9),
                            Color(white: 0.12).opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(categoryColor.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var priorityColor: Color {
        switch item.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }

    private var priorityBadge: some View {
        Text(item.priority.label)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(priorityColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(priorityColor.opacity(0.15))
            )
    }

    private func isOverdue(_ date: Date) -> Bool {
        date < Date()
    }
}

struct StudyCompletedCardView: View {
    let item: Item
    let categoryColor: Color
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button {
                onToggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 28, height: 28)

                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .strikethrough(true, color: .secondary)

                HStack(spacing: 12) {
                    if !item.notes.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 10))
                            Text("备注")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary.opacity(0.7))
                    }

                    if let dueDate = item.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(dueDate, format: .dateTime.month(.abbreviated).day())
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary.opacity(0.7))
                    }
                }
            }

            Spacer()

            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.secondary.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.12).opacity(0.7),
                            Color(white: 0.10).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(0.8)
    }
}

#Preview {
    NavigationStack {
        CategoryDetailView(category: StudyCategory(name: "AI 学习", icon: "🤖", colorHex: "#63B3FF"), navigationState: nil)
    }
    .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
