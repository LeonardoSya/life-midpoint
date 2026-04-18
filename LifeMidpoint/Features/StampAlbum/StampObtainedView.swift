import SwiftUI

// P5.15-P5.16 获得邮票弹窗 (2:22745)
struct StampObtainedView: View {
    @Environment(\.dismiss) private var dismiss

    /// 可选: 指定具体邮票。默认用 StampObtainedImage 占位
    let stampImageName: String

    init(stampImageName: String = "StampObtainedImage") {
        self.stampImageName = stampImageName
    }

    @State private var stampScale: CGFloat = 0.3
    @State private var stampOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            background

            VStack(spacing: 36) {
                Spacer()

                Image(stampImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 316, height: 420)
                    .rotationEffect(.degrees(-0.27))
                    .scaleEffect(stampScale)
                    .opacity(stampOpacity)
                    .shadow(color: .black.opacity(0.2), radius: 24, y: 12)

                VStack(spacing: 12) {
                    Text("你获得了一枚邮票")
                        .font(AppFont.title(24))
                        .foregroundStyle(Color.textPrimary)
                        .tracking(-0.6)

                    Text("它已被收进你的集邮册")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary.opacity(0.8))
                        .tracking(0.35)
                }
                .opacity(textOpacity)

                Spacer()

                Button { dismiss() } label: {
                    Text("好的")
                        .font(AppFont.body(16))
                        .foregroundStyle(Color.mindPrimary)
                        .underline()
                }
                .padding(.bottom, 60)
                .opacity(textOpacity)
            }
            .responsiveFill()
        }
        .onAppear { playAnimation() }
    }

    private var background: some View {
        ZStack {
            Color.pageBackground
            RadialGradient(
                colors: [Color.warmGradientTop.opacity(0.4), .clear],
                center: .topLeading, startRadius: 0, endRadius: 500
            )
            RadialGradient(
                colors: [Color.warmGradientHot.opacity(0.1), .clear],
                center: .topTrailing, startRadius: 0, endRadius: 500
            )
            RadialGradient(
                colors: [Color.stampShineYellow.opacity(0.15), .clear],
                center: .init(x: 0.2, y: 0.3), startRadius: 0, endRadius: 280
            )
        }
        .ignoresSafeArea()
    }

    private func playAnimation() {
        Haptic.success()
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
            stampScale = 1.0
            stampOpacity = 1.0
        }
        withAnimation(.easeIn(duration: 0.5).delay(0.6)) {
            textOpacity = 1.0
        }
    }
}
