//
//  AddExercisePresetView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import SwiftUI
import SwiftData

struct AddExercisePresetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedIcon: String = ""

    @FocusState private var nameFocused: Bool

    private let presetIcons: [String] = [
        "🏋️", "🏃", "💪", "🧘", "🚴", "🏊", "🪢", "🙆",
        "⚽️", "🏀", "🎾", "🏓", "🏸", "⛳️", "🥊", "🤸",
        "🚶", "🧗", "🏇", "⛷️", "🛹", "🏄", "🚣", "🤾"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.08, blue: 0.05),
                        Color(red: 0.08, green: 0.12, blue: 0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        previewSection
                        nameSection
                        iconSection

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("添加运动预设")
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
                        savePreset()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || selectedIcon.isEmpty)
                }
            }
            .onAppear {
                nameFocused = true
            }
        }
        .preferredColorScheme(.dark)
    }

    private var previewSection: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.3),
                                Color.green.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                    .frame(height: 100)

                VStack(spacing: 8) {
                    Text(selectedIcon.isEmpty ? "🏃" : selectedIcon)
                        .font(.system(size: 36))

                    Text(name.isEmpty ? "运动名称" : name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(name.isEmpty ? .secondary : .white)
                }
            }

            Text("预览")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("名称")

            TextField("输入运动名称", text: $name)
                .font(.system(size: 17))
                .padding(16)
                .background(inputBackground)
                .focused($nameFocused)
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("图标")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 8), spacing: 12) {
                ForEach(presetIcons, id: \.self) { emoji in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIcon = emoji
                        }
                    } label: {
                        Text(emoji)
                            .font(.system(size: 24))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedIcon == emoji ? Color.green.opacity(0.3) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedIcon == emoji ? Color.green.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(inputBackground)
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

    private func savePreset() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        let newPreset = ExercisePreset(
            name: trimmedName,
            icon: selectedIcon,
            isBuiltIn: false
        )
        modelContext.insert(newPreset)

        dismiss()
    }
}

#Preview {
    AddExercisePresetView()
        .modelContainer(for: [ExercisePreset.self], inMemory: true)
}
