import SwiftUI

/// 通用导航栏脚手架: 简化"返回 + 标题 + 右侧操作"模式
///
/// 用法:
/// ```
/// ScreenScaffold(title: "知识库", trailingIcon: "bookmark") {
///     content
/// }
/// ```
struct ScreenScaffold<Content: View>: View {
    let title: String?
    var trailingIcon: String? = nil
    var trailingAction: (() -> Void)? = nil
    var background: Color = .pageBackground
    var showBackButton: Bool = true
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(showBackButton)
            .toolbar {
                if showBackButton {
                    ToolbarItem(placement: .navigationBarLeading) {
                        BackButton()
                    }
                }
                if let title {
                    ToolbarItem(placement: .principal) {
                        Text(title).font(AppFont.title(17))
                    }
                }
                if let trailingIcon {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            Haptic.light()
                            trailingAction?()
                        } label: {
                            Image(systemName: trailingIcon)
                                .foregroundStyle(Color.textPrimary)
                        }
                    }
                }
            }
    }
}

/// 标准返回按钮
struct BackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            Haptic.light()
            dismiss()
        } label: {
            Image(systemName: "arrow.left")
                .foregroundStyle(Color.textPrimary)
        }
    }
}

/// 全屏 X 关闭按钮 (情绪选择器, 呼吸练习, 健康总览等)
struct CloseButton: View {
    @Environment(\.dismiss) private var dismiss
    var foreground: Color = .textPrimary

    var body: some View {
        Button {
            Haptic.light()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16))
                .foregroundStyle(foreground)
        }
    }
}
