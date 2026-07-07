import Foundation
import SwiftData

// MARK: - 依赖协议 (每个协议只负责一类"某一天"的数据来源, 便于单独 mock 测试)

/// 某一天的情绪打卡来源.
@MainActor
protocol DailyEmotionProviding {
    func emotionLogs(on date: Date) -> [EmotionLog]
}

/// 某一天的信件与邮票活动来源.
@MainActor
protocol DailyMailActivityProviding {
    func lettersSentCount(on date: Date) -> Int
    func lettersReceivedCount(on date: Date) -> Int
    func stampsObtained(on date: Date) -> [UserStamp]
}

// MARK: - 聚合结果 (纯值类型, 与 SwiftData / View 解耦, 方便断言)

/// "今日小确幸" 聚合结果, 供"查看完整回忆"详情页展示.
struct DailyMemoryHighlights: Equatable {
    var moodLabel: String?
    var moodIcon: String?
    var lettersSentCount: Int
    var lettersReceivedCount: Int
    var stampDefinitionIds: [String]

    static let empty = DailyMemoryHighlights(
        moodLabel: nil, moodIcon: nil,
        lettersSentCount: 0, lettersReceivedCount: 0,
        stampDefinitionIds: []
    )
}

/// 把"某一天"分散在情绪打卡 / 信件 / 邮票三张表里的数据聚合成 `DailyMemoryHighlights`.
///
/// 数据来源通过协议注入: 生产环境默认接 SwiftData 仓储 (`DiaryRepository` / `PostOfficeRepository`),
/// 单测可注入轻量 mock, 无需真实 `ModelContext` 即可验证聚合逻辑 (参见 swift-protocol-di-testing)。
@MainActor
struct DailyMemoryAggregator {
    private let emotionProvider: DailyEmotionProviding
    private let mailProvider: DailyMailActivityProviding

    init(emotionProvider: DailyEmotionProviding, mailProvider: DailyMailActivityProviding) {
        self.emotionProvider = emotionProvider
        self.mailProvider = mailProvider
    }

    init(context: ModelContext) {
        self.init(
            emotionProvider: DiaryRepository(context: context),
            mailProvider: PostOfficeRepository(context: context)
        )
    }

    func highlights(for date: Date) -> DailyMemoryHighlights {
        let mood = emotionProvider.emotionLogs(on: date).first
        let moodLabel = mood.flatMap { $0.isCustom ? ($0.customLabel ?? $0.emotionName) : $0.emotionName }
        return DailyMemoryHighlights(
            moodLabel: moodLabel,
            moodIcon: mood?.emotionIcon,
            lettersSentCount: mailProvider.lettersSentCount(on: date),
            lettersReceivedCount: mailProvider.lettersReceivedCount(on: date),
            stampDefinitionIds: mailProvider.stampsObtained(on: date).map(\.stampDefinitionId)
        )
    }
}
