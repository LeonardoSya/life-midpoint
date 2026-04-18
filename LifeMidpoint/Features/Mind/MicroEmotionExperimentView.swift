import SwiftUI

// P6.23 开始-微情绪实验 (2:23467)
struct MicroEmotionStartView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.mindLighter.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Circle()
                    .fill(Color.mindPrimary.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.mindPrimary)
                    )

                VStack(spacing: 12) {
                    Text("完成一件小事")
                        .font(AppFont.title(24))
                        .foregroundStyle(Color.textPrimary)

                    Text("想想有没有一件事，你拖了很久，\n但其实5分钟就能做完？")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }

                Spacer()

                NavigationLink {
                    MicroEmotionEndView()
                } label: {
                    Text("开始实验")
                        .font(AppFont.title(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.mindPrimary, in: RoundedRectangle(cornerRadius: 28))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .responsiveFill()
        }
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .navigationBarHidden(true)
    }
}

// P6.24 结束-微情绪实验 (2:23490)
struct MicroEmotionEndView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.mindLight, Color.mindLighter],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.mindPrimary)

                VStack(spacing: 12) {
                    Text("你完成了一件小事")
                        .font(AppFont.title(24))
                        .foregroundStyle(Color.textPrimary)

                    Text("这就是改变的开始。\n恭喜你获得了一枚\u{201C}完成者\u{201D}邮票。")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Spacer()

                Button { dismiss() } label: {
                    Text("完成")
                        .font(AppFont.title(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.mindPrimary, in: RoundedRectangle(cornerRadius: 28))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .responsiveFill()
        }
        .navigationBarHidden(true)
    }
}
