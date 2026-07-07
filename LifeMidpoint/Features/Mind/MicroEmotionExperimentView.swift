import SwiftUI
import SwiftData

/// "微情绪实验"入口(拖延主题)默认使用的模板, 让 `MicroEmotionStartView()` 无参调用
/// 时也有定制化内容, 而不是复用"微行为实验"的身体扫描文案.
private let completeOneSmallThingTemplate = GuidedPracticeTemplate(
    id: "complete_one_small_thing",
    title: "完成一件小事",
    steps: [
        "想一想：花10秒想一件你拖延已久、但其实几分钟就能做完的小事——回一条消息、洗一个杯子、整理一下桌面都可以。",
        "只做眼前这一步：先不用想着\u{201C}做完\u{201D}，只专注开始的第一个动作，比如\u{201C}打开那条消息\u{201D}或\u{201C}拿起杯子\u{201D}。",
        "真正去做：现在就去完成这件小事，不用追求完美，做到能让自己停下来的程度即可。",
        "感受完成：做完之后，留意一下身体和情绪的变化——那种小小的轻松感，就是多巴胺在起作用。"
    ],
    scienceNote: "拖延常常伴随自我否定，而哪怕只是完成一件微小的事，也能激活大脑的奖赏回路、分泌多巴胺，提升自我效能感，帮助打破\u{201C}什么都做不好\u{201D}的消极循环。"
)

// P6.23 开始-微情绪实验 (2:23467) — 沉浸式分步引导练习页
/// 按 `template.steps` 逐步引导, 每步有节奏倒计时, 最后一步才允许"滑动完成实验".
/// 同时承载 `MicroBehaviorExperimentView`("微行为实验") 与 Mind 首页"微情绪实验"两个入口,
/// 靠 `template` 区分具体内容, 靠 `MicroBehaviorSession` 记录一次完整练习.
struct MicroEmotionStartView: View {
    let template: GuidedPracticeTemplate
    let ambientSound: String
    let didSwapTemplate: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var stepIndex = 0
    @State private var secondsRemaining: Int
    @State private var goToEnd = false
    @State private var session: MicroBehaviorSession?

    init(template: GuidedPracticeTemplate = completeOneSmallThingTemplate,
         ambientSound: String = "雨", didSwapTemplate: Bool = false) {
        self.template = template
        self.ambientSound = ambientSound
        self.didSwapTemplate = didSwapTemplate
        _secondsRemaining = State(initialValue: Self.stepDuration(for: template))
    }

    var body: some View {
        ZStack {
            immersiveBackground

            VStack(spacing: 0) {
                Spacer()

                stepProgress
                    .padding(.bottom, 28)

                instructionText
                    .id(stepIndex)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))

                Text(countdownLabel)
                    .font(AppFont.body(14))
                    .tracking(4.2)
                    .foregroundStyle(Color(hex: 0x777B7B).opacity(0.8))
                    .padding(.top, 32)

                Spacer()
            }
            .responsiveFill()

            VStack {
                Spacer()
                bottomControl
                    .padding(.bottom, 49)
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
        .navigationDestination(isPresented: $goToEnd) {
            MicroEmotionEndView()
        }
        .onAppear {
            guard session == nil else { return }
            session = MindRepository(context: modelContext).startMicroBehavior(
                templateId: template.id, ambient: ambientSound, didSwapTemplate: didSwapTemplate
            )
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard secondsRemaining > 0 else { return }
            secondsRemaining -= 1
            if secondsRemaining == 0 && stepIndex < template.steps.count - 1 {
                Haptic.light()
                advanceStep()
            }
        }
    }

    private var immersiveBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xF9F9F8), Color(hex: 0xFDFCF6), Color(hex: 0xF3F4F3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            Ellipse()
                .fill(Color.mindAccent.opacity(0.6))
                .frame(width: 234, height: 442)
                .blur(radius: 60)
                .offset(x: -130, y: -170)
            Circle()
                .fill(Color.warmGradientBottom.opacity(0.3))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: 130, y: 300)
        }
        .ignoresSafeArea()
    }

    private var stepProgress: some View {
        VStack(spacing: 10) {
            Text("第 \(stepIndex + 1) / \(template.steps.count) 步 · \(template.title)")
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary.opacity(0.7))
            HStack(spacing: 6) {
                ForEach(0..<template.steps.count, id: \.self) { i in
                    Capsule()
                        .fill(i <= stepIndex ? Color.mindPrimary : Color.mindPrimary.opacity(0.18))
                        .frame(width: i == stepIndex ? 22 : 8, height: 6)
                }
            }
        }
    }

    private var instructionText: some View {
        Text(template.steps[stepIndex])
            .font(AppFont.body(17))
            .foregroundStyle(Color.textSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(5)
            .frame(width: 280)
            .animation(.easeInOut(duration: 0.3), value: stepIndex)
    }

    @ViewBuilder
    private var bottomControl: some View {
        if stepIndex < template.steps.count - 1 {
            Button {
                Haptic.light()
                advanceStep()
            } label: {
                Text("下一步")
                    .font(AppFont.title(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.mindPrimary, in: Capsule())
            }
            .padding(.horizontal, 24)
        } else {
            SlideToConfirmButton(text: "滑动完成实验") { finish() }
                .padding(.horizontal, 24)
        }
    }

    private var countdownLabel: String {
        String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    private func advanceStep() {
        guard stepIndex < template.steps.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            stepIndex += 1
        }
        secondsRemaining = Self.stepDuration(for: template)
    }

    private func finish() {
        if let session {
            MindRepository(context: modelContext).completeMicroBehavior(session)
        }
        goToEnd = true
    }

    /// 按步骤数把整体 3 分钟左右的练习均分到每一步, 单步不少于 30 秒.
    private static func stepDuration(for template: GuidedPracticeTemplate) -> Int {
        max(30, Int((180.0 / Double(max(template.steps.count, 1))).rounded()))
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
