import SwiftUI

struct BreathingExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phase: BreathPhase = .inhale
    @State private var scale: CGFloat = 0.6
    @State private var timer: Timer?

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
                    .padding(.bottom, 80)
            }
            .responsiveFill()
        }
        .navigationBarHidden(true)
        .onAppear { startBreathCycle() }
        .onDisappear { timer?.invalidate() }
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
}
