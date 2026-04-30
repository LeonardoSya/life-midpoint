import SwiftUI
import SwiftData

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
    @Environment(\.modelContext) private var modelContext
    @State private var stampScale: CGFloat = 0.86
    @State private var contentOpacity: Double = 0

    private let rewardStamp = StampLibrary.goldStamps[1]   // 情绪采样者

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.mindLighter, Color.pageBackground],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("情绪实验完成!")
                    .font(AppFont.title(24))
                    .foregroundStyle(Color.textPrimary)
                    .tracking(-0.4)
                    .opacity(contentOpacity)

                Image(rewardStamp.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 178, height: 236)
                    .padding(.top, 28)
                    .scaleEffect(stampScale)
                    .opacity(contentOpacity)
                    .shadow(color: Color.textPrimary.opacity(0.08), radius: 18, y: 10)

                VStack(spacing: 12) {
                    Text("你获得了一枚新邮票")
                        .font(AppFont.title(22))
                        .foregroundStyle(Color.textPrimary)

                    Text("它已被收进你的集邮册")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary.opacity(0.72))
                }
                .padding(.top, 26)
                .opacity(contentOpacity)

                Spacer()

                Button {
                    Haptic.selection()
                    dismiss()
                } label: {
                    Text("返回")
                        .font(AppFont.body(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.mindPrimary.opacity(0.82), in: Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .opacity(contentOpacity)
            }
            .responsiveFill()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            grantRewardStampIfNeeded()
            playEntranceAnimation()
        }
    }

    private func grantRewardStampIfNeeded() {
        let repo = PostOfficeRepository(context: modelContext)
        if !repo.hasStamp(definitionId: rewardStamp.id) {
            repo.grantStamp(definitionId: rewardStamp.id, source: "micro_emotion_experiment")
        }
    }

    private func playEntranceAnimation() {
        Haptic.success()
        withAnimation(.spring(response: 0.7, dampingFraction: 0.72)) {
            stampScale = 1
            contentOpacity = 1
        }
    }
}
