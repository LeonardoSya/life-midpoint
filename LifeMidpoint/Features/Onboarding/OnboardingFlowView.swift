import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppStateManager
    @StateObject private var audio = AudioPlayer.shared

    @State private var currentStep: Int = OnboardingFlowView.initialStep()
    @State private var musicStarted = false
    @State private var beachAmbientStarted = false

    // 对话气泡 / 分屏揭示的"放行"开关: 仅当本页完全呈现(转场/渐变全部结束)后才置 true,
    // 保证所有对话框都在"当前页完全加载完毕之后"才出现。
    @State private var pageReady = false

    // 转场用的全屏纯色遮罩: 第一页黑场渐亮 / 第3→4黑场 / 第10-12白闪
    @State private var coverColor: Color = .black
    @State private var coverOpacity: Double = OnboardingFlowView.initialStep() == 0 ? 1.0 : 0.0
    @State private var isTransitioning = false

    private static func initialStep() -> Int {
        #if DEBUG
        if let raw = ProcessInfo.processInfo.environment["DEBUG_ONBOARDING_STEP"],
           let i = Int(raw), (0..<onboardingSteps.count).contains(i) {
            return i
        }
        #endif
        return 0
    }

    var body: some View {
        ZStack {
            ForEach(Array(onboardingSteps.enumerated()), id: \.offset) { index, step in
                if index == currentStep {
                    OnboardingStepView(
                        step: step,
                        isActive: pageReady,
                        onNext: { advanceStep() },
                        onComplete: { completeOnboarding() }
                    )
                    .transition(pageTransition(for: step))
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

            // 全屏转场遮罩 (置于最上层). 仅在转场期间拦截点击, 平时透明且不挡手势.
            Rectangle()
                .fill(coverColor)
                .ignoresSafeArea()
                .opacity(coverOpacity)
                .allowsHitTesting(isTransitioning)
        }
        .onAppear {
            playAudioForStep(currentStep)
            if currentStep == 0 {
                runInitialBlackFadeIn()
            } else {
                // 调试直达任意页: 无转场遮罩, 直接放行揭示
                coverOpacity = 0
                DispatchQueue.main.async { pageReady = true }
            }
            #if DEBUG
            scheduleAutoAdvanceIfNeeded()
            #endif
        }
        .onDisappear {
            audio.stopAll()
        }
    }

    // MARK: - 第一页: 全黑渐渐变亮

    private func runInitialBlackFadeIn() {
        isTransitioning = true
        coverColor = .black
        coverOpacity = 1.0
        withAnimation(.easeInOut(duration: 1.2)) { coverOpacity = 0.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isTransitioning = false
            pageReady = true   // 首页完全变亮后再放行(本页无对话, 仅为一致性)
        }
    }

    #if DEBUG
    /// 通过 SIMCTL_CHILD_DEBUG_AUTO_ADVANCE=<seconds> 启动后, 每 N 秒自动 advanceStep 一次,
    /// 用于自动化验证整段流转无死锁 / 卡死.
    private func scheduleAutoAdvanceIfNeeded() {
        guard let raw = ProcessInfo.processInfo.environment["DEBUG_AUTO_ADVANCE"],
              let interval = Double(raw), interval > 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if onboardingSteps[currentStep].ctaText != nil {
                completeOnboarding()
            } else {
                advanceStep()
                scheduleAutoAdvanceIfNeeded()
            }
        }
    }
    #endif

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

    // MARK: - 翻页 + 转场

    /// 每页的插入/移除转场。注意: 这里不内嵌 `.animation(...)`,
    /// 转场是否动画、时长多少, 完全由触发切页处的 `withAnimation` 决定:
    /// - 普通翻页: 包在 `withAnimation` 里 → 交叉淡变;
    /// - 纯色(黑/白)转场: 在白幕下用"无动画事务"瞬切 → 旧图瞬间消失、新图瞬间就位,
    ///   褪色时只显示下一张, 不残留上一张。
    /// 分屏页(第7页)插入用 `.identity`, 保证下半屏从第一帧即纯黑、不被淡入稀释闪出底图。
    private func pageTransition(for step: OnboardingStep) -> AnyTransition {
        if step.revealStyle == .splitTopBottom {
            return .asymmetric(insertion: .identity, removal: .opacity)
        }
        return .opacity
    }

    private func advanceStep() {
        guard !isTransitioning, currentStep < onboardingSteps.count - 1 else { return }
        let from = currentStep
        let to = from + 1
        pageReady = false   // 切页前先收起对话, 待新页完全呈现后再放行

        switch transition(leaving: from) {
        case .black:
            // 第3页 → 第4页: 渐黑 → 停留 1 秒 → 渐亮 → 完全变亮后才播放第4页音乐并放行对话
            performColorTransition(color: .black, fadeIn: 0.6, hold: 1.0, fadeOut: 0.6,
                                   to: to, deferMusic: true) {
                startMusicIfNeeded()
                pageReady = true
            }
        case .white:
            // 第10-12页: 渐渐变纯白 → 停留 0.5 秒 → 由白渐渐显出下一张图, 完全显出后才放行对话
            performColorTransition(color: .white, fadeIn: 0.5, hold: 0.5, fadeOut: 0.5, to: to) {
                pageReady = true
            }
        case .none:
            if onboardingSteps[to].revealStyle == .splitTopBottom {
                // 分屏页瞬切: 上半立即可见、下半第一帧即纯黑(不经淡入, 避免黑遮罩被稀释闪出底图),
                // 随后由本页自身的揭示序列(0.5s 显下半 → 再 0.5s 出文字)推进。
                currentStep = to
                playAudioForStep(to)
                DispatchQueue.main.async { pageReady = true }
            } else {
                withAnimation(.easeInOut(duration: 0.5)) { currentStep = to }
                playAudioForStep(to)
                // 淡入(0.6s)结束、本页完全显出后再放行对话
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { pageReady = true }
            }
        }
    }

    private enum StepTransition { case none, black, white }

    /// 离开某页时使用的转场效果 (页码 = index + 1).
    /// 第10-12页的换图用白闪: index 9(第10)→10(第11), 10(第11)→11(第12), 12("突然"分镜)→13(海边).
    /// index 11→12 是第12页内部"兔子逃脱→突然"同图换字, 用普通淡入淡出, 不白闪.
    private func transition(leaving from: Int) -> StepTransition {
        switch from {
        case 2:           return .black   // 第3页 → 第4页: 1 秒黑场
        case 9, 10, 12:   return .white   // 第10-12页换到下一张图: 渐白再渐显
        default:          return .none
        }
    }

    /// 通用纯色转场: 当前画面渐渐被 color 覆盖 →(可选)停留 hold 秒 → 在遮罩下切到目标页 → 渐渐褪色显出.
    /// - deferMusic: 切页时不立刻启动背景音乐, 留给 onArrive 在完全显出后再播 (第4页音乐需求).
    /// - onArrive: 完全褪色(画面完全显现)后回调.
    private func performColorTransition(
        color: Color, fadeIn: Double, hold: Double, fadeOut: Double,
        to: Int, deferMusic: Bool = false, onArrive: (() -> Void)? = nil
    ) {
        isTransitioning = true
        coverColor = color
        withAnimation(.easeInOut(duration: fadeIn)) { coverOpacity = 1.0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + fadeIn + hold) {
            // 在纯色全覆盖下"瞬切"目标页: 禁用动画 → 旧图瞬间消失、新图瞬间满屏就位,
            // 这样接下来褪色时只会显示下一张, 不会残留正在淡出的上一张。
            var instant = Transaction()
            instant.disablesAnimations = true
            withTransaction(instant) { currentStep = to }
            playAudioForStep(to, deferMusic: deferMusic)
            withAnimation(.easeInOut(duration: fadeOut)) { coverOpacity = 0.0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOut) {
                isTransitioning = false
                onArrive?()
            }
        }
    }

    private func completeOnboarding() {
        audio.stopAll()
        appState.completeOnboarding()
    }

    // MARK: - 音频

    /// 音频播放策略 (页码 = index + 1):
    /// - 第1页 (index 0): intro_step1 (下班音效), 配合黑场渐亮
    /// - 第2页 (index 1): intro_step2 (脚步声), 循环播放 3 次
    /// - 第3页 (index 2): intro_step3 (叹气声)
    /// - 第4页起 (index 3+): intro_music 持续循环 (第3→4黑场完全变亮后才启动)
    /// - 第13-14页 (index 13+, 海边): 停掉延续的 intro_music, 仅保留 whitenoise_waves (海浪/海鸥)
    private func playAudioForStep(_ index: Int, deferMusic: Bool = false) {
        // 旁白音效 (前 3 页): 第 2 页脚步声循环 3 次 (loops = 2 → 共播放 3 遍)
        // 这几个声效源文件本身偏轻, 用满音量 1.0 让它们比背景音乐更突出。
        if let voiceFile = AudioAssets.voiceForOnboardingStep(index) {
            audio.play(file: voiceFile, channel: .voice, loops: index == 1 ? 2 : 0, volume: 1.0)
        }

        // 第13-14页: 停掉从第4页延续的背景音乐, 只保留海边环境音
        if index >= 13 {
            audio.stop(channel: .music)
            musicStarted = true
            startBeachAmbientIfNeeded()
            return
        }

        // 第4页起确保背景音乐在播 (第3→4黑场转场会延迟到完全变亮后再启动)
        if index >= 3 && !deferMusic {
            startMusicIfNeeded()
        }
    }

    private func startMusicIfNeeded() {
        guard !musicStarted else { return }
        audio.play(file: AudioAssets.introMusic, channel: .music, loop: true, volume: 0.5)
        musicStarted = true
    }

    private func startBeachAmbientIfNeeded() {
        guard !beachAmbientStarted else { return }
        audio.play(file: AudioAssets.whiteNoiseWaves, channel: .ambient, loop: true, volume: 0.6)
        beachAmbientStarted = true
        // 注: 第14页"海鸥声"素材未包含在打包内 (仅 13-14海浪声.MP3);
        //     补充 海鸥声 文件后可在 index == 14 时叠加到其它通道。
    }
}
