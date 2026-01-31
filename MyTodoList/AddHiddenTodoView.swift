//
//  AddHiddenTodoView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import SwiftUI
import SwiftData

struct AddHiddenTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var notes = ""
    @State private var priority: Priority = .medium

    var body: some View {
        NavigationStack {
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

                ScrollView {
                    VStack(spacing: 24) {
                        // 标题
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标题")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)

                            TextField("输入事项标题", text: $title)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                )
                        }

                        // 备注
                        VStack(alignment: .leading, spacing: 8) {
                            Text("备注")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)

                            TextEditor(text: $notes)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                )
                        }

                        // 优先级
                        VStack(alignment: .leading, spacing: 8) {
                            Text("优先级")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                ForEach(Priority.allCases, id: \.rawValue) { p in
                                    Button {
                                        priority = p
                                    } label: {
                                        Text(p.label)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(priority == p ? .white : .secondary)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(priority == p ? priorityColor(p) : Color.white.opacity(0.08))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("添加事项")
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
                        addItem()
                    }
                    .foregroundColor(.purple)
                    .disabled(title.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func priorityColor(_ p: Priority) -> Color {
        switch p {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }

    private func addItem() {
        let item = Item(
            title: title,
            notes: notes,
            priority: priority,
            section: .hidden
        )
        modelContext.insert(item)
        dismiss()
    }
}

struct EditHiddenTodoView: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var item: Item

    var body: some View {
        NavigationStack {
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

                ScrollView {
                    VStack(spacing: 24) {
                        // 标题
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标题")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)

                            TextField("输入事项标题", text: $item.title)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                )
                        }

                        // 备注
                        VStack(alignment: .leading, spacing: 8) {
                            Text("备注")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)

                            TextEditor(text: $item.notes)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                )
                        }

                        // 优先级
                        VStack(alignment: .leading, spacing: 8) {
                            Text("优先级")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                ForEach(Priority.allCases, id: \.rawValue) { p in
                                    Button {
                                        item.priority = p
                                    } label: {
                                        Text(p.label)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(item.priority == p ? .white : .secondary)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(item.priority == p ? priorityColor(p) : Color.white.opacity(0.08))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("编辑事项")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func priorityColor(_ p: Priority) -> Color {
        switch p {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    AddHiddenTodoView()
        .modelContainer(for: [Item.self, StudyCategory.self], inMemory: true)
}
