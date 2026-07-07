import SwiftUI

// MARK: - 字体策略 (与 Figma 设计稿严格对齐)
//
// 项目内使用的 3 款衬线字体, 通过 Resources/Fonts/ 打包并在 Info.plist 注册:
//
//   1. Source Han Serif CN - Bold       (思源宋体 Bold)
//      - PostScript: "SourceHanSerifCN-Bold"
//      - 用途: 所有大小标题, 强调正文 (page title, section header, hero title)
//
//   2. Sky Heart Clear Serif SC - Regular (空心晴宋体)
//      - PostScript: "SkyHeartClearSerifSC-Regular"
//      - 用途: 默认正文, 输入提示, 次要文本, 描述
//      - 这是设计稿里出现频率最高的字体, 给页面温暖质感
//
//   3. Source Han Serif CN - ExtraLight (思源宋体 ExtraLight)
//      - PostScript: "SourceHanSerifCN-ExtraLight"
//      - 用途: 优雅的小数字、日期 (例: "我的周报 2.1-2.7")
//
// 缺字回退: 系统默认 (.system) 自动衔接.

private enum FontPS {
    static let titleBold = "SourceHanSerifCN-Bold"
    static let body = "SkyHeartClearSerifSC-Regular"
    static let extraLight = "SourceHanSerifCN-ExtraLight"
}

enum AppFont {
    /// 大小标题, hero 文字 — 思源宋体 Bold
    static func title(_ size: CGFloat) -> Font {
        .custom(FontPS.titleBold, size: size)
    }

    /// 默认正文 — 空心晴宋体 Regular
    static func body(_ size: CGFloat) -> Font {
        .custom(FontPS.body, size: size)
    }

    /// 次要 / 注释 / 元数据 — 同正文字体, 视觉层级靠颜色和字号区分
    static func caption(_ size: CGFloat) -> Font {
        .custom(FontPS.body, size: size)
    }

    /// 优雅的小数字、日期标签 — 思源宋体 ExtraLight
    /// 用于"2.1-2.7"这类需要精致细线感的辅助信息
    static func numeric(_ size: CGFloat) -> Font {
        .custom(FontPS.extraLight, size: size)
    }

    // MARK: - 兼容旧 API (避免一次性大批量改业务代码)
    static func serifTitle(_ size: CGFloat) -> Font { title(size) }
    static func serifBody(_ size: CGFloat) -> Font { body(size) }
    static func serifTitleFallback(_ size: CGFloat) -> Font { title(size) }
    static func serifBodyFallback(_ size: CGFloat) -> Font { body(size) }
}

// MARK: - View Modifiers

extension View {
    /// 标题样式: serif bold + textPrimary
    func titleStyle(_ size: CGFloat = 24) -> some View {
        self.font(AppFont.title(size))
            .foregroundStyle(Color.textPrimary)
    }

    /// 正文样式: serif regular + textPrimary
    func bodyStyle(_ size: CGFloat = 14) -> some View {
        self.font(AppFont.body(size))
            .foregroundStyle(Color.textPrimary)
    }

    /// 次要文本: serif regular + textSecondary
    func secondaryStyle(_ size: CGFloat = 12) -> some View {
        self.font(AppFont.body(size))
            .foregroundStyle(Color.textSecondary)
    }

    /// 注释 / 元数据: 小号 caption + textSecondary
    func captionStyle(_ size: CGFloat = 12) -> some View {
        self.font(AppFont.caption(size))
            .foregroundStyle(Color.textSecondary)
    }

    /// 数字 / 日期 (思源宋体 ExtraLight): textPrimary
    func numericStyle(_ size: CGFloat = 12) -> some View {
        self.font(AppFont.numeric(size))
            .foregroundStyle(Color.textPrimary)
    }
}
