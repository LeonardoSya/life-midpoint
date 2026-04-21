import Foundation
import SwiftData

/// 邮局模块仓储 (笔友 / 信件 / 邮票).
@MainActor
struct PostOfficeRepository {
    let context: ModelContext

    // MARK: - 笔友

    func allPenPals() -> [PenPal] {
        let d = FetchDescriptor<PenPal>(
            sortBy: [SortDescriptor(\.lastActiveAt, order: .reverse)]
        )
        return (try? context.fetch(d)) ?? []
    }

    @discardableResult
    func upsertPenPal(name: String, avatar: String, info: String = "") -> PenPal {
        let predicate = #Predicate<PenPal> { $0.name == name }
        if let existing = try? context.fetch(FetchDescriptor<PenPal>(predicate: predicate)).first {
            existing.avatar = avatar
            existing.info = info
            existing.lastActiveAt = Date()
            try? context.save()
            return existing
        }
        let p = PenPal(name: name, avatar: avatar, info: info)
        context.insert(p)
        try? context.save()
        return p
    }

    // MARK: - 信件

    /// 保存草稿 (未寄出).
    @discardableResult
    func saveDraft(body: String, recipientMode: String,
                   moodTag: String? = nil, feelingTag: String? = nil,
                   weatherTag: String? = nil, letterTypeTag: String? = nil,
                   alias: String? = nil, penPal: PenPal? = nil) -> Letter {
        let l = Letter(direction: "sent", recipientMode: recipientMode, body: body,
                       moodTag: moodTag, feelingTag: feelingTag, weatherTag: weatherTag,
                       letterTypeTag: letterTypeTag, alias: alias, penPal: penPal,
                       status: "draft")
        context.insert(l)
        try? context.save()
        return l
    }

    /// 寄出一封信. 同时奖励一枚邮票 (若提供 stampDefinitionId).
    @discardableResult
    func send(body: String, recipientMode: String,
              moodTag: String? = nil, feelingTag: String? = nil,
              weatherTag: String? = nil, letterTypeTag: String? = nil,
              alias: String? = nil, penPal: PenPal? = nil,
              awardStampDefinitionId: String? = nil) -> Letter {
        let l = Letter(direction: "sent", recipientMode: recipientMode, body: body,
                       moodTag: moodTag, feelingTag: feelingTag, weatherTag: weatherTag,
                       letterTypeTag: letterTypeTag, alias: alias, penPal: penPal,
                       status: "sent")
        context.insert(l)

        if let stampId = awardStampDefinitionId {
            let stamp = UserStamp(stampDefinitionId: stampId, source: "letter_sent")
            context.insert(stamp)
            l.stampUsedId = stampId
        }

        if let penPal {
            penPal.lastActiveAt = Date()
        }

        try? context.save()
        return l
    }

    func recentLetters(limit: Int = 10) -> [Letter] {
        var d = FetchDescriptor<Letter>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        d.fetchLimit = limit
        return (try? context.fetch(d)) ?? []
    }

    func letters(in penPal: PenPal) -> [Letter] {
        let pid = penPal.persistentModelID
        let predicate = #Predicate<Letter> { $0.penPal?.persistentModelID == pid }
        let d = FetchDescriptor<Letter>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(d)) ?? []
    }

    // MARK: - 邮票

    func allUserStamps() -> [UserStamp] {
        let d = FetchDescriptor<UserStamp>(
            sortBy: [SortDescriptor(\.obtainedAt, order: .reverse)]
        )
        return (try? context.fetch(d)) ?? []
    }

    /// 是否已获得某个邮票定义.
    func hasStamp(definitionId: String) -> Bool {
        let predicate = #Predicate<UserStamp> { $0.stampDefinitionId == definitionId }
        return ((try? context.fetchCount(FetchDescriptor<UserStamp>(predicate: predicate))) ?? 0) > 0
    }

    @discardableResult
    func grantStamp(definitionId: String, source: String = "achievement") -> UserStamp {
        let stamp = UserStamp(stampDefinitionId: definitionId, source: source)
        context.insert(stamp)
        try? context.save()
        return stamp
    }
}
