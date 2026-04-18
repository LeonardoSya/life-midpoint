import Foundation

struct OnboardingStep {
    let index: Int
    let imageName: String
    let dialogues: [String]
    let hasUserInput: Bool
    let ctaText: String?

    var hasDialogue: Bool { !dialogues.isEmpty }
}

let onboardingSteps: [OnboardingStep] = [
    // Step 1: 电梯场景，无文字
    OnboardingStep(
        index: 0,
        imageName: "OnboardingStep01",
        dialogues: [],
        hasUserInput: false,
        ctaText: nil
    ),
    // Step 2: 马路行走
    OnboardingStep(
        index: 1,
        imageName: "OnboardingStep02",
        dialogues: ["今天是你的生日。加班很辛苦，你打算去附近的蛋糕店买一块蛋糕犒劳自己。"],
        hasUserInput: false,
        ctaText: nil
    ),
    // Step 3: 脚步声，叹气声，无文字
    OnboardingStep(
        index: 2,
        imageName: "OnboardingStep03",
        dialogues: [],
        hasUserInput: false,
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
        hasUserInput: false,
        ctaText: nil
    ),
    // Step 5: 分享蛋糕，无文字
    OnboardingStep(
        index: 4,
        imageName: "OnboardingStep05",
        dialogues: [],
        hasUserInput: false,
        ctaText: nil
    ),
    // Step 6: 和小女孩一起
    OnboardingStep(
        index: 5,
        imageName: "OnboardingStep06",
        dialogues: ["你决定和小女孩一起分享这块蛋糕！"],
        hasUserInput: false,
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
        hasUserInput: false,
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
        hasUserInput: false,
        ctaText: nil
    ),
    // Step 9: 到家，无文字
    OnboardingStep(
        index: 8,
        imageName: "OnboardingStep09",
        dialogues: [],
        hasUserInput: false,
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
        hasUserInput: true,
        ctaText: nil
    ),
    // Step 11: 完成输入
    OnboardingStep(
        index: 10,
        imageName: "OnboardingStep11",
        dialogues: ["你认识了：xx！"],
        hasUserInput: false,
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
        hasUserInput: false,
        ctaText: nil
    ),
    // Step 13: 海边，三个角色相遇
    OnboardingStep(
        index: 12,
        imageName: "OnboardingStep13",
        dialogues: [
            "小女孩:(笑)你终于来了!我们等了你好久。",
            "介绍你们认识一下!这位奶奶是长大后的你，我是小时候的你。嘿，我们想见你好久了!听说你最近有很多心事，别着急，我们是来陪伴你的。",
            "你感到很疑惑。"
        ],
        hasUserInput: false,
        ctaText: nil
    ),
    // Step 14: 海边咖啡厅，开始旅程
    OnboardingStep(
        index: 13,
        imageName: "OnboardingStep14",
        dialogues: ["听着海浪声，你回想着发生的这一切。\n好想记录一些什么。"],
        hasUserInput: false,
        ctaText: "开始你的记录旅程"
    ),
]
