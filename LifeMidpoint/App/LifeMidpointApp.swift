import SwiftUI
import SwiftData

@main
struct LifeMidpointApp: App {
    @StateObject private var appState = AppStateManager()

    init() {
        resetEphemeralDiaryHistory()
        runDebugDataHooks()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
        // SwiftData 容器: 全 app 共享, 通过 @Environment(\.modelContext) 在 view 中注入.
        // 首次启动时由 AppDatabase 自动播种 demo 数据 (症状/药品/笔友).
        .modelContainer(AppDatabase.shared)
    }

    /// 启动时执行的 debug 数据写入钩子, 用于自动化验证持久化.
    /// 通过环境变量触发, 无需手动 UI 操作:
    ///   - DEBUG_INSERT_SYMPTOM=<name>  插入一条带名症状 (icon=checkmark.seal, severity=2)
    ///   - DEBUG_INSERT_LETTER=<text>   寄出一封 marker 信件
    ///   - DEBUG_INSERT_DIARY_ENTRY=1   插入一条 marker 日记总结
    ///   - DEBUG_SET_NOISE=<mode>       覆盖 AppSettings.whiteNoiseMode
    ///   - DEBUG_PRINT_DB=1             打印各表当前条目数, 便于跨重启对比
    @MainActor
    private func resetEphemeralDiaryHistory() {
        let ctx = AppDatabase.shared.mainContext
        DiaryRepository(context: ctx).deleteAllConversationHistory()
    }

    @MainActor
    private func runDebugDataHooks() {
        #if DEBUG
        let ctx = AppDatabase.shared.mainContext
        let env = ProcessInfo.processInfo.environment

        if let name = env["DEBUG_INSERT_SYMPTOM"], !name.isEmpty {
            ctx.insert(SymptomLog(name: name, iconSystemName: "checkmark.seal", severity: 2))
            try? ctx.save()
            print("🧪 DEBUG: inserted SymptomLog name=\(name)")
        }

        if let body = env["DEBUG_INSERT_LETTER"], !body.isEmpty {
            PostOfficeRepository(context: ctx).send(
                body: body, recipientMode: "self",
                moodTag: "测试", alias: "测试者",
                awardStampDefinitionId: "gold_1"
            )
            print("🧪 DEBUG: inserted Letter body=\(body)")
        }

        if env["DEBUG_INSERT_DIARY_ENTRY"] != nil {
            DiaryRepository(context: ctx).createEntry(
                title: "疲惫但平静的晴天",
                body: "下午在公园散步，让我的思绪慢慢沉下来。我开始留意生活中那些安静的细节，比如树叶轻轻晃动的样子。只是偶尔还是会有一种被困住的感觉，也隐隐察觉到自己的体力不如从前了。",
                summaryText: "4月29日 疲惫但平静的晴天\n\n下午在公园散步，让我的思绪慢慢沉下来。我开始留意生活中那些安静的细节，比如树叶轻轻晃动的样子。"
            )
            print("🧪 DEBUG: inserted DiaryEntry")
        }

        if let noise = env["DEBUG_SET_NOISE"], !noise.isEmpty {
            UserRepository(context: ctx).updateWhiteNoise(noise)
            print("🧪 DEBUG: set whiteNoiseMode=\(noise)")
        }

        if env["DEBUG_PRINT_DB"] != nil {
            printDBSummary(ctx)
        }
        #endif
    }

    #if DEBUG
    @MainActor
    private func printDBSummary(_ ctx: ModelContext) {
        func count<T: PersistentModel>(_ t: T.Type) -> Int {
            (try? ctx.fetchCount(FetchDescriptor<T>())) ?? -1
        }
        print("📊 DB Summary:")
        print("  UserProfile:        \(count(UserProfile.self))")
        print("  AppSettings:        \(count(AppSettings.self))")
        print("  DiarySession:       \(count(DiarySession.self))")
        print("  DiaryEntry:         \(count(DiaryEntry.self))")
        print("  DiaryMessage:       \(count(DiaryMessage.self))")
        print("  EmotionLog:         \(count(EmotionLog.self))")
        print("  SymptomLog:         \(count(SymptomLog.self))")
        print("  Medication:         \(count(Medication.self))")
        print("  MedicationDose:     \(count(MedicationDoseEvent.self))")
        print("  PenPal:             \(count(PenPal.self))")
        print("  Letter:             \(count(Letter.self))")
        print("  UserStamp:          \(count(UserStamp.self))")
        if let p = try? ctx.fetch(FetchDescriptor<UserProfile>()).first {
            print("  → UserProfile.displayName = '\(p.displayName)'")
            print("  → UserProfile.birthday    = \(p.birthday?.description ?? "nil")")
        }
        if let s = try? ctx.fetch(FetchDescriptor<AppSettings>()).first {
            print("  → AppSettings.whiteNoise  = '\(s.whiteNoiseMode)'")
            print("  → AppSettings.ambiance    = '\(s.ambianceMode)'")
        }
    }
    #endif
}
