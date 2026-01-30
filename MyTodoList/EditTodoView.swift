//
//  EditTodoView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//

import SwiftUI
import SwiftData

struct EditTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item

    @State private var title: String
    @State private var notes: String
    @State private var priority: Priority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date

    init(item: Item) {
        self.item = item
        _title = State(initialValue: item.title)
        _notes = State(initialValue: item.notes)
        _priority = State(initialValue: item.priority)
        _hasDueDate = State(initialValue: item.dueDate != nil)
        _dueDate = State(initialValue: item.dueDate ?? Date())
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
                        titleSection
                        notesSection
                        prioritySection
                        dueDateSection

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("编辑任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTask()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("标题")

            TextField("需要做什么？", text: $title)
                .font(.system(size: 17))
                .padding(16)
                .background(inputBackground)
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

    private func saveTask() {
        item.title = title.trimmingCharacters(in: .whitespaces)
        item.notes = notes.trimmingCharacters(in: .whitespaces)
        item.priority = priority
        item.dueDate = hasDueDate ? dueDate : nil
        dismiss()
    }
}

#Preview {
    EditTodoView(item: Item(title: "测试任务", notes: "这是备注", priority: .high))
        .modelContainer(for: Item.self, inMemory: true)
}
