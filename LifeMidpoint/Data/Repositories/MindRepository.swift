import Foundation
import SwiftData

/// 心境模块仓储 (微情绪 / 微行为 / 呼吸 / 知识库收藏).
@MainActor
struct MindRepository {
    let context: ModelContext

    // MARK: - 微情绪实验

    @discardableResult
    func startMicroEmotion(templateId: String) -> MicroEmotionSession {
        let s = MicroEmotionSession(templateId: templateId)
        context.insert(s)
        try? context.save()
        return s
    }

    func completeMicroEmotion(_ session: MicroEmotionSession, stampAwardedId: String? = nil) {
        session.completedAt = Date()
        session.stampAwardedId = stampAwardedId
        try? context.save()
    }

    // MARK: - 微行为实验

    @discardableResult
    func startMicroBehavior(templateId: String, ambient: String) -> MicroBehaviorSession {
        let s = MicroBehaviorSession(templateId: templateId, ambientSoundKey: ambient)
        context.insert(s)
        try? context.save()
        return s
    }

    func completeMicroBehavior(_ session: MicroBehaviorSession) {
        session.completedAt = Date()
        try? context.save()
    }

    // MARK: - 呼吸练习

    @discardableResult
    func startBreathing(pattern: String) -> BreathingSession {
        let s = BreathingSession(pattern: pattern)
        context.insert(s)
        try? context.save()
        return s
    }

    func endBreathing(_ session: BreathingSession, elapsedSeconds: Int, completed: Bool) {
        session.endedAt = Date()
        session.elapsedSeconds = elapsedSeconds
        session.completed = completed
        try? context.save()
    }

    // MARK: - 知识库收藏

    func bookmark(articleKey: String) {
        let predicate = #Predicate<ArticleBookmark> { $0.articleKey == articleKey }
        if let existing = try? context.fetch(FetchDescriptor<ArticleBookmark>(predicate: predicate)).first {
            // 已收藏 -> 视为取消
            context.delete(existing)
        } else {
            context.insert(ArticleBookmark(articleKey: articleKey))
        }
        try? context.save()
    }

    func isBookmarked(articleKey: String) -> Bool {
        let predicate = #Predicate<ArticleBookmark> { $0.articleKey == articleKey }
        return ((try? context.fetchCount(FetchDescriptor<ArticleBookmark>(predicate: predicate))) ?? 0) > 0
    }

    func allBookmarks() -> [ArticleBookmark] {
        let d = FetchDescriptor<ArticleBookmark>(
            sortBy: [SortDescriptor(\.bookmarkedAt, order: .reverse)]
        )
        return (try? context.fetch(d)) ?? []
    }
}
