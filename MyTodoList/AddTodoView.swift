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

    @State private var title = ""
    @State private var notes = ""
    @State private var priority: Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()

    @FocusState private var titleFocused: Bool

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
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                titleFocused = true
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
            priority: priority
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
        .modelContainer(for: Item.self, inMemory: true)
}
