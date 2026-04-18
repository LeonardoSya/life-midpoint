import SwiftUI

// P3.28 情绪详细记录页 (2:23397)
struct EmotionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let emotion: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.mindLight, Color.mindLighter],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    analysisCard
                    experimentCard
                    breathingCard
                    skipButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 48)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(Color.mindPrimary.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.mindPrimary)
                )

            Text("你今天似乎有一点\(emotion)，\n也有些低落。")
                .font(AppFont.title(18))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("没关系，这种感觉是被允许的。")
                .font(AppFont.body(13))
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("疲惫是一个信号。")
                .font(AppFont.title(16))
                .foregroundStyle(Color.textPrimary)

            Text("当心灵感到超负荷时，它会通过疲惫来请求一个停顿。这并不是虚弱，而是身体在提醒你，现在的你比以往任何时候都更需要温柔的关怀。")
                .font(AppFont.body(13))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var experimentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11))
                Text("试试这个微行为实验")
                    .font(AppFont.body(12))
            }
            .foregroundStyle(Color.textSecondary)

            Text("闭上眼睛，试着在脑海中列出三个此刻让你感到沉重的小事。不用去解决它们，只需在大脑中轻轻地对它们说一声：\u{201C}我知道了，辛苦了。\u{201D}")
                .font(AppFont.body(13))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(6)

            NavigationLink {
                MicroBehaviorExperimentView()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 11))
                    Text("前往微行为实验")
                        .font(AppFont.body(14))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.mindPrimary, in: Capsule())
            }

            Text("预计耗时 3-5分钟")
                .font(AppFont.caption(10))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var breathingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("可以跟着做一会儿")
                .font(AppFont.title(16))
                .foregroundStyle(Color.textPrimary)

            Text("一段柔和的呼吸引导，带你回到当下的宁静。")
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary)

            NavigationLink {
                BreathingExerciseView()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 11))
                    Text("开始练习")
                        .font(AppFont.body(14))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.mindPrimary, in: Capsule())
            }

            Text("预计耗时 3-5分钟")
                .font(AppFont.caption(10))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var skipButton: some View {
        Button { dismiss() } label: {
            Text("不了，我想自己看看")
                .font(AppFont.body(14))
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Color.mindPrimary, in: Capsule())
        }
        .frame(maxWidth: .infinity)
    }
}
