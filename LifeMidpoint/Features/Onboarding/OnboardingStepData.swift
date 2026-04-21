import Foundation

enum OnboardingInputKind {
    /// 单行/多行文本: "写下你想说的话..."
    case text
    /// 个人档案: 姓名 + 出生日期 (Step 10 老照片)
    case profile
}

/// 对话气泡的位置布局, 严格对应 Figma 设计稿:
/// - `.bottom`: 全部气泡贴近屏幕底部 (绝大多数 step)
/// - `.mixed(topCount: N)`: 前 N 条放屏幕顶部, 余下放底部 (e.g. step 13 角色对话+内心独白)
enum BubbleLayout {
    case bottom
    case mixed(topCount: Int)
}

struct OnboardingStep {
    let index: Int
    let imageName: String
    let dialogues: [String]
    let inputKind: OnboardingInputKind?
    let ctaText: String?
    let bubbleLayout: BubbleLayout

    init(index: Int, imageName: String, dialogues: [String],
         inputKind: OnboardingInputKind? = nil, ctaText: String? = nil,
         bubbleLayout: BubbleLayout = .bottom) {
        self.index = index
        self.imageName = imageName
        self.dialogues = dialogues
        self.inputKind = inputKind
        self.ctaText = ctaText
        self.bubbleLayout = bubbleLayout
    }

    var hasUserInput: Bool { inputKind != nil }
    var hasDialogue: Bool { !dialogues.isEmpty }
}

let onboardingSteps: [OnboardingStep] = [
    // Step 1: 电梯场景，无文字
    OnboardingStep(
        index: 0,
        imageName: "OnboardingStep01",
        dialogues: [],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 2: 马路行走
    OnboardingStep(
        index: 1,
        imageName: "OnboardingStep02",
        dialogues: ["今天是你的生日。加班很辛苦，你打算去附近的蛋糕店买一块蛋糕犒劳自己。"],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 3: 脚步声，叹气声，无文字
    OnboardingStep(
        index: 2,
        imageName: "OnboardingStep03",
        dialogues: [],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 4: 蛋糕店
    OnboardingStep(
        index: 3,
        imageName: "OnboardingStep04",
        dialogues: [
            "只剩下最后一块了。",
            "这个小女孩看起来也想要这块蛋糕。你想起自己小时候最爱吃的就是草莓蛋糕。"
        ],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 5: 分享蛋糕，无文字
    OnboardingStep(
        index: 4,
        imageName: "OnboardingStep05",
        dialogues: [],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 6: 和小女孩一起
    OnboardingStep(
        index: 5,
        imageName: "OnboardingStep06",
        dialogues: ["你决定和小女孩一起分享这块蛋糕！"],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 7: 小孩笑声，发现胎记
    OnboardingStep(
        index: 6,
        imageName: "OnboardingStep07",
        dialogues: [
            "等等...",
            "你注意到她的手上有着和你一样的胎记。"
        ],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 8: 获得兔子
    OnboardingStep(
        index: 7,
        imageName: "OnboardingStep08",
        dialogues: [
            "*你获得了\u{201C}兔子\u{201D}！",
            "这看起来和你小时候在玩具店里看到的那只兔子很像..."
        ],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 9: 到家，无文字
    OnboardingStep(
        index: 8,
        imageName: "OnboardingStep09",
        dialogues: [],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 10: 用户输入名字
    OnboardingStep(
        index: 9,
        imageName: "OnboardingStep10",
        dialogues: [
            "...这怎么是...小时候的自己？",
            "*请输入你的名字与出生日期。"
        ],
        inputKind: .profile,
        ctaText: nil
    ),
    // Step 11: 完成输入
    OnboardingStep(
        index: 10,
        imageName: "OnboardingStep11",
        dialogues: ["你认识了：xx！"],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 12: 梦幻漩涡
    OnboardingStep(
        index: 11,
        imageName: "OnboardingStep12",
        dialogues: [
            "兔子从你的手中逃脱了！",
            "你不知道自己追了它多久，或许它知道哪里能够找到xx..."
        ],
        inputKind: nil,
        ctaText: nil
    ),
    // Step 13: 海边，三个角色相遇
    // Figma 设计: 前 2 条角色对话贴顶, 第 3 条内心独白贴底.
    OnboardingStep(
        index: 12,
        imageName: "OnboardingStep13",
        dialogues: [
            "小女孩:(笑)你终于来了!我们等了你好久。",
            "小女孩:介绍你们认识一下!这位奶奶是长大后的你，我是小时候的你。嘿，我们想见你好久了!听说你最近有很多心事，别着急，我们是来陪伴你的。",
            "你感到很疑惑。"
        ],
        inputKind: nil,
        ctaText: nil,
        bubbleLayout: .mixed(topCount: 2)
    ),
    // Step 14: 海边咖啡厅，开始旅程
    OnboardingStep(
        index: 13,
        imageName: "OnboardingStep14",
        dialogues: ["听着海浪声，你回想着发生的这一切。\n好想记录一些什么。"],
        inputKind: nil,
        ctaText: "开始你的记录旅程"
    ),
]
