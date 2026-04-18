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

// MARK: - 笔友

struct PenPal: Identifiable {
    let id = UUID()
    let avatar: String
    let name: String
    let info: String
    let time: String
    let count: Int
}

enum PenPalMock {
    static let list: [PenPal] = [
        PenPal(avatar: "偷", name: "偷喝一口月亮", info: "往来二十三封书信", time: "一天前", count: 23),
        PenPal(avatar: "云", name: "云端的朋友", info: "往来五封书信", time: "三天前", count: 5),
        PenPal(avatar: "野", name: "旷野之息", info: "往来九封书信", time: "五天前", count: 9)
    ]
}

// MARK: - 健康

struct SymptomEntry: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var severity: Int    // 0-3
}

enum HealthMock {
    static let symptoms: [SymptomEntry] = [
        SymptomEntry(name: "潮热", icon: "flame", severity: 3),
        SymptomEntry(name: "失眠", icon: "moon.zzz", severity: 2),
        SymptomEntry(name: "盗汗", icon: "drop", severity: 1),
        SymptomEntry(name: "心悸", icon: "heart", severity: 2),
        SymptomEntry(name: "焦虑", icon: "waveform.path", severity: 2),
        SymptomEntry(name: "头痛", icon: "brain", severity: 0)
    ]
}

struct MedicationItem: Identifiable {
    let id = UUID()
    let name: String
    let time: String
    var checked: Bool
}

enum MedicationMock {
    static let list: [MedicationItem] = [
        MedicationItem(name: "大豆异黄酮", time: "09:00", checked: true),
        MedicationItem(name: "雌激素制剂", time: "11:00", checked: true),
        MedicationItem(name: "鱼油", time: "13:00", checked: false),
        MedicationItem(name: "褪黑素", time: "22:00", checked: false)
    ]
    static let allDrugs = ["大豆异黄酮", "雌激素制剂", "鱼油", "褪黑素"]
}

// MARK: - 知识库

struct KnowledgeArticle: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let duration: String
}

enum KnowledgeMock {
    static let categories = ["身体与情绪", "情绪急救", "关系与沟通", "自我成长", "白…"]
    static let articles: [KnowledgeArticle] = [
        .init(title: "潮热与情绪波动",
              summary: "潮热时体温逐渐上升，会激活我们的交感神经系统……这不是你脾气变了，而是身体的\u{201C}应激开关\u{201D}被触发了。",
              duration: "阅读时长 2 分钟"),
        .init(title: "隐性疲劳与精力管理",
              summary: "更年期雌激素水平下降时，会影响深度睡眠的质量和时长。身体和大脑没有得到真正的休息，精力自然入不敷出。",
              duration: "阅读时长 1 分钟"),
        .init(title: "脑雾与记忆力困扰",
              summary: "很多更年期女性会经历暂时的记忆力变差和思维迟缓，这叫\u{201C}脑雾\u{201D}……这种状态通常是暂时的，会随着身体适应而缓解。",
              duration: "阅读时长 1 分钟"),
        .init(title: "情绪与躯体化疼痛",
              summary: "长期的情绪压力（焦虑、压抑）如果没有得到释放，会转化为躯体化症状存进肌肉里，表现为肩颈僵硬、深度酸痛。",
              duration: "阅读时长 2 分钟"),
        .init(title: "心悸与焦虑反应",
              summary: "更年期心悸多是激素波动影响对心跳的感知，或者是焦虑情绪引发的急性躯体反应。这种心悸通常是无害的，但感受上确实让人恐慌。",
              duration: "阅读时长 2 分钟")
    ]
}

// MARK: - 写信选项

enum WriteLetterMock {
    static let moods = ["自由填写 →", "忙里偷闲", "旅行途中", "\u{201C}虚\u{201D}"]
    static let feelings = ["自由填写 →", "心情平静", "有些疲惫", "知足"]
    static let weathers = ["自由填写 →", "阳光灿烂", "阴雨绵绵", "晚风"]
    static let letterTypes = ["自由填写 →", "碎碎念", "心事清单", "今天的"]
}
