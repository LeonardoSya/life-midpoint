import Foundation
import SwiftData

/// 日记会话 + 消息 + 情绪打卡仓储.
@MainActor
struct DiaryRepository {
    let context: ModelContext

    // MARK: - Sessions

    /// 取最近一条 session (用于 DiaryView 默认沿用).
    func latestSession() -> DiarySession? {
        var d = FetchDescriptor<DiarySession>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        d.fetchLimit = 1
        return try? context.fetch(d).first
    }

    /// 拿最近一条 session, 没有则新建.
    func currentOrNewSession() -> DiarySession {
        if let existing = latestSession() {
            return existing
        }
        let s = DiarySession()
        context.insert(s)
        try? context.save()
        return s
    }

    /// 强制开新一条 session (用户点"开始新的记录"时用).
    func startNewSession() -> DiarySession {
        let s = DiarySession()
        context.insert(s)
        try? context.save()
        return s
    }

    func allSessions() -> [DiarySession] {
        let d = FetchDescriptor<DiarySession>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(d)) ?? []
    }

    @discardableResult
    func createEntry(title: String, body: String, summaryText: String, date: Date = Date()) -> DiaryEntry {
        let entry = DiaryEntry(entryDate: date, title: title, body: body, summaryText: summaryText)
        context.insert(entry)
        try? context.save()
        return entry
    }

    /// 清空所有日记对话历史.
    ///
    /// 当前产品决策: 日记对话不做本地持久化, 每次 App 冷启动都应为空。
    /// SwiftData 仍用于本次运行期间驱动 UI/逐字写入, 但启动时会清理旧 session/message。
    func deleteAllConversationHistory() {
        let sessions = (try? context.fetch(FetchDescriptor<DiarySession>())) ?? []
        for session in sessions {
            context.delete(session)
        }

        // 防御性清理: 如果历史迁移或异常中出现 orphan message, 也一起删除。
        let orphanMessages = (try? context.fetch(FetchDescriptor<DiaryMessage>())) ?? []
        for message in orphanMessages {
            context.delete(message)
        }

        try? context.save()
    }

    // MARK: - Messages

    /// 追加一条消息到指定 session.
    @discardableResult
    func append(text: String, isFromUser: Bool, to session: DiarySession) -> DiaryMessage {
        let msg = DiaryMessage(text: text, isFromUser: isFromUser, session: session)
        context.insert(msg)
        session.updatedAt = Date()
        try? context.save()
        return msg
    }

    func messages(in session: DiarySession) -> [DiaryMessage] {
        let sid = session.persistentModelID
        let predicate = #Predicate<DiaryMessage> { $0.session?.persistentModelID == sid }
        let d = FetchDescriptor<DiaryMessage>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.sentAt, order: .forward)]
        )
        return (try? context.fetch(d)) ?? []
    }

    func updateMessageText(_ message: DiaryMessage, text: String, persist: Bool = false) {
        message.text = text
        message.session?.updatedAt = Date()
        if persist {
            try? context.save()
        }
    }

    func save() {
        try? context.save()
    }

    func delete(_ message: DiaryMessage) {
        context.delete(message)
        try? context.save()
    }

    // MARK: - Summary

    func updateSummary(_ text: String?, for session: DiarySession) {
        session.summaryText = text
        session.updatedAt = Date()
        try? context.save()
    }

    // MARK: - Emotion

    @discardableResult
    func logEmotion(name: String, icon: String?, intensity: Double,
                    isCustom: Bool = false, customLabel: String? = nil,
                    session: DiarySession? = nil) -> EmotionLog {
        let log = EmotionLog(
            emotionName: name, emotionIcon: icon, intensity: intensity,
            isCustom: isCustom, customLabel: customLabel, session: session
        )
        context.insert(log)
        try? context.save()
        return log
    }

    func recentEmotions(limit: Int = 30) -> [EmotionLog] {
        var d = FetchDescriptor<EmotionLog>(
            sortBy: [SortDescriptor(\.recordedAt, order: .reverse)]
        )
        d.fetchLimit = limit
        return (try? context.fetch(d)) ?? []
    }
}
