//
//  CookModels.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import Foundation
import SwiftUI
import SwiftData

// 食材分类
@Model
final class IngredientCategory {
    var name: String
    var icon: String
    var colorHex: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Ingredient.category)
    var ingredients: [Ingredient]?

    init(name: String, icon: String, colorHex: String, createdAt: Date = Date()) {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = createdAt
    }

    var color: Color {
        Color(hex: colorHex) ?? .orange
    }
}

// 食材项
@Model
final class Ingredient {
    var name: String
    var icon: String
    var category: IngredientCategory?
    var createdAt: Date

    init(name: String, icon: String, category: IngredientCategory? = nil, createdAt: Date = Date()) {
        self.name = name
        self.icon = icon
        self.category = category
        self.createdAt = createdAt
    }
}

// 餐次类型
enum MealType: Int, Codable, CaseIterable {
    case breakfast = 0
    case lunch = 1
    case dinner = 2

    var name: String {
        switch self {
        case .breakfast: return "早餐"
        case .lunch: return "中餐"
        case .dinner: return "晚餐"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch: return "☀️"
        case .dinner: return "🌙"
        }
    }
}

// 饮食计划
@Model
final class MealPlan {
    var date: Date
    var mealTypeRaw: Int
    var content: String
    var updatedAt: Date

    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .breakfast }
        set { mealTypeRaw = newValue.rawValue }
    }

    init(date: Date, mealType: MealType, content: String = "", updatedAt: Date = Date()) {
        self.date = Calendar.current.startOfDay(for: date)
        self.mealTypeRaw = mealType.rawValue
        self.content = content
        self.updatedAt = updatedAt
    }
}
