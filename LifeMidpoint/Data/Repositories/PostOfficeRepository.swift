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

    /// 删除笔友关系 (级联删除其往来信件, 见 `PenPal.letters` 的 `.cascade` 规则).
    func deletePenPal(_ penPal: PenPal) {
        context.delete(penPal)
        try? context.save()
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
              awardStampDefinitionId: String? = nil,
              attachmentFilenames: [String] = []) -> Letter {
        let l = Letter(direction: "sent", recipientMode: recipientMode, body: body,
                       moodTag: moodTag, feelingTag: feelingTag, weatherTag: weatherTag,
                       letterTypeTag: letterTypeTag, alias: alias, penPal: penPal,
                       status: "sent", attachmentFilenames: attachmentFilenames)
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

    /// 某一天寄出的信件数 (用于"查看完整回忆"详情页"今日小确幸").
    func lettersSentCount(on date: Date) -> Int {
        letters(on: date, direction: "sent").count
    }

    /// 某一天收到的信件数.
    func lettersReceivedCount(on date: Date) -> Int {
        letters(on: date, direction: "received").count
    }

    private func letters(on date: Date, direction: String) -> [Letter] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        let predicate = #Predicate<Letter> {
            $0.direction == direction && $0.createdAt >= start && $0.createdAt < end
        }
        let d = FetchDescriptor<Letter>(predicate: predicate)
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

    /// 某一天获得的邮票 (用于"查看完整回忆"详情页"今日小确幸").
    func stampsObtained(on date: Date) -> [UserStamp] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        let predicate = #Predicate<UserStamp> { $0.obtainedAt >= start && $0.obtainedAt < end }
        let d = FetchDescriptor<UserStamp>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.obtainedAt, order: .reverse)]
        )
        return (try? context.fetch(d)) ?? []
    }
}

// MARK: - DailyMailActivityProviding

extension PostOfficeRepository: DailyMailActivityProviding {}
