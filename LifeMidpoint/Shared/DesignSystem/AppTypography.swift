import SwiftUI

// MARK: - 字体策略
//
// Figma 设计:
//   标题: Source Han Serif CN (思源宋体) Bold
//   正文: Sky Heart Clear Serif SC Regular
//
// iOS 系统宋体 STSongti-SC 作为正式字体替代 (开源协议兼容).

private let serifFontName = "STSongti-SC-Regular"
private let serifBoldFontName = "STSongti-SC-Bold"

enum AppFont {
    /// 标题字体 (思源宋体 Bold fallback)
    static func title(_ size: CGFloat) -> Font {
        .custom(serifBoldFontName, size: size)
    }

    /// 正文字体 (思源宋体 Regular fallback)
    static func body(_ size: CGFloat) -> Font {
        .custom(serifFontName, size: size)
    }

    /// 辅助字体 (系统默认 sans)
    static func caption(_ size: CGFloat) -> Font {
        .system(size: size)
    }

    // 兼容旧 API
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

    /// 注释 / 元数据: 小号 sans + textSecondary
    func captionStyle(_ size: CGFloat = 12) -> some View {
        self.font(AppFont.caption(size))
            .foregroundStyle(Color.textSecondary)
    }
}
