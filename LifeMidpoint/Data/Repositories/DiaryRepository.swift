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
