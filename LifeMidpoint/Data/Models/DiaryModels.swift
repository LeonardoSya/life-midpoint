import Foundation
import SwiftData

// MARK: - 日记会话

/// 一次连续的日记输入 (一段聊天对话 + 可选 AI 总结).
/// 用户每次进入 DiaryView 默认沿用最近的 session, 也可手动开新一条.
@Model
final class DiarySession {
    var createdAt: Date
    var updatedAt: Date
    var summaryText: String?

    @Relationship(deleteRule: .cascade, inverse: \DiaryMessage.session)
    var messages: [DiaryMessage] = []

    @Relationship(deleteRule: .cascade, inverse: \EmotionLog.session)
    var emotionLogs: [EmotionLog] = []

    init(createdAt: Date = Date(), summaryText: String? = nil) {
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.summaryText = summaryText
    }
}

// MARK: - 聊天消息

/// 一条日记/AI 对话气泡.
/// `isFromUser` = false 表示 AI 引导 / 系统欢迎语.
@Model
final class DiaryMessage {
    var sentAt: Date
    var text: String
    var isFromUser: Bool

    var session: DiarySession?

    init(text: String, isFromUser: Bool, sentAt: Date = Date(), session: DiarySession? = nil) {
        self.text = text
        self.isFromUser = isFromUser
        self.sentAt = sentAt
        self.session = session
    }
}

// MARK: - 情绪打卡

/// 情绪选择器 (`EmotionPickerSheet`) 的提交记录.
/// 关联到当前日记 session, 也可单独存在 (session=nil 表示独立打卡).
@Model
final class EmotionLog {
    var recordedAt: Date
    var emotionName: String         // "平静" / "疲惫" / "希望" 等
    var emotionIcon: String?        // SF Symbol 名
    var intensity: Double           // 0.0...1.0
    var isCustom: Bool
    var customLabel: String?

    var session: DiarySession?

    init(emotionName: String, emotionIcon: String? = nil,
         intensity: Double = 0.5, isCustom: Bool = false,
         customLabel: String? = nil, recordedAt: Date = Date(),
         session: DiarySession? = nil) {
        self.emotionName = emotionName
        self.emotionIcon = emotionIcon
        self.intensity = intensity
        self.isCustom = isCustom
        self.customLabel = customLabel
        self.recordedAt = recordedAt
        self.session = session
    }
}
