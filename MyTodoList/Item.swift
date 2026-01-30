//
//  Item.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//

import Foundation
import SwiftData

enum Priority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2

    var label: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }

    var color: String {
        switch self {
        case .low: return "priorityLow"
        case .medium: return "priorityMedium"
        case .high: return "priorityHigh"
        }
    }
}

enum Section: Int, Codable {
    case life = 0
    case study = 1
}

@Model
final class Item {
    var title: String
    var notes: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var priorityRaw: Int
    var sectionRaw: Int = 0
    var category: StudyCategory?

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var section: Section {
        get { Section(rawValue: sectionRaw) ?? .life }
        set { sectionRaw = newValue.rawValue }
    }

    init(
        title: String,
        notes: String = "",
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        dueDate: Date? = nil,
        priority: Priority = .medium,
        section: Section = .life,
        category: StudyCategory? = nil
    ) {
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.priorityRaw = priority.rawValue
        self.sectionRaw = section.rawValue
        self.category = category
    }
}
