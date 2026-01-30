//
//  AddTodoView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//

import SwiftUI
import SwiftData

struct AddTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \StudyCategory.createdAt) private var categories: [StudyCategory]

    var initialSection: Section = .life
    var initialCategory: StudyCategory?

    @State private var title = ""
    @State private var notes = ""
    @State private var priority: Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var selectedSection: Section = .life
    @State private var selectedCategory: StudyCategory?

    @FocusState private var titleFocused: Bool

    private var canAdd: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespaces).isEmpty
        if selectedSection == .study {
            return hasTitle && selectedCategory != nil
        }
        return hasTitle
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
                    VStack(spacing: 24) {
                        sectionPickerSection
                        if selectedSection == .study {
                            categorySection
                        }
                        titleSection
                        notesSection
                        prioritySection
                        dueDateSection

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("新建任务")
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
                        addTask()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .disabled(!canAdd)
                }
            }
            .onAppear {
                selectedSection = initialSection
                selectedCategory = initialCategory
                titleFocused = true
            }
        }
        .preferredColorScheme(.dark)
    }

    private var sectionPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("分区")

            HStack(spacing: 12) {
                sectionButton(section: .life, icon: "house.fill", label: "生活")
                sectionButton(section: .study, icon: "book.fill", label: "学习")
            }
        }
    }

    private func sectionButton(section: Section, icon: String, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedSection = section
                if section == .life {
                    selectedCategory = nil
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(selectedSection == section ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedSection == section ? Color.purple.opacity(0.3) : Color(white: 0.15).opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedSection == section ? Color.purple.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionLabel("学习分类")
                if selectedCategory == nil {
                    Text("(必选)")
                        .font(.system(size: 11))
                        .foregroundColor(.red.opacity(0.8))
                }
            }

            if categories.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("暂无分类，请先创建学习分类")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(inputBackground)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories) { category in
                            categoryChip(category)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }

    private func categoryChip(_ category: StudyCategory) -> some View {
        let isSelected = selectedCategory?.persistentModelID == category.persistentModelID
        let color = Color(hex: category.colorHex) ?? .blue

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                Text(category.icon)
                    .font(.system(size: 16))
                Text(category.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.3) : Color(white: 0.15).opacity(0.9))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? color.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("标题")

            TextField("需要做什么？", text: $title)
                .font(.system(size: 17))
                .padding(16)
                .background(inputBackground)
                .focused($titleFocused)
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("备注")

            TextField("添加详情...", text: $notes, axis: .vertical)
                .font(.system(size: 16))
                .lineLimit(3...6)
                .padding(16)
                .background(inputBackground)
        }
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("优先级")

            HStack(spacing: 12) {
                ForEach(Priority.allCases, id: \.self) { p in
                    PriorityButton(
                        priority: p,
                        isSelected: priority == p
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            priority = p
                        }
                    }
                }
            }
        }
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("截止日期")

            VStack(spacing: 16) {
                Toggle(isOn: $hasDueDate.animation(.spring(response: 0.3))) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: hasDueDate
                                            ? [.purple.opacity(0.3), .blue.opacity(0.3)]
                                            : [.white.opacity(0.1), .white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)

                            Image(systemName: "calendar")
                                .font(.system(size: 16))
                                .foregroundColor(hasDueDate ? .purple : .secondary)
                        }

                        Text("设置截止日期")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
                .tint(.purple)
                .padding(16)
                .background(inputBackground)

                if hasDueDate {
                    DatePicker(
                        "截止日期",
                        selection: $dueDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .tint(.purple)
                    .padding(16)
                    .background(inputBackground)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
                }
            }
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

    private func addTask() {
        let newItem = Item(
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces),
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority,
            section: selectedSection,
            category: selectedCategory
        )
        modelContext.insert(newItem)
        dismiss()
    }
}

struct PriorityButton: View {
    let priority: Priority
    let isSelected: Bool
    let action: () -> Void

    private var color: Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }

    private var icon: String {
        switch priority {
        case .high: return "exclamationmark.2"
        case .medium: return "exclamationmark"
        case .low: return "minus"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? color.opacity(0.2)
                                : Color.white.opacity(0.05)
                        )
                        .frame(width: 44, height: 44)

                    if isSelected {
                        Circle()
                            .stroke(color, lineWidth: 2)
                            .frame(width: 44, height: 44)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? color : .secondary)
                }

                Text(priority.label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(white: 0.15).opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected ? color.opacity(0.5) : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddTodoView()
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}

#Preview("Study Section") {
    AddTodoView(initialSection: .study)
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
