import Foundation
import SwiftData

// MARK: - 微情绪实验

/// 微情绪实验单次记录 (`MicroEmotionStartView` → `MicroEmotionEndView`).
/// `templateId` 对应代码常量目录里的实验模板 (e.g. "complete_one_small_thing").
@Model
final class MicroEmotionSession {
    var templateId: String
    var startedAt: Date
    var completedAt: Date?
    /// 完成实验时, 若奖励了邮票, 关联到 UserStamp.id.
    var stampAwardedId: String?

    init(templateId: String, startedAt: Date = Date(), completedAt: Date? = nil) {
        self.templateId = templateId
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}

// MARK: - 微行为实验

/// 微行为实验单次记录 (`MicroBehaviorExperimentView`).
/// 包含选择的环境音 + 是否换过模板.
@Model
final class MicroBehaviorSession {
    var templateId: String
    var ambientSoundKey: String     // "海浪" / "风" / "雨"
    var startedAt: Date
    var completedAt: Date?
    var didSwapTemplate: Bool

    init(templateId: String, ambientSoundKey: String,
         startedAt: Date = Date(), completedAt: Date? = nil,
         didSwapTemplate: Bool = false) {
        self.templateId = templateId
        self.ambientSoundKey = ambientSoundKey
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.didSwapTemplate = didSwapTemplate
    }
}

// MARK: - 呼吸练习

/// 呼吸练习单次记录 (`BreathingExerciseView`).
/// `pattern` = "4-7-8" 等节律模式.
@Model
final class BreathingSession {
    var pattern: String
    var startedAt: Date
    var endedAt: Date?
    var elapsedSeconds: Int
    var completed: Bool

    init(pattern: String, startedAt: Date = Date(),
         endedAt: Date? = nil, elapsedSeconds: Int = 0, completed: Bool = false) {
        self.pattern = pattern
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.elapsedSeconds = elapsedSeconds
        self.completed = completed
    }
}

// MARK: - 知识库书签

/// 知识库文章的"用户行为"侧 (收藏 + 已读进度).
/// 文章内容目录仍由代码常量 (`KnowledgeMock.articles`) 提供;
/// 这里仅按标题做 key, 表示"用户对这篇文章做了什么操作".
@Model
final class ArticleBookmark {
    @Attribute(.unique) var articleKey: String  // 文章 title 作为短期 key
    var bookmarkedAt: Date
    var lastReadAt: Date?
    var readProgress: Double                    // 0.0...1.0

    init(articleKey: String, bookmarkedAt: Date = Date()) {
        self.articleKey = articleKey
        self.bookmarkedAt = bookmarkedAt
        self.readProgress = 0
    }
}
