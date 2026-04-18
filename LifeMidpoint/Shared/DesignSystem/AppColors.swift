import SwiftUI

/// 全局色板. 所有页面使用语义化 token, 禁止内联 Color(hex:).
extension Color {

    // MARK: - 基础语义色 (Foundation)

    /// 主文本: 深炭色 #2F3333
    static let textPrimary = Color(hex: 0x2F3333)
    /// 次要文本: 灰绿 #5C605F
    static let textSecondary = Color(hex: 0x5C605F)
    /// 占位文本 #AFB4B5
    static let textPlaceholder = Color(hex: 0xAFB4B5)
    /// 暖白页面背景 #F9F9F8
    static let pageBackground = Color(hex: 0xF9F9F8)
    /// 卡片白色
    static let cardBackground = Color.white

    // MARK: - 边框 / 分隔
    static let borderLight = Color(hex: 0xD9D9D9)
    static let chipBackgroundIdle = Color(hex: 0xF0F0F0)
    static let chipBackgroundAlt = Color(hex: 0xF5F5F5)
    static let chipBackgroundSelected = Color(hex: 0xE8E8E8)

    // MARK: - 灰阶 (Legacy)
    static let gray80 = Color(hex: 0x292524)
    static let gray60 = Color(hex: 0x686868)
    static let grayPlaceholder = Color(hex: 0xAFB4B5)
    static let cultured = Color(hex: 0xF7F6F9)
    static let deepCharcoal = Color(hex: 0x1B1A1F)
    static let steelBlue = Color(hex: 0x737B98)
    static let lightPurple = Color(hex: 0xAC92F7)

    // MARK: - 品牌色 (Brand)
    static let brandWarmBg = Color(hex: 0xF9F9F8)
    static let brandSoftPink = Color(hex: 0xF8ECEA)
    static let brandMutedGold = Color(hex: 0xD4C5A9)

    // MARK: - 心境模块 (Mind - 绿色系)
    static let mindPrimary = Color(hex: 0x536443)
    static let mindLight = Color(hex: 0xE8F0E9)
    static let mindLighter = Color(hex: 0xF5F7F5)
    static let mindMuted = Color(hex: 0xA3BFA8)
    static let mindAccent = Color(hex: 0xEDFFD8)
    static let mindChipBg = Color(hex: 0xE8F0F0)

    // MARK: - 健康/心率/经期 (粉色系)
    static let healthPink = Color(hex: 0xE8A0A0)
    static let healthPinkDark = Color(hex: 0xF2A0A0)
    static let healthPinkLight = Color(hex: 0xFAEBE8)
    static let healthPinkSoft = Color(hex: 0xF2D5D0)

    // MARK: - 睡眠 (蓝色系)
    static let sleepPrimary = Color(hex: 0x4A6FA5)
    static let sleepSecondary = Color(hex: 0x7BA3C9)
    static let sleepLight = Color(hex: 0xA8C4DC)
    static let sleepBg = Color(hex: 0xE8F0F8)

    // MARK: - 邮局 / 信件 / 黄色暖色
    static let postCream = Color(hex: 0xFDF8DF)        // 邮局浅黄
    static let postCardBg = Color(hex: 0xF3F4F3)        // 集邮册卡片底
    static let postSentInk = Color(hex: 0x536443)       // 寄出绿标签
    static let postReceivedInk = Color(hex: 0x506267)   // 收回标签
    static let postReceivedBg = Color(hex: 0xFDF8DF)
    static let postBrown = Color(hex: 0x3B3013)         // 深棕文字
    static let paperWarm = Color(hex: 0xF5ECD7)         // 纸张纹理
    static let paperWarmBlur = Color(hex: 0xD4C5A9)     // 纸张噪点
    static let inkBrownLight = Color(hex: 0xB8966B)     // 工具栏棕色
    static let inkBrownDark = Color(hex: 0xB8814D)      // 提示棕色
    static let inkBrownDeep = Color(hex: 0x5C4E3C)      // 完成按钮棕
    static let inkBrownAvatar = Color(hex: 0xE5D2A3)    // 信封黄底
    static let inkBrownGold = Color(hex: 0xB8A064)      // 高亮日

    // MARK: - 邮票 (金色系)
    static let stampGold = Color(hex: 0x845A06)
    static let stampGoldDeep = Color(hex: 0x5B4A00)
    static let stampGoldLink = Color(hex: 0xA26E0F)
    static let stampShowcaseBg = Color(hex: 0xF7F3EF)
    static let stampShowcaseBlush = Color(hex: 0xFFF9E7)
    static let stampDashed = Color(hex: 0xAFB3B2)

    // MARK: - 抽屉 / Drawer
    static let drawerLavender = Color(hex: 0xEEE8F0)
    static let drawerPeach = Color(hex: 0xF5EDE8)

    // MARK: - 渐变背景常用
    static let warmGradientTop = Color(hex: 0xFFEFD7)
    static let warmGradientHot = Color(hex: 0xFD795A)
    static let warmGradientBottom = Color(hex: 0xD2E6EC)
    static let stampShineYellow = Color(hex: 0xFFF5B4)

    // MARK: - 心理卡牌
    static let cardSandLight = Color(hex: 0xF5EDE0)
    static let cardSandDark = Color(hex: 0xE8DCCF)
    static let cardCream = Color(hex: 0xFFFCF5)

    // MARK: - 周总结 / Summary
    static let summaryPink = Color(hex: 0xF5E8ED)
    static let summaryDecoration = Color(hex: 0xE8C5A0)

    // MARK: - 集邮册渐变
    static let stampAlbumGradTop = Color(hex: 0xFBFAF4)

    // MARK: - 日记
    static let diarySandWarm = Color(hex: 0xC0B8AA)

    // MARK: - 呼吸花朵
    static let breathBlue = Color(hex: 0x00B4D8)
    static let breathBlueDark = Color(hex: 0x0077B6)
    static let breathCenter = Color(hex: 0x48CAE4)

    // MARK: - 情绪记录提示
    static let emotionPink = Color(hex: 0xC590B3)

    // MARK: - 杂项辅助色 (Misc)
    static let mutedGray = Color(hex: 0x8B8B8B)             // 通用灰
    static let dialogueGray = Color(hex: 0x666666)          // 对话气泡文字
    static let dustyPurple = Color(hex: 0x76697A)           // 输入占位
    static let mauve = Color(hex: 0x776B77)                 // 紫灰链接
    static let pastelLightBlue = Color(hex: 0xE8F4F8)       // 浅蓝按钮
    static let mintGreenLight = Color(hex: 0xD5E9BF)        // 心境推荐渐变
    static let mintMistBg = Color(hex: 0xEFF5F7)            // 心境模块卡背
    static let mintMistAlt = Color(hex: 0xF3F7F9)           // 心境模块次背
    static let inkBrownDeeper = Color(hex: 0x8B6E46)        // 心理卡牌深棕
}

// MARK: - Hex Init

extension Color {
    /// 通过 0xRRGGBB 形式构造颜色. 仅供 AppColors 内部使用,
    /// 业务代码请使用语义 token (如 `.textPrimary`).
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
