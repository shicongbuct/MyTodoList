//
//  FitnessModels.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import Foundation
import SwiftData

// 运动预设选项
@Model
final class ExercisePreset {
    var name: String
    var icon: String
    var isBuiltIn: Bool
    var createdAt: Date

    init(name: String, icon: String, isBuiltIn: Bool = false, createdAt: Date = Date()) {
        self.name = name
        self.icon = icon
        self.isBuiltIn = isBuiltIn
        self.createdAt = createdAt
    }
}

// 今日运动计划条目
@Model
final class TodayExercise {
    var preset: ExercisePreset?
    var isCompleted: Bool
    var date: Date
    var createdAt: Date

    init(preset: ExercisePreset? = nil, isCompleted: Bool = false, date: Date = Date(), createdAt: Date = Date()) {
        self.preset = preset
        self.isCompleted = isCompleted
        self.date = Calendar.current.startOfDay(for: date)
        self.createdAt = createdAt
    }
}

enum FitnessPlanType: Int, Codable {
    case weekly = 0
    case monthly = 1
}

// 周/月计划
@Model
final class FitnessPlan {
    var content: String
    var planTypeRaw: Int
    var startDate: Date
    var updatedAt: Date

    var planType: FitnessPlanType {
        get { FitnessPlanType(rawValue: planTypeRaw) ?? .weekly }
        set { planTypeRaw = newValue.rawValue }
    }

    init(content: String = "", planType: FitnessPlanType, startDate: Date, updatedAt: Date = Date()) {
        self.content = content
        self.planTypeRaw = planType.rawValue
        self.startDate = startDate
        self.updatedAt = updatedAt
    }
}
