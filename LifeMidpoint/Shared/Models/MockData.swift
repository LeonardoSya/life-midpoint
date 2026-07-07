import Foundation

// MARK: - 邮局相关

struct LetterEntry: Identifiable {
    let id = UUID()
    let isFromMe: Bool
    let time: String
    let content: String
}

enum PostOfficeMock {
    static let recentLetters: [LetterEntry] = [
        LetterEntry(isFromMe: true, time: "2小时前",
                    content: "今天的风很轻，我想把那些焦虑\n都吹散在云里..."),
        LetterEntry(isFromMe: false, time: "昨天 21:40",
                    content: "愿你的世界总有暖阳，那些不安\n终会成为过去的风景。"),
        LetterEntry(isFromMe: true, time: "2小时前",
                    content: "今天的风很轻，我想把那些焦虑\n都吹散在云里...")
    ]
}

// 注意: 旧的 `struct PenPal` mock 已被 SwiftData `@Model class PenPal` 替代,
// 见 LifeMidpoint/Data/Models/PostOfficeModels.swift. 笔友数据通过
// `PostOfficeRepository.allPenPals()` 获取.
