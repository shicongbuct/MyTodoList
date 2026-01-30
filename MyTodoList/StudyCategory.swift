//
//  StudyCategory.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//

import Foundation
import SwiftData

@Model
final class StudyCategory {
    var name: String
    var icon: String
    var colorHex: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Item.category)
    var items: [Item] = []

    init(name: String, icon: String, colorHex: String, createdAt: Date = Date()) {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = createdAt
    }
}
