import Foundation

/// 情绪识别弹窗的单一数据源.
///
/// 设计稿仅提供了"疲惫"版的"情绪识别弹窗2"(node 2:23397). 这里把 9 种预设心理状态
/// 都按同一套 UI 结构补齐文案: 顶部图标 + 两行标题 + 被允许语 + "信号"知识卡 + 微行为实验引导.
/// 呼吸练习卡与底部寄语在所有情绪间保持一致(由 `EmotionDetailView` 内置),故不放进此模型.
struct EmotionContent: Identifiable, Hashable {
    /// 情绪名, 同时作为选择器格子文案与查找键.
    let name: String
    /// 顶部胶囊图标 (SF Symbol). 选择器格子与详情页头部共用, 保证全程图标一致.
    let icon: String
    /// 标题第一行, 形如 "你今天似乎有一点疲惫，".
    let headlineLine1: String
    /// 标题第二行, 形如 "也有些低落。".
    let headlineLine2: String
    /// 标题下方的被允许语.
    let allowedLine: String
    /// "信号"知识卡标题, 形如 "疲惫是一种信号。".
    let signalTitle: String
    /// "信号"知识卡正文.
    let signalBody: String
    /// "试试这个微行为实验"卡的正文引导.
    let microBody: String

    var id: String { name }
}

enum EmotionLibrary {
    /// 9 种预设心理状态. 顺序与设计稿"情绪识别弹窗1"的 3×3 宫格一致.
    static let all: [EmotionContent] = [
        EmotionContent(
            name: "平静",
            icon: "leaf.fill",
            headlineLine1: "你今天似乎挺平静，",
            headlineLine2: "内心很安稳。",
            allowedLine: "很好，值得为此停留片刻。",
            signalTitle: "平静是一种力量。",
            signalBody: "平静不是什么都没有发生，而是你有能力安放发生的一切。此刻的稳定，是你与自己达成的默契，也是继续向前的底气。试着记住这种感觉，它会在风浪来临时成为你的锚。",
            microBody: "找一个舒服的姿势坐下，把注意力放在呼吸上。试着在心里记下此刻让你感到安稳的三件小事——也许是一杯温水，一段空白的时间，或只是此刻的自己。"
        ),
        EmotionContent(
            name: "愉悦",
            icon: "face.smiling",
            headlineLine1: "你今天似乎很愉悦，",
            headlineLine2: "心情轻盈。",
            allowedLine: "真好，请记住此刻的明亮。",
            signalTitle: "愉悦值得被记住。",
            signalBody: "快乐有时来得很轻，轻到容易被忽略。但正是这些细小的明亮时刻，串起了值得回味的一天。允许自己充分地高兴，不必急着寻找理由，也不必担心它会消失。",
            microBody: "闭上眼睛，回想今天让你嘴角上扬的那个瞬间。把它在脑海里多停留几秒，像收藏一张照片那样，轻轻对自己说：\u{201C}这一刻，真好。\u{201D}"
        ),
        EmotionContent(
            name: "低落",
            icon: "cloud.fill",
            headlineLine1: "你今天似乎有些低落，",
            headlineLine2: "提不起劲。",
            allowedLine: "没关系，这种感觉是被允许的。",
            signalTitle: "低落是一种休息。",
            signalBody: "情绪低落时，世界仿佛蒙上了一层灰。但这并不意味着你出了问题，它更像心在示意你慢下来。不必强迫自己立刻好起来，低谷也是旅途的一部分，光会以它自己的节奏回来。",
            microBody: "试着把此刻的沉重，想象成天上的一片云。它会停留一会儿，也终将飘走。你不需要驱赶它，只需安静地陪着自己，等待光重新照进来。"
        ),
        EmotionContent(
            name: "烦躁",
            icon: "bolt.fill",
            headlineLine1: "你今天似乎有点烦躁，",
            headlineLine2: "心里有些乱。",
            allowedLine: "没关系，这种感觉是被允许的。",
            signalTitle: "烦躁是一种提醒。",
            signalBody: "烦躁常常出现在你被消耗太多、却来不及照顾自己的时候。它不是你的错，而是内心在提醒你：需要一点空间，需要喘口气了。听见这个提醒，已经是温柔待己的开始。",
            microBody: "把双手放在胸口，做三次缓慢的深呼吸。每一次呼气时，想象那些细碎的烦扰随气息一起离开身体，让紧绷的肩膀慢慢松下来。"
        ),
        EmotionContent(
            name: "焦虑",
            icon: "brain.head.profile",
            headlineLine1: "你今天似乎有些焦虑，",
            headlineLine2: "思绪停不下来。",
            allowedLine: "没关系，这种感觉是被允许的。",
            signalTitle: "焦虑是一种关心。",
            signalBody: "焦虑的背后，往往藏着你对某件事的在乎。它让你不安，也说明你认真。试着把那些盘旋的念头一件件放下，你不需要一次性解决所有事情，此刻只需先照顾好自己。",
            microBody: "环顾四周，试着说出你看到的五样东西、听到的三种声音、能触碰到的两样物体。让感官把你温柔地拉回此刻，回到脚踏实地的当下。"
        ),
        EmotionContent(
            name: "疲惫",
            icon: "moon.fill",
            headlineLine1: "你今天似乎有一点疲惫，",
            headlineLine2: "也有些低落。",
            allowedLine: "没关系，这种感觉是被允许的。",
            signalTitle: "疲惫是一种信号。",
            signalBody: "当心灵感到超负荷时，它会通过疲惫来请求一个停顿。这并不是虚弱，而是身体在提醒你，现在的你比以往任何时候都更需要温柔的关怀。",
            microBody: "闭上眼睛，试着在脑海中列出三个此刻让你感到沉重的小事。不用去解决它们，只需在大脑中轻轻地对它们说一声：\u{201C}我知道了，辛苦了。\u{201D}"
        ),
        EmotionContent(
            name: "悲伤",
            icon: "drop.fill",
            headlineLine1: "你今天似乎有些悲伤，",
            headlineLine2: "心里沉甸甸的。",
            allowedLine: "没关系，眼泪也是被允许的。",
            signalTitle: "悲伤是一种深情。",
            signalBody: "我们会悲伤，是因为曾经真切地在乎过。它沉重，却也温柔地证明了那些人和事对你的意义。不必急着擦干，给悲伤一点时间，它会慢慢沉淀成更柔软的力量。",
            microBody: "如果此刻想哭，就让自己哭一会儿。或者，找一个安静的角落，把手轻轻放在心口，像安慰一位老朋友那样，对自己说：\u{201C}我在这里，陪着你。\u{201D}"
        ),
        EmotionContent(
            name: "易怒",
            icon: "flame.fill",
            headlineLine1: "你今天似乎容易动怒，",
            headlineLine2: "胸口有团火。",
            allowedLine: "没关系，愤怒也是被允许的。",
            signalTitle: "愤怒是一种边界。",
            signalBody: "愤怒常常出现在你的某条底线被触碰时。它并不可怕，反而在替你守护重要的东西。看见它、理解它，再决定如何回应，你依然可以是温柔而有力量的。",
            microBody: "在心里慢慢从一数到十，每数一个数，就松开一分紧绷。然后试着问问自己：\u{201C}这团火，其实是想保护我什么？\u{201D}"
        ),
        EmotionContent(
            name: "麻木",
            icon: "snowflake",
            headlineLine1: "你今天似乎有些麻木，",
            headlineLine2: "感觉有点抽离。",
            allowedLine: "没关系，这种状态也是被允许的。",
            signalTitle: "麻木是一种保护。",
            signalBody: "当情绪太满、太重时，心会暂时按下静音键，用麻木把你保护起来。这不是冷漠，而是一种自我保全。不必责怪此刻没有感觉的自己，感受会在你准备好时，慢慢回来。",
            microBody: "倒一杯温水，双手握住杯子，专注地感受那份温度从掌心一点点传来。让一个微小而真实的感觉，轻轻唤醒此刻的你。"
        ),
    ]

    /// 非选择器情绪, 但同样用"弹窗2"详情结构展示的额外条目.
    /// 例如心境首页"今日推荐"Hero 卡指向的"潮热与情绪波动". 这些不出现在弹窗1的选择宫格里.
    static let extras: [EmotionContent] = [
        EmotionContent(
            name: "潮热",
            icon: "thermometer.sun.fill",
            headlineLine1: "潮热袭来时，",
            headlineLine2: "身体和情绪都在波动。",
            allowedLine: "没关系，这是身体在经历变化。",
            signalTitle: "潮热是一种身体信号。",
            signalBody: "潮热引发的体温骤升，会激活交感神经系统，进而触发应激反应，让人变得警觉、急躁。这并不是你情绪失控，而是身体在努力适应变化。理解它的来由，就能少一分自责，多一分从容。",
            microBody: "当潮热来袭，试着把注意力放在呼吸上：缓慢地吸气四秒，再缓慢地呼气六秒。让拉长的呼气安抚被唤醒的神经，轻轻告诉身体——现在是安全的。"
        ),
    ]

    /// 按情绪名查内容(预设 9 种 + 额外条目); 未命中(如自定义情绪)返回一份温柔的通用兜底, 保证详情页永不为空.
    static func content(for name: String) -> EmotionContent {
        all.first { $0.name == name }
            ?? extras.first { $0.name == name }
            ?? fallback(for: name)
    }

    /// 自定义/未知情绪的兜底文案.
    static func fallback(for name: String) -> EmotionContent {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let label = trimmed.isEmpty ? "情绪" : trimmed
        return EmotionContent(
            name: label,
            icon: "sparkles",
            headlineLine1: "你今天似乎有一点\(label)，",
            headlineLine2: "谢谢你愿意说出它。",
            allowedLine: "没关系，任何感受都是被允许的。",
            signalTitle: "每一种感受都值得被看见。",
            signalBody: "能为此刻的自己找到一个词，已经是一种了不起的觉察。不论它是什么，都不必急着评判或改变。先看见它、承认它，温柔就有了落脚的地方。",
            microBody: "做一次长长的深呼吸，把注意力放回身体。试着在心里轻轻地对此刻的自己说一声：\u{201C}我看见你了，谢谢你告诉我。\u{201D}"
        )
    }
}
