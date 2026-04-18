import SwiftUI

/// 通用卡片容器: 圆角白底, 可选阴影
struct AppCard<Content: View>: View {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 20
    var background: Color = .cardBackground
    var hasShadow: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: hasShadow ? Color.textPrimary.opacity(0.06) : .clear,
                radius: 12, y: 8
            )
    }
}

extension View {
    /// 快速包成卡片
    func asCard(padding: CGFloat = 20,
                cornerRadius: CGFloat = 20,
                background: Color = .cardBackground,
                hasShadow: Bool = false) -> some View {
        AppCard(padding: padding,
                cornerRadius: cornerRadius,
                background: background,
                hasShadow: hasShadow) { self }
    }
}
