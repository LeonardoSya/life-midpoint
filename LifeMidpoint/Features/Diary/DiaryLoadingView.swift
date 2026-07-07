import SwiftUI

/// 日记生成加载态 (Figma 2:20663 日记页-加载).
///
/// 设计稿里加载态延续日记主页的暖色海边背景, 中央浮现一个柔和的
/// "思考中" 玻璃气泡, 而不是突兀的纯色 spinner. 这里复用 DiaryView
/// 的背景层, 保证生成日记时画面过渡自然.
struct DiaryLoadingView: View {
    @State private var dotCount = 1

    var body: some View {
        ZStack {
            background

            Text("正在整理你的心声" + String(repeating: ".", count: dotCount))
                .font(AppFont.body(16))
                .foregroundStyle(Color.textSecondary)
                .padding(.horizontal, 30)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.45))
                )
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.16)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 24, y: 12)
        }
        .ignoresSafeArea()
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 380_000_000)
                dotCount = dotCount % 3 + 1
            }
        }
    }

    private var background: some View {
        ZStack {
            Color.pageBackground

            LinearGradient(
                colors: [
                    Color.warmGradientTop.opacity(0.5),
                    Color.pageBackground.opacity(0.5),
                    Color.warmGradientBottom.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image("DiaryBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.5)
        }
        .ignoresSafeArea()
    }
}
