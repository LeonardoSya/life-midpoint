import SwiftUI

// MARK: - Responsive Screen Container
//
// 解决 SwiftUI 经典布局陷阱:
//   ZStack 内 VStack + padding + maxWidth: .infinity child, 导致内容溢出屏幕.
//
// 根本原因:
//   .frame(maxWidth: .infinity) 是 "我可以撑到 infinity",
//   不会反向约束 children. 当某个 child 用 maxWidth.infinity 让父变 infinity 时,
//   再加一层 .frame(maxWidth: .infinity) 也无法压回到屏幕宽度.
//
// 真正的解决方案: 用 GeometryReader 显式锁定宽高 = 父容器实际尺寸.
//
// 使用示例:
// ```
// // 方式 A: 用 ResponsiveScreen 容器 (推荐, 新页面用)
// ResponsiveScreen {
//     LinearGradient(...)
// } content: {
//     VStack { ... }
//         .padding(.horizontal, 40)
// }
//
// // 方式 B: 直接给 VStack/HStack 加 .responsiveFill() (现有代码)
// ZStack {
//     background
//     VStack { ... }
//         .padding(.horizontal, 40)
//         .responsiveFill()           // ← 内部用 GeometryReader 锁宽高
// }
// .ignoresSafeArea()
// ```

/// 全屏页面响应式根容器: GeometryReader 强制锁定宽高 = 父容器尺寸,
/// 内部任意嵌套的 maxWidth.infinity / padding 都不会溢出.
struct ResponsiveScreen<Background: View, Content: View>: View {
    let background: Background
    let content: Content
    var ignoresSafeArea: Bool = true

    init(
        ignoresSafeArea: Bool = true,
        @ViewBuilder background: () -> Background,
        @ViewBuilder content: () -> Content
    ) {
        self.ignoresSafeArea = ignoresSafeArea
        self.background = background()
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                background
                    .frame(width: geo.size.width, height: geo.size.height)

                content
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .applyIgnoresSafeArea(ignoresSafeArea)
    }
}

// MARK: - Convenience initializers

extension ResponsiveScreen where Background == Color {
    init(
        background: Color = .pageBackground,
        ignoresSafeArea: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.background = background
        self.content = content()
        self.ignoresSafeArea = ignoresSafeArea
    }
}

// MARK: - Modifier API

extension View {
    /// 强制此视图响应式撑满父容器, 通过 GeometryReader 显式锁定宽高.
    /// 与 `.frame(maxWidth: .infinity, maxHeight: .infinity)` 的关键区别:
    /// 即使内部 children 用 maxWidth.infinity 让 layout 想要 infinity,
    /// 本 modifier 也能强制压回到父容器实际尺寸, 杜绝溢出.
    ///
    /// 适用场景:
    ///  - 紧贴 .padding() 之后, 防止 padding 撑出屏幕
    ///  - 包含 .frame(maxWidth: .infinity) 子视图的容器
    func responsiveFill() -> some View {
        modifier(ResponsiveFillModifier())
    }

    /// 仅水平方向撑满 (基于 GeometryReader 锁定宽度)
    func responsiveWidth() -> some View {
        modifier(ResponsiveWidthModifier())
    }
}

private struct ResponsiveFillModifier: ViewModifier {
    // iOS 17+ containerRelativeFrame: 强制锁定到 nearest container 的实际尺寸,
    // 即使 children 用 maxWidth.infinity 也能压回正确大小. 这是 Apple 官方推荐.
    func body(content: Content) -> some View {
        content.containerRelativeFrame([.horizontal, .vertical])
    }
}

private struct ResponsiveWidthModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.containerRelativeFrame(.horizontal)
    }
}

private extension View {
    @ViewBuilder
    func applyIgnoresSafeArea(_ apply: Bool) -> some View {
        if apply { self.ignoresSafeArea() } else { self }
    }
}
