import Foundation
import SwiftData

/// 全局 SwiftData 容器入口.
///
/// 用法:
/// ```swift
/// @main
/// struct LifeMidpointApp: App {
///     var body: some Scene {
///         WindowGroup { RootView() }
///             .modelContainer(AppDatabase.shared)
///     }
/// }
/// ```
///
/// View 层通过 `@Environment(\.modelContext)` 拿到 context, 然后用 `@Query` 订阅数据.
@MainActor
enum AppDatabase {
    /// 应用范围 ModelContainer. 包含全部 @Model schema.
    static let shared: ModelContainer = makeContainer()

    /// 包含全部模型的 Schema, 供生产/测试共享.
    static let schema = Schema([
        // 用户与设置
        UserProfile.self,
        AppSettings.self,
        // 日记
        DiarySession.self,
        DiaryMessage.self,
        EmotionLog.self,
        // 心境
        MicroEmotionSession.self,
        MicroBehaviorSession.self,
        BreathingSession.self,
        ArticleBookmark.self,
        // 健康
        SleepDay.self,
        HeartRateDay.self,
        SymptomLog.self,
        MenstrualPeriod.self,
        Medication.self,
        MedicationDoseEvent.self,
        // 邮局
        PenPal.self,
        Letter.self,
        UserStamp.self,
    ])

    private static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            // 首次启动播种 demo 数据 (症状目录/演示药品/演示笔友)
            DataSeeder.seedIfNeeded(context: container.mainContext)
            return container
        } catch {
            fatalError("无法初始化 ModelContainer: \(error)")
        }
    }

    // MARK: - 单例式访问 (UserProfile / AppSettings)

    /// 获取或创建唯一的 UserProfile 行.
    /// 全 app 仅有一个用户档案 (无多账号设计).
    static func profile(in ctx: ModelContext) -> UserProfile {
        if let existing = try? ctx.fetch(FetchDescriptor<UserProfile>()).first {
            return existing
        }
        let profile = UserProfile()
        ctx.insert(profile)
        try? ctx.save()
        return profile
    }

    /// 获取或创建唯一的 AppSettings 行.
    static func settings(in ctx: ModelContext) -> AppSettings {
        if let existing = try? ctx.fetch(FetchDescriptor<AppSettings>()).first {
            return existing
        }
        let settings = AppSettings()
        ctx.insert(settings)
        try? ctx.save()
        return settings
    }

    // MARK: - 测试 / Preview 用

    #if DEBUG
    /// In-memory 容器, 用于 SwiftUI Preview 与单元测试.
    static func inMemoryContainer() -> ModelContainer {
        makeContainer(inMemory: true)
    }
    #endif
}
