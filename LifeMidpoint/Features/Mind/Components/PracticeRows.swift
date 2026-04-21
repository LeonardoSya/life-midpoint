import SwiftUI

/// 心境 - 疗愈跟练 + 微情绪实验 双 ROW 区
struct PracticeAndExperimentSection: View {
    // 卡片宽度自适应字体宽度, 避免标题被截断 ("疗愈跟练" / "微情绪实验" 4-5 字)
    private static let moduleCardWidth: CGFloat = 130

    var body: some View {
        VStack(spacing: 19) {
            HStack(spacing: 11) {
                NavigationLink(value: MindHomeView.MindRoute.breathing) {
                    ModuleCard(title: "疗愈跟练", icon: "waveform.path")
                        .frame(width: Self.moduleCardWidth)
                }
                .buttonStyle(.plain)

                NavigationLink(value: MindHomeView.MindRoute.breathing) {
                    RecentPracticeCard()
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 11) {
                NavigationLink(value: MindHomeView.MindRoute.microEmotion) {
                    ModuleCard(title: "微情绪实验", icon: "arrow.triangle.2.circlepath")
                        .frame(width: Self.moduleCardWidth)
                }
                .buttonStyle(.plain)

                NavigationLink(value: MindHomeView.MindRoute.microBehavior) {
                    TodayExperimentCard()
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ModuleCard: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mintMistBg)
                .frame(width: 61, height: 48)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.mindPrimary)
                )

            Text(title)
                .titleStyle(15)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(25)
        .frame(height: 162, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.mintMistBg)
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.5), lineWidth: 1))
        )
    }
}

private struct RecentPracticeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("我最近的跟练")
                .font(AppFont.title(14))
                .padding(.bottom, 4)

            PracticeItem(name: "4-7-8呼吸法",
                         desc: "高效平复神经系统，即时缓解潮热与心悸带来的燥动感。",
                         duration: "5分钟")
            PracticeItem(name: "情绪安抚触摸",
                         desc: "通过轻柔的身体触碰释放压力，重塑内心的安全感与宁静。",
                         duration: "5分钟")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 162)
        .background(Color.white.opacity(0.47), in: RoundedRectangle(cornerRadius: 32))
    }
}

private struct PracticeItem: View {
    let name: String
    let desc: String
    let duration: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(name).font(AppFont.title(10))
                Spacer()
                Text(duration)
                    .font(AppFont.body(5))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 6).padding(.vertical, 4)
                    .background(Color.mintMistAlt, in: RoundedRectangle(cornerRadius: 10))
            }
            Text(desc)
                .font(AppFont.body(8.6))
                .lineLimit(1)
        }
        .padding(10)
        .background(.white, in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct TodayExperimentCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("情绪实验｜今日推荐")
                .font(AppFont.title(14))
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("完成一件小事").font(AppFont.title(10))

                Text("想想有没有一件事，你拖了很久，但其实5分钟就能做完？\n拖延往往带来自我否定，而完成一件小事能带来多巴胺分泌，提升自我效能感，打破\u{201C}什么都做不好\u{201D}的消极循环。")
                    .font(AppFont.body(9))
                    .lineSpacing(2)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(12)
            .background(.white, in: RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 162)
        .background(Color.white.opacity(0.47), in: RoundedRectangle(cornerRadius: 32))
    }
}
