import SwiftUI
import SwiftData

struct BreathingExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var phase: BreathPhase = .inhale
    @State private var scale: CGFloat = 0.6
    @State private var timer: Timer?
    @State private var showReward = false

    private let rewardStamp = StampLibrary.goldStamps[4]   // 缓缓回温

    enum BreathPhase: String {
        case inhale = "吸气 4 秒"
        case hold = "屏气 7 秒"
        case exhale = "呼气 8 秒"

        var instruction: String { "放轻松\n\(rawValue)" }

        var duration: Double {
            switch self {
            case .inhale: return 4
            case .hold: return 7
            case .exhale: return 8
            }
        }

        var next: BreathPhase {
            switch self {
            case .inhale: return .hold
            case .hold: return .exhale
            case .exhale: return .inhale
            }
        }

        var targetScale: CGFloat {
            switch self {
            case .inhale: return 1.0
            case .hold: return 1.0
            case .exhale: return 0.6
            }
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                Spacer()

                flowerAnimation
                    .scaleEffect(scale)

                Spacer()

                Text(phase.instruction)
                    .font(AppFont.body(18))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.bottom, 32)

                SlideToConfirmButton(text: "滑动离开") {
                    completePractice()
                }
                .padding(.bottom, 52)
            }
            .responsiveFill()
        }
        .navigationBarHidden(true)
        .onAppear { startBreathCycle() }
        .onDisappear { timer?.invalidate() }
        .fullScreenCover(isPresented: $showReward) {
            HealingPracticeRewardView(stamp: rewardStamp) {
                dismiss()
            }
        }
    }

    private var flowerAnimation: some View {
        ZStack {
            ForEach(0..<6) { i in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.breathBlue.opacity(0.7), Color.breathBlueDark.opacity(0.5)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 100, height: 100)
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(i) * 60))
            }
            Circle()
                .fill(Color.breathCenter.opacity(0.8))
                .frame(width: 40, height: 40)
        }
        .frame(width: 200, height: 200)
    }

    private func startBreathCycle() {
        animatePhase()
    }

    private func animatePhase() {
        withAnimation(.easeInOut(duration: phase.duration)) {
            scale = phase.targetScale
        }
        timer = Timer.scheduledTimer(withTimeInterval: phase.duration, repeats: false) { _ in
            phase = phase.next
            animatePhase()
        }
    }

    private func completePractice() {
        timer?.invalidate()
        let repo = PostOfficeRepository(context: modelContext)
        if !repo.hasStamp(definitionId: rewardStamp.id) {
            repo.grantStamp(definitionId: rewardStamp.id, source: "healing_practice")
        }
        showReward = true
    }
}

private struct HealingPracticeRewardView: View {
    let stamp: StampInfo
    let onReturn: () -> Void

    @State private var contentOpacity: Double = 0
    @State private var stampScale: CGFloat = 0.86

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.mindLighter, Color.pageBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("疗愈跟练完成!")
                    .font(AppFont.title(24))
                    .foregroundStyle(Color.textPrimary)
                    .tracking(-0.4)
                    .opacity(contentOpacity)

                Image(stamp.imageName)
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
                    onReturn()
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
        .onAppear {
            Haptic.success()
            withAnimation(.spring(response: 0.7, dampingFraction: 0.72)) {
                stampScale = 1
                contentOpacity = 1
            }
        }
    }
}
