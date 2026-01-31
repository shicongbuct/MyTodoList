//
//  AddExerciseView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExercisePreset.createdAt) private var presets: [ExercisePreset]

    @State private var showingAddPreset = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
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
                    VStack(spacing: 24) {
                        instructionText

                        presetsGrid

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("添加运动")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPreset = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showingAddPreset) {
                AddExercisePresetView()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var instructionText: some View {
        Text("选择运动添加到今日计划")
            .font(.system(size: 15))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var presetsGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(presets) { preset in
                PresetCard(preset: preset) {
                    addExercise(preset: preset)
                } onDelete: {
                    deletePreset(preset)
                }
            }
        }
    }

    private func addExercise(preset: ExercisePreset) {
        let exercise = TodayExercise(preset: preset)
        modelContext.insert(exercise)
        dismiss()
    }

    private func deletePreset(_ preset: ExercisePreset) {
        withAnimation(.easeOut(duration: 0.3)) {
            modelContext.delete(preset)
        }
    }
}

struct PresetCard: View {
    let preset: ExercisePreset
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: 8) {
                Text(preset.icon)
                    .font(.system(size: 32))

                Text(preset.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
}

#Preview {
    AddExerciseView()
        .modelContainer(for: [ExercisePreset.self, TodayExercise.self], inMemory: true)
}
