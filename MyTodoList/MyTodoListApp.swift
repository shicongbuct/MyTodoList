//
//  MyTodoListApp.swift
//  MyTodoList
//
//  Created by miles on 2026/1/30.
//
//  文件说明：
//  本文件是应用程序的入口点，负责：
//  - 配置 SwiftData 数据容器（ModelContainer）
//  - 设置应用的根视图（MainTabView）
//  - 初始化预设的学习分类数据
//

import SwiftUI
import SwiftData

// MARK: - 应用入口
/// MyTodoList 应用的主入口结构体
/// 使用 @main 标记为应用程序的入口点
/// 遵循 App 协议，定义应用的场景和数据容器配置
@main
struct MyTodoListApp: App {
    
    // MARK: 数据容器配置
    
    /// 共享的 SwiftData 模型容器
    /// 使用闭包进行延迟初始化，确保只创建一次
    /// 负责管理应用的数据持久化
    var sharedModelContainer: ModelContainer = {
        // 定义数据模式，包含所有需要持久化的模型类型
        let schema = Schema([
            Item.self,           // 待办任务模型
            StudyCategory.self,  // 学习分类模型
        ])
        
        // 创建模型配置
        // isStoredInMemoryOnly: false 表示数据持久化到磁盘
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        // 尝试创建模型容器
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // 如果创建失败，终止应用并输出错误信息
            // 这通常表示数据模型有严重问题
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: 应用场景
    
    /// 定义应用的主场景
    /// WindowGroup 创建一个支持多窗口的场景（在支持的平台上）
    var body: some Scene {
        WindowGroup {
            // 设置 MainTabView 作为应用的根视图
            MainTabView()
                .onAppear {
                    // 应用启动时初始化预设分类
                    initializePresetCategories()
                }
        }
        // 将模型容器注入到环境中
        // 所有子视图都可以通过 @Environment(\.modelContext) 访问数据上下文
        .modelContainer(sharedModelContainer)
    }

    // MARK: 私有方法
    
    /// 初始化预设的学习分类
    /// 在应用首次启动时创建默认的学习分类
    /// 如果已存在分类数据，则不执行任何操作
    private func initializePresetCategories() {
        // 获取主上下文用于数据操作
        let context = sharedModelContainer.mainContext
        
        // 创建查询描述符，用于检查是否已有分类数据
        let descriptor = FetchDescriptor<StudyCategory>()

        do {
            // 查询现有的学习分类
            let existingCategories = try context.fetch(descriptor)
            
            // 只有在没有任何分类时才创建预设分类
            if existingCategories.isEmpty {
                // 定义预设分类的数据
                // 每个元组包含：(名称, 图标emoji, 主题颜色)
                let presets: [(name: String, icon: String, colorHex: String)] = [
                    ("AI 学习", "🤖", "#63B3FF"),        // 人工智能学习 - 蓝色
                    ("产品学习", "💡", "#FF9F63"),       // 产品知识学习 - 橙色
                    ("Python/大模型", "🐍", "#63FFB3"), // Python 和大模型 - 绿色
                    ("文学阅读", "📖", "#FF63B3")        // 文学阅读 - 粉色
                ]

                // 遍历预设数据，创建并插入分类对象
                for preset in presets {
                    let category = StudyCategory(
                        name: preset.name,
                        icon: preset.icon,
                        colorHex: preset.colorHex
                    )
                    context.insert(category)
                }

                // 保存更改到持久化存储
                try context.save()
            }
        } catch {
            // 如果初始化失败，打印错误信息
            // 这不是致命错误，应用仍可正常运行，用户可手动创建分类
            print("Failed to initialize preset categories: \(error)")
        }
    }
}
