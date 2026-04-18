import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppStateManager
    @StateObject private var audio = AudioPlayer.shared
    @State private var currentStep = 0
    @State private var musicStarted = false

    var body: some View {
        ZStack {
            ForEach(Array(onboardingSteps.enumerated()), id: \.offset) { index, step in
                if index == currentStep {
                    OnboardingStepView(
                        step: step,
                        onNext: { advanceStep() },
                        onComplete: { completeOnboarding() }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeIn(duration: 0.6)),
                        removal: .opacity.animation(.easeOut(duration: 0.4))
                    ))
                }
            }

            VStack {
                Spacer()
                if onboardingSteps[currentStep].ctaText == nil {
                    progressIndicator
                        .padding(.bottom, 50)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            playAudioForStep(currentStep)
        }
        .onDisappear {
            audio.stopAll()
        }
    }

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<onboardingSteps.count, id: \.self) { index in
                Circle()
                    .fill(index == currentStep ? Color.white : Color.white.opacity(0.4))
                    .frame(width: index == currentStep ? 8 : 6,
                           height: index == currentStep ? 8 : 6)
            }
        }
    }

    private func advanceStep() {
        guard currentStep < onboardingSteps.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep += 1
        }
        playAudioForStep(currentStep)
    }

    private func completeOnboarding() {
        audio.stopAll()
        appState.completeOnboarding()
    }

    /// 音频播放策略:
    /// - Step 1 (index 0): intro_step1 (下班音效) on voice channel
    /// - Step 2 (index 1): intro_step2 (走路声) on voice channel
    /// - Step 3 (index 2): intro_step3 (叹气声) on voice channel
    /// - Step 4+ (index 3+): intro_music 持续播放在 music channel
    private func playAudioForStep(_ index: Int) {
        // 播放该步骤的旁白音效 (1-3)
        if let voiceFile = AudioAssets.voiceForOnboardingStep(index) {
            audio.play(file: voiceFile, channel: .voice, loop: false, volume: 0.9)
        }

        // 从 Step 4 开始确保背景音乐在播
        if index >= 3 && !musicStarted {
            audio.play(file: AudioAssets.introMusic, channel: .music, loop: true, volume: 0.5)
            musicStarted = true
        }
    }
}
