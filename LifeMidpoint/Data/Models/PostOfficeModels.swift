import Foundation
import SwiftData

// MARK: - 笔友

/// 笔友 (本地虚拟 NPC 或未来对接的远程账号).
/// 名称 unique: 不允许重名笔友.
@Model
final class PenPal {
    @Attribute(.unique) var name: String
    var avatar: String              // 头像首字 ("偷" / "云" / "野")
    var info: String                // "往来二十三封书信" 描述
    var lastActiveAt: Date
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Letter.penPal)
    var letters: [Letter] = []

    init(name: String, avatar: String, info: String = "", lastActiveAt: Date = Date()) {
        self.name = name
        self.avatar = avatar
        self.info = info
        self.lastActiveAt = lastActiveAt
        self.createdAt = Date()
    }
}

// MARK: - 信件

/// 一封信件: 用户写出 (sent) 或收到 (received) 都用同一张表.
/// 状态机: draft → sent (写完点寄出);  received 状态用于收到的回信.
@Model
final class Letter {
    var direction: String           // "sent" / "received"
    var recipientMode: String       // "self" / "stranger" / "penPal"
    var body: String
    var moodTag: String?            // "忙里偷闲" 等
    var feelingTag: String?         // "心情平静" 等
    var weatherTag: String?         // "晚风" 等
    var letterTypeTag: String?      // "心事清单" 等
    var alias: String?              // 化名 / 署名
    var createdAt: Date
    var sentAt: Date?
    var status: String              // "draft" / "sent"

    var penPal: PenPal?
    /// 关联到寄出时消耗的邮票 (UserStamp.id 字符串形式).
    var stampUsedId: String?

    init(direction: String = "sent",
         recipientMode: String = "stranger",
         body: String,
         moodTag: String? = nil, feelingTag: String? = nil,
         weatherTag: String? = nil, letterTypeTag: String? = nil,
         alias: String? = nil,
         penPal: PenPal? = nil,
         status: String = "draft") {
        self.direction = direction
        self.recipientMode = recipientMode
        self.body = body
        self.moodTag = moodTag
        self.feelingTag = feelingTag
        self.weatherTag = weatherTag
        self.letterTypeTag = letterTypeTag
        self.alias = alias
        self.penPal = penPal
        self.status = status
        self.createdAt = Date()
        self.sentAt = status == "sent" ? Date() : nil
    }
}

// MARK: - 邮票

/// 用户已经获得的邮票实例.
/// 邮票"目录"(图片/标题/文案) 仍由代码常量 `StampLibrary` 提供;
/// 这里只记录"用户在何时何地获得了邮票 X".
@Model
final class UserStamp {
    /// 对应 `StampInfo.id` (e.g. "gold_1").
    var stampDefinitionId: String
    var obtainedAt: Date
    /// "letter_sent" / "achievement" / "onboarding_seed" / "manual"
    var source: String

    init(stampDefinitionId: String, source: String = "achievement", obtainedAt: Date = Date()) {
        self.stampDefinitionId = stampDefinitionId
        self.obtainedAt = obtainedAt
        self.source = source
    }
}
