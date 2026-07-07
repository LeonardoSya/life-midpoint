import SwiftUI

// P3.28 情绪详细记录页 / "情绪识别弹窗2" (2:23397)
struct EmotionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let emotion: String
    /// 在"情绪识别门"中使用: 点击底部"不了，我想自己看看"时关闭整个门进入心境首页.
    /// 为 nil 时(日记/心境内的普通 push)沿用 `dismiss()`.
    var onFinish: (() -> Void)?

    private var content: EmotionContent { EmotionLibrary.content(for: emotion) }

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    header
                    analysisCard
                    experimentCard
                    breathingCard
                    footer
                }
                .padding(.horizontal, 24)
                .padding(.top, 64)
                .padding(.bottom, 80)
                .frame(maxWidth: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) { backButton }
    }

    private var backButton: some View {
        AppBackButton { dismiss() }
        .padding(.leading, 18)
        .padding(.top, 8)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 20) {
            ZStack {
                Capsule()
                    .fill(Color.mintGreenLight.opacity(0.3))
                    .frame(width: 80, height: 64)
                Image(systemName: content.icon)
                    .font(.system(size: 26))
                    .foregroundStyle(Color.mindMuted)
            }

            Text("\(content.headlineLine1)\n\(content.headlineLine2)")
                .font(AppFont.title(24))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .tracking(-0.6)

            Text(content.allowedLine)
                .font(AppFont.body(16))
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Gentle Knowledge Card

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(content.signalTitle)
                .font(AppFont.title(20))
                .foregroundStyle(Color.mindPrimary)

            Text(content.signalBody)
                .font(AppFont.body(18))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(8)
        }
        .padding(40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFCFFFA), in: RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Micro Experience Card

    private var experimentCard: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                    Text("试试这个微行为实验")
                        .font(AppFont.title(18))
                }
                .foregroundStyle(Color.postReceivedInk.opacity(0.8))

                Text(content.microBody)
                    .font(AppFont.body(18))
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(8)
            }

            VStack(spacing: 16) {
                NavigationLink {
                    MicroBehaviorExperimentView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                        Text("前往微行为实验")
                            .font(AppFont.body(18))
                    }
                    .foregroundStyle(Color.mindAccent)
                    .frame(height: 64)
                    .padding(.horizontal, 40)
                    .background(Color.mindPrimary.opacity(0.8), in: Capsule())
                }

                experimentFootnote
            }
            .frame(maxWidth: .infinity)
        }
        .padding(41)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.textPlaceholder.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.textPrimary.opacity(0.04), radius: 16, y: 12)
    }

    // MARK: - Healing Practice Card

    private var breathingCard: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("可以跟着做一会儿")
                    .font(AppFont.title(24))
                    .foregroundStyle(Color(hex: 0x514736))

                Text("一段柔和的呼吸引导，带你回到当下的宁静。")
                    .font(AppFont.body(18))
                    .foregroundStyle(Color(hex: 0x6E6351))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }

            VStack(spacing: 16) {
                NavigationLink {
                    BreathingExerciseView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                        Text("开始练习")
                            .font(AppFont.body(18))
                    }
                    .foregroundStyle(Color.mindAccent)
                    .frame(height: 64)
                    .padding(.horizontal, 40)
                    .background(Color.mindPrimary.opacity(0.8), in: Capsule())
                }

                experimentFootnote
            }
        }
        .frame(maxWidth: .infinity)
        .padding(49)
        .background(
            LinearGradient(
                colors: [Color(hex: 0xFCFFFA), Color.pageBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 40)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.warmGradientTop.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 5, y: 4)
    }

    private var experimentFootnote: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .font(.system(size: 11))
            Text("预计时长 3–5分钟")
                .font(AppFont.body(14))
        }
        .foregroundStyle(Color(hex: 0x6E6351, alpha: 0.5))
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 16) {
            skipButton

            Circle()
                .fill(Color.textPlaceholder.opacity(0.3))
                .frame(width: 6, height: 6)

            Text("愿此刻的你，能感受到内心的平静")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private var skipButton: some View {
        Button {
            if let onFinish { onFinish() } else { dismiss() }
        } label: {
            Text("不了，我想自己看看")
                .font(AppFont.body(16))
                .foregroundStyle(Color.mindAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.mindPrimary.opacity(0.8), in: Capsule())
        }
    }
}
