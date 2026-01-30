//
//  MyTodoListApp.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//

import SwiftUI
import SwiftData

@main
struct MyTodoListApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            StudyCategory.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    initializePresetCategories()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func initializePresetCategories() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<StudyCategory>()

        do {
            let existingCategories = try context.fetch(descriptor)
            if existingCategories.isEmpty {
                let presets: [(name: String, icon: String, colorHex: String)] = [
                    ("AI 学习", "🤖", "#63B3FF"),
                    ("产品学习", "💡", "#FF9F63"),
                    ("Python/大模型", "🐍", "#63FFB3"),
                    ("文学阅读", "📖", "#FF63B3")
                ]

                for preset in presets {
                    let category = StudyCategory(
                        name: preset.name,
                        icon: preset.icon,
                        colorHex: preset.colorHex
                    )
                    context.insert(category)
                }

                try context.save()
            }
        } catch {
            print("Failed to initialize preset categories: \(error)")
        }
    }
}
