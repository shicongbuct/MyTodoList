//
//  StudyCategory.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//
//  文件说明：
//  本文件定义了学习分类的数据模型
//  学习分类用于组织和分组"学习"分区中的待办任务
//  每个分类有自己的名称、图标（emoji）和主题颜色
//

import Foundation
import SwiftData

// MARK: - StudyCategory 数据模型
/// 学习分类数据模型
/// 使用 @Model 宏标记为 SwiftData 模型类，自动获得持久化能力
/// 用于组织学习分区中的待办任务，支持自定义名称、图标和颜色
@Model
final class StudyCategory {
    // MARK: 基本属性
    
    /// 分类名称 - 学习分类的显示名称
    /// 例如："AI 学习"、"Python/大模型"、"文学阅读"等
    var name: String
    
    /// 分类图标 - 使用 emoji 作为分类的视觉标识
    /// 例如："🤖"、"🐍"、"📖"等
    var icon: String
    
    /// 主题颜色 - 分类的主题颜色，使用十六进制颜色代码表示
    /// 格式：#RRGGBB，例如："#63B3FF"（蓝色）
    /// 用于分类卡片的背景渐变和边框颜色
    var colorHex: String
    
    /// 创建时间 - 分类的创建日期时间
    /// 用于分类列表的排序
    var createdAt: Date

    // MARK: 关联关系
    
    /// 关联的任务列表
    /// 使用 @Relationship 宏定义与 Item 的一对多关系
    /// - deleteRule: .cascade 表示删除分类时，自动删除该分类下的所有任务
    /// - inverse: \Item.category 指定反向关系属性
    /// 默认为空数组
    @Relationship(deleteRule: .cascade, inverse: \Item.category)
    var items: [Item] = []

    // MARK: 初始化方法
    
    /// 创建新的学习分类
    /// - Parameters:
    ///   - name: 分类名称（必填）
    ///   - icon: 分类图标 emoji（必填）
    ///   - colorHex: 主题颜色的十六进制代码（必填）
    ///   - createdAt: 创建时间，默认为当前时间
    init(name: String, icon: String, colorHex: String, createdAt: Date = Date()) {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = createdAt
    }
}
