//
//  Item.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//
//  文件说明：
//  本文件定义了待办事项应用的核心数据模型，包括：
//  - Priority 枚举：任务的优先级（低、中、高）
//  - Section 枚举：任务所属分区（生活、学习）
//  - Item 类：待办任务的数据模型，使用 SwiftData 进行持久化存储
//

import Foundation
import SwiftData

// MARK: - Priority 枚举
/// 任务优先级枚举
/// 用于表示待办任务的紧急程度，分为三个等级
/// - 遵循 Int 类型以便于 SwiftData 存储
/// - 遵循 Codable 协议支持编解码
/// - 遵循 CaseIterable 协议支持遍历所有优先级选项
enum Priority: Int, Codable, CaseIterable {
    /// 低优先级 - 不紧急的任务
    case low = 0
    /// 中优先级 - 一般任务（默认）
    case medium = 1
    /// 高优先级 - 紧急任务
    case high = 2

    /// 优先级的显示标签
    /// 返回对应优先级的中文名称，用于界面展示
    var label: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }

    /// 优先级对应的颜色资源名称
    /// 返回在 Assets.xcassets 中定义的颜色名称
    /// - 低优先级：蓝色调
    /// - 中优先级：橙色调
    /// - 高优先级：红色调
    var color: String {
        switch self {
        case .low: return "priorityLow"
        case .medium: return "priorityMedium"
        case .high: return "priorityHigh"
        }
    }
}

// MARK: - Section 枚举
/// 任务分区枚举
/// 用于区分任务属于"生活"还是"学习"分区
/// - 遵循 Int 类型以便于 SwiftData 存储
/// - 遵循 Codable 协议支持编解码
enum Section: Int, Codable {
    /// 生活分区 - 日常生活相关的任务
    case life = 0
    /// 学习分区 - 学习相关的任务，可关联具体的学习分类
    case study = 1
}

// MARK: - Item 数据模型
/// 待办任务数据模型
/// 使用 @Model 宏标记为 SwiftData 模型类，自动获得持久化能力
/// 存储单个待办任务的所有相关信息
@Model
final class Item {
    // MARK: 基本属性
    
    /// 任务标题 - 任务的主要描述文字
    var title: String
    
    /// 任务备注 - 任务的补充说明信息
    var notes: String
    
    /// 完成状态 - 标记任务是否已完成
    var isCompleted: Bool
    
    /// 创建时间 - 任务的创建日期时间
    var createdAt: Date
    
    /// 截止日期 - 任务的截止日期（可选）
    /// nil 表示没有设置截止日期
    var dueDate: Date?
    
    // MARK: 存储属性（用于 SwiftData 持久化）
    
    /// 优先级原始值 - 存储 Priority 枚举的 rawValue
    /// 使用 Int 类型便于 SwiftData 存储
    var priorityRaw: Int
    
    /// 分区原始值 - 存储 Section 枚举的 rawValue
    /// 默认值为 0（生活分区）
    var sectionRaw: Int = 0
    
    /// 关联的学习分类 - 仅当任务属于学习分区时有效
    /// 与 StudyCategory 建立可选的关联关系
    var category: StudyCategory?

    // MARK: 计算属性
    
    /// 任务优先级
    /// 提供类型安全的方式访问和修改优先级
    /// - get: 将 priorityRaw 转换为 Priority 枚举，默认返回 .medium
    /// - set: 将 Priority 枚举的 rawValue 存储到 priorityRaw
    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    /// 任务所属分区
    /// 提供类型安全的方式访问和修改分区
    /// - get: 将 sectionRaw 转换为 Section 枚举，默认返回 .life
    /// - set: 将 Section 枚举的 rawValue 存储到 sectionRaw
    var section: Section {
        get { Section(rawValue: sectionRaw) ?? .life }
        set { sectionRaw = newValue.rawValue }
    }

    // MARK: 初始化方法
    
    /// 创建新的待办任务
    /// - Parameters:
    ///   - title: 任务标题（必填）
    ///   - notes: 任务备注，默认为空字符串
    ///   - isCompleted: 完成状态，默认为 false（未完成）
    ///   - createdAt: 创建时间，默认为当前时间
    ///   - dueDate: 截止日期，默认为 nil（无截止日期）
    ///   - priority: 优先级，默认为 .medium（中优先级）
    ///   - section: 所属分区，默认为 .life（生活分区）
    ///   - category: 关联的学习分类，默认为 nil
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
