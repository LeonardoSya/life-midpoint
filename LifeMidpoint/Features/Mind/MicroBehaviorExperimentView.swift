import SwiftUI

// P6.17-P6.22 微行为实验 (2:23170)
/// 引导式练习模板: "微行为实验"(身体/感官类)与"微情绪实验"(行动类)共用同一套
/// 分步引导 + 倒计时的练习流程 (`MicroEmotionStartView`), 靠 `id` 区分具体是哪一个.
struct GuidedPracticeTemplate {
    let id: String
    let title: String
    let steps: [String]
    let scienceNote: String
}

struct MicroBehaviorExperimentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var audio = AudioPlayer.shared
    @State private var selectedSound: String = "雨"
    @State private var templateIndex = 0
    @State private var showInfo = false
    @State private var didSwapTemplate = false

    private let soundFiles: [String: String] = [
        "海浪": AudioAssets.whiteNoiseWaves,
        "风": AudioAssets.whiteNoiseWind,
        "雨": AudioAssets.whiteNoiseRain
    ]

    private static let templates: [GuidedPracticeTemplate] = [
        GuidedPracticeTemplate(
            id: "standing_body_scan",
            title: "站立身体扫描",
            steps: [
                "站定与进入状态：找一个安静的地方站好，双脚与肩同宽，轻轻闭上眼睛。先不用做任何调整，只是让自己慢慢停下来，注意力回到身体上。",
                "感受下半身：把注意力放到双脚与小腿，感受脚底与地面的接触，留意腿部有没有不自觉的紧绷，不用改变，只是感受它。",
                "向上扫描身体：继续把注意力移动到脸部、腰部和肩膀，感受它们的状态：有没有被支撑着、肩膀是紧的还是放松的，不需要改变，只是观察。",
                "完整扫描与回到当下：从脚到头整体感受一遍身体。如果中途走神了，不用在意，只需轻轻把注意力拉回来。持续3-5分钟，然后慢慢睁开眼睛。"
            ],
            scienceNote: "身体扫描激活副交感神经系统，帮助身体从\u{201C}应激状态\u{201D}切换到\u{201C}放松状态\u{201D}，让紧绷的肌肉和情绪得到深度慢慢松开。"
        ),
        GuidedPracticeTemplate(
            id: "five_senses_grounding",
            title: "五感着陆练习",
            steps: [
                "环顾四周：慢慢说出你现在能看到的五样东西，不用刻意寻找特别的，普通的物件也可以。",
                "倾听当下：闭上眼睛，留意你能听到的三种声音，可能是风声、脚步声，或是自己的呼吸。",
                "触碰感受：用手触碰身边两样不同质感的物体，感受它们的温度与纹理。",
                "回到呼吸：做一次深长的呼吸，把注意力交还给此刻的身体，慢慢睁开眼睛。"
            ],
            scienceNote: "五感着陆通过调动感官注意力，把大脑从反复的思绪中拉回到当下，是缓解焦虑、快速平复情绪的经典技巧。"
        ),
        GuidedPracticeTemplate(
            id: "shoulder_neck_release",
            title: "肩颈放松操",
            steps: [
                "缓慢耸肩：吸气时把两侧肩膀慢慢往耳朵方向抬起，感受肩颈的紧绷。",
                "松开落下：呼气时让肩膀突然放松落下，重复三到五次。",
                "左右转头：缓慢地把头转向一侧，停留两秒，再转向另一侧，感受颈侧的拉伸。",
                "画圈舒展：让肩膀慢慢向后画圈转动几圈，想象紧张随着转动一点点释放。"
            ],
            scienceNote: "久坐或情绪紧张时，肩颈肌肉容易不自觉地绷紧。主动的伸展与放松能打断这种紧张循环，向大脑传递\u{201C}安全\u{201D}的信号。"
        )
    ]

    private var currentTemplate: GuidedPracticeTemplate { Self.templates[templateIndex] }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.mindLight, Color.mindLighter],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    experimentCard
                    changeLink
                    soundPicker
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity)
            }

            VStack {
                Spacer()
                startButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            .responsiveFill()
        }
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("午后好，\n找回内在的节奏。")
                .font(AppFont.title(26))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(4)
        }
        .padding(.top, 40)
    }

    private var experimentCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("微行为实验")
                    .font(AppFont.caption(10))
                    .foregroundStyle(Color.mindPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.mindLight, in: Capsule())

                Spacer()

                Button {
                    Haptic.light()
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textSecondary)
                }
                .buttonStyle(.plain)
            }

            Text(currentTemplate.title)
                .font(AppFont.title(22))
                .foregroundStyle(Color.textPrimary)

            Text("情景练习")
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(currentTemplate.steps.enumerated()), id: \.offset) { index, step in
                    experimentStep(index + 1, step)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 12))
                    Text("科学依据")
                        .font(AppFont.body(12))
                }
                .foregroundStyle(Color.mindPrimary)

                Text(currentTemplate.scienceNote)
                    .font(AppFont.body(11))
                    .foregroundStyle(Color.textSecondary)
                    .lineSpacing(4)
            }
            .padding(12)
            .background(Color.mindLight.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
        .alert("什么是微行为实验？", isPresented: $showInfo) {
            Button("知道了") {}
        } message: {
            Text("微行为实验是一些几分钟内就能完成的小练习，通过身体或注意力的微小调整，帮助你在当下快速缓解紧绷或波动的情绪。")
        }
    }

    private func experimentStep(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(n)")
                .font(AppFont.body(12))
                .foregroundStyle(Color.mindPrimary)
                .frame(width: 20, height: 20)
                .background(Color.mindLight, in: Circle())

            Text(text)
                .font(AppFont.body(12))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(4)
        }
    }

    private var changeLink: some View {
        Button {
            Haptic.selection()
            didSwapTemplate = true
            withAnimation(.easeInOut(duration: 0.2)) {
                templateIndex = (templateIndex + 1) % Self.templates.count
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 11))
                Text("换一个微行为实验")
                    .font(AppFont.body(13))
            }
            .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var soundPicker: some View {
        VStack(spacing: 12) {
            Text("背景环境音")
                .font(AppFont.caption(11))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)

            HStack(spacing: 12) {
                soundChip(name: "海浪", icon: "water.waves")
                soundChip(name: "风", icon: "wind")
                soundChip(name: "雨", icon: "cloud.drizzle")
            }
        }
    }

    private func soundChip(name: String, icon: String) -> some View {
        Button {
            Haptic.selection()
            selectedSound = name
            if let file = soundFiles[name] {
                audio.play(file: file, channel: .ambient, loop: true, volume: 0.5)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(name)
                    .font(AppFont.body(12))
            }
            .foregroundStyle(selectedSound == name ? .white : Color.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(selectedSound == name ? Color.mindPrimary.opacity(0.8) : Color.mindChipBg)
            )
        }
    }

    private var startButton: some View {
        NavigationLink {
            MicroEmotionStartView(
                template: currentTemplate,
                ambientSound: selectedSound,
                didSwapTemplate: didSwapTemplate
            )
        } label: {
            Text("开始任务")
                .font(AppFont.title(16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.mindPrimary, in: RoundedRectangle(cornerRadius: 28))
        }
        .simultaneousGesture(TapGesture().onEnded { Haptic.medium() })
    }
}
