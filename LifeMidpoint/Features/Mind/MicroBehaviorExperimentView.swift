import SwiftUI

// P6.17-P6.22 微行为实验 (2:23170)
struct MicroBehaviorExperimentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audio = AudioPlayer.shared
    @State private var selectedSound: String = "雨"

    private let soundFiles: [String: String] = [
        "海浪": AudioAssets.whiteNoiseWaves,
        "风": AudioAssets.whiteNoiseWind,
        "雨": AudioAssets.whiteNoiseRain
    ]

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
                    .padding(.bottom, 40)
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

                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
            }

            Text("站立身体扫描")
                .font(AppFont.title(22))
                .foregroundStyle(Color.textPrimary)

            Text("情景练习")
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary)

            VStack(alignment: .leading, spacing: 10) {
                experimentStep(1, "站定与进入状态：找一个安静的地方站好，双脚与肩同宽，轻轻闭上眼睛。先不用做任何调整，只是让自己慢慢停下来，注意力回到身体上。")
                experimentStep(2, "站定与进入状态：找一个安静的地方站好，双脚与肩同宽，轻轻闭上眼睛。先不用做任何调整，只是让自己慢慢停下来，注意力回到身体上。")
                experimentStep(3, "向上扫描身体：继续把注意力移动到脸部、腰部和肩膀，感受它们的状态：有没有被支撑着、肩膀是紧的还是放松的，不需要改变，只是观察。")
                experimentStep(4, "完整扫描与回到当下：从脚到头整体感受一遍身体。如果中途走神了，不用在意，只需轻轻把注意力拉回来。持续3-5分钟，然后慢慢睁开眼睛。")
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 12))
                    Text("科学依据")
                        .font(AppFont.body(12))
                }
                .foregroundStyle(Color.mindPrimary)

                Text("身体扫描激活副交感神经系统，帮助身体从\u{201C}应激状态\u{201D}切换到\u{201C}放松状态\u{201D}，让紧绷的肌肉和情绪得到深度慢慢松开。")
                    .font(AppFont.body(11))
                    .foregroundStyle(Color.textSecondary)
                    .lineSpacing(4)
            }
            .padding(12)
            .background(Color.mindLight.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
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
            MicroEmotionEndView()
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
