//
//  HiddenTodoView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import SwiftUI
import SwiftData

struct HiddenTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Item> { $0.sectionRaw == 2 },
        sort: \Item.sortOrder
    ) private var items: [Item]

    let onExit: () -> Void

    @State private var showingAddSheet = false
    @State private var showingClearAlert = false
    @State private var editingItem: Item?
    @State private var isEditMode = false

    private var pendingItems: [Item] {
        items.filter { !$0.isCompleted }
    }

    private var completedItems: [Item] {
        items.filter { $0.isCompleted }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.08, blue: 0.12),
                    Color(red: 0.12, green: 0.10, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                if items.isEmpty {
                    emptyStateView
                } else {
                    List {
                        if !pendingItems.isEmpty {
                            SwiftUI.Section {
                                ForEach(pendingItems) { item in
                                    HiddenTodoCardView(
                                        item: item,
                                        isEditMode: isEditMode,
                                        onToggle: { toggleComplete(item) },
                                        onDelete: { deleteItem(item) },
                                        onTap: { editingItem = item }
                                    )
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                }
                                .onMove(perform: movePendingItems)
                            } header: {
                                sectionHeader("待办", count: pendingItems.count)
                                    .listRowInsets(EdgeInsets())
                            }
                        }

                        if !completedItems.isEmpty {
                            SwiftUI.Section {
                                ForEach(completedItems) { item in
                                    HiddenCompletedCardView(item: item) {
                                        toggleComplete(item)
                                    } onDelete: {
                                        deleteItem(item)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                }
                            } header: {
                                completedSectionHeader
                                    .listRowInsets(EdgeInsets())
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .contentMargins(.bottom, 120, for: .scrollContent)
                    .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
                }
            }
            .frame(maxHeight: .infinity)

            // 浮动添加按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingAddSheet = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.purple,
                                            Color.purple.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)

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
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingAddSheet) {
            AddHiddenTodoView()
        }
        .sheet(item: $editingItem) { item in
            EditHiddenTodoView(item: item)
        }
        .alert("清空已完成", isPresented: $showingClearAlert) {
            Button("取消", role: .cancel) { }
            Button("清空", role: .destructive) {
                deleteAllCompleted()
            }
        } message: {
            Text("确定要删除所有已完成的事项吗？")
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(Date(), format: .dateTime.weekday(.wide).month().day())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Text("事项")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(white: 0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            Spacer()

            // 编辑/完成按钮
            if !pendingItems.isEmpty {
                Button {
                    withAnimation {
                        isEditMode.toggle()
                    }
                } label: {
                    Text(isEditMode ? "完成" : "排序")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isEditMode ? .purple : .white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isEditMode ? Color.purple.opacity(0.2) : Color.white.opacity(0.1))
                        )
                }
            }

            Button {
                onExit()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14, weight: .medium))
                    Text("返回")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.3),
                                Color.pink.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Image(systemName: "eye.slash")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("暂无事项")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("点击 + 添加隐藏事项")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
        .padding(.horizontal, 20)
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
                    Text("清空")
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
        .padding(.horizontal, 20)
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

    private func movePendingItems(from source: IndexSet, to destination: Int) {
        var pending = pendingItems
        pending.move(fromOffsets: source, toOffset: destination)

        // 更新所有项目的排序顺序
        for (index, item) in pending.enumerated() {
            item.sortOrder = index
        }
    }
}

// 隐藏事项卡片
struct HiddenTodoCardView: View {
    let item: Item
    var isEditMode: Bool = false
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showDeleteButton = false

    var body: some View {
        ZStack(alignment: .trailing) {
            if showDeleteButton && !isEditMode {
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
            }

            HStack(spacing: 16) {
                // 左边圆圈：点击完成事项
                Button {
                    onToggle()
                } label: {
                    Circle()
                        .stroke(Color.purple.opacity(0.6), lineWidth: 2)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .disabled(isEditMode)

                // 中间标题区域
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)

                    if !item.notes.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 10))
                            Text("备注")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 右边箭头：点击编辑
                if !isEditMode {
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
                            .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                    )
            )
            .offset(x: isEditMode ? 0 : offset)
            .gesture(
                isEditMode ? nil :
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { value in
                        let horizontalAmount = abs(value.translation.width)
                        let verticalAmount = abs(value.translation.height)
                        guard horizontalAmount > verticalAmount else { return }

                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -80)
                        } else if showDeleteButton {
                            offset = min(0, -80 + value.translation.width)
                        }
                    }
                    .onEnded { value in
                        let horizontalAmount = abs(value.translation.width)
                        let verticalAmount = abs(value.translation.height)

                        if verticalAmount > horizontalAmount {
                            return
                        }

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
}

struct HiddenCompletedCardView: View {
    let item: Item
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button {
                onToggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.8))
                        .frame(width: 28, height: 28)

                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .strikethrough(true, color: .secondary)

            Spacer()

            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.12).opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(0.8)
    }
}

#Preview {
    HiddenTodoView(onExit: {})
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
