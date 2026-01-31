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
            ExercisePreset.self,
            TodayExercise.self,
            FitnessPlan.self,
            IngredientCategory.self,
            Ingredient.self,
            MealPlan.self,
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
                    initializePresetExercises()
                    initializePresetIngredients()
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

    private func initializePresetExercises() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<ExercisePreset>()

        do {
            let existingPresets = try context.fetch(descriptor)
            if existingPresets.isEmpty {
                let presets: [(name: String, icon: String)] = [
                    ("去健身房", "🏋️"),
                    ("跑步5公里", "🏃"),
                    ("10个俯卧撑", "💪"),
                    ("30分钟瑜伽", "🧘"),
                    ("骑行30分钟", "🚴"),
                    ("游泳", "🏊"),
                    ("跳绳10分钟", "🪢"),
                    ("拉伸运动", "🙆")
                ]

                for preset in presets {
                    let exercise = ExercisePreset(
                        name: preset.name,
                        icon: preset.icon,
                        isBuiltIn: true
                    )
                    context.insert(exercise)
                }

                try context.save()
            }
        } catch {
            print("Failed to initialize preset exercises: \(error)")
        }
    }

    private func initializePresetIngredients() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<IngredientCategory>()

        do {
            let existingCategories = try context.fetch(descriptor)
            if existingCategories.isEmpty {
                // 预设分类和食材
                let presets: [(name: String, icon: String, colorHex: String, ingredients: [(name: String, icon: String)])] = [
                    ("肉类", "🥩", "#FF6B6B", [
                        ("猪肉", "🥩"), ("牛肉", "🥩"), ("鸡肉", "🍗"), ("羊肉", "🍖"), ("鱼肉", "🐟"), ("虾", "🦐")
                    ]),
                    ("蔬菜", "🥬", "#6BCB77", [
                        ("白菜", "🥬"), ("西兰花", "🥦"), ("黄瓜", "🥒"), ("番茄", "🍅"), ("胡萝卜", "🥕"), ("土豆", "🥔")
                    ]),
                    ("主食", "🍚", "#FFD93D", [
                        ("米饭", "🍚"), ("馒头", "🫓"), ("面条", "🍜"), ("饼", "🥯"), ("方便面", "🍝")
                    ]),
                    ("水果", "🍎", "#FF9F63", [
                        ("苹果", "🍎"), ("香蕉", "🍌"), ("橙子", "🍊"), ("葡萄", "🍇"), ("草莓", "🍓"), ("西瓜", "🍉")
                    ]),
                    ("零食", "🍪", "#9B59B6", [
                        ("饼干", "🍪"), ("薯片", "🥜"), ("巧克力", "🍫"), ("糖果", "🍬"), ("坚果", "🌰")
                    ])
                ]

                for preset in presets {
                    let category = IngredientCategory(
                        name: preset.name,
                        icon: preset.icon,
                        colorHex: preset.colorHex
                    )
                    context.insert(category)

                    for ingredient in preset.ingredients {
                        let item = Ingredient(
                            name: ingredient.name,
                            icon: ingredient.icon,
                            category: category
                        )
                        context.insert(item)
                    }
                }

                try context.save()
            }
        } catch {
            print("Failed to initialize preset ingredients: \(error)")
        }
    }
}
