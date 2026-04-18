import SwiftUI

// P6.25 心理卡牌展开页 (2:23268)
struct PsychologyCardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isFlipped = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.cardSandLight, Color.cardSandDark],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    cardBack
                        .opacity(isFlipped ? 0 : 1)
                        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

                    cardFront
                        .opacity(isFlipped ? 1 : 0)
                        .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                        isFlipped.toggle()
                    }
                }

                Text(isFlipped ? "再次点击翻面" : "点击卡牌查看今日指引")
                    .font(AppFont.caption(12))
                    .foregroundStyle(Color.textSecondary)

                Spacer()

                Button { dismiss() } label: {
                    Text("关闭")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(Capsule().stroke(Color.borderLight, lineWidth: 1))
                }
                .padding(.bottom, 40)
            }
            .responsiveFill()
        }
    }

    private var cardBack: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [Color.inkBrownLight, Color.inkBrownDeeper],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .frame(width: 240, height: 360)
            .overlay(
                VStack(spacing: 24) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("心 境")
                        .font(AppFont.title(32))
                        .foregroundStyle(.white.opacity(0.9))
                        .tracking(8)
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 12, y: 8)
    }

    private var cardFront: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.cardCream)
            .frame(width: 240, height: 360)
            .overlay(
                VStack(spacing: 16) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.inkBrownLight)

                    Text("今 日 指 引")
                        .font(AppFont.caption(10))
                        .foregroundStyle(Color.inkBrownLight)
                        .tracking(4)

                    Text("停 顿")
                        .font(AppFont.title(28))
                        .foregroundStyle(Color.textPrimary)
                        .tracking(12)

                    Divider().frame(width: 80)

                    Text("不是每一次疲惫都需要\n立刻被解决。\n有时候，停下来本身\n就是最好的答案。")
                        .font(AppFont.body(13))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 20)
                }
            )
            .shadow(color: .black.opacity(0.15), radius: 12, y: 8)
    }
}
