import SwiftUI

// P8.7-P8.12 周总结 (2:22455)
struct WeeklySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let variant: Int // 0/1/2 - 三种变体

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                titleSection
                chartCard
                statsRow
                summaryCard
                quoteCard
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: { Image(systemName: "arrow.left").foregroundStyle(Color.textPrimary) }
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("本周回顾").font(AppFont.caption(11)).foregroundStyle(Color.textSecondary)
            Text("情绪与节奏").font(AppFont.title(28))
            Text("过去一周，你的情绪呈现出平稳上升的趋势。早晨的呼吸练习显著降低了心率峰值。")
                .font(AppFont.body(13))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(6)
        }
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                legend(color: Color.mindPrimary, label: "心情指数", solid: true)
                legend(color: Color.healthPinkSoft, label: "睡眠时长", solid: true)
                legend(color: Color.summaryDecoration, label: "平均心率", solid: false)
            }

            Canvas { ctx, size in
                let days: CGFloat = 7
                let step = size.width / days

                // Mood line (green, solid)
                var moodPath = Path()
                let mood: [CGFloat] = [0.3, 0.4, 0.5, 0.45, 0.6, 0.7, 0.75]
                for (i, p) in mood.enumerated() {
                    let pt = CGPoint(x: CGFloat(i) * step, y: size.height * (1 - p))
                    if i == 0 { moodPath.move(to: pt) } else { moodPath.addLine(to: pt) }
                }
                ctx.stroke(moodPath, with: .color(Color.mindPrimary), lineWidth: 2.5)

                // Sleep line (pink, solid)
                var sleepPath = Path()
                let sleep: [CGFloat] = [0.5, 0.4, 0.6, 0.5, 0.55, 0.5, 0.55]
                for (i, p) in sleep.enumerated() {
                    let pt = CGPoint(x: CGFloat(i) * step, y: size.height * (1 - p))
                    if i == 0 { sleepPath.move(to: pt) } else { sleepPath.addLine(to: pt) }
                }
                ctx.stroke(sleepPath, with: .color(Color.healthPinkSoft), lineWidth: 2)

                // Heart rate (yellow, dashed)
                var hrPath = Path()
                let hr: [CGFloat] = [0.35, 0.3, 0.4, 0.35, 0.3, 0.32, 0.28]
                for (i, p) in hr.enumerated() {
                    let pt = CGPoint(x: CGFloat(i) * step, y: size.height * (1 - p))
                    if i == 0 { hrPath.move(to: pt) } else { hrPath.addLine(to: pt) }
                }
                ctx.stroke(hrPath, with: .color(Color.summaryDecoration),
                           style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            }
            .frame(height: 180)

            HStack {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                    Text(day).font(AppFont.caption(10)).foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private func legend(color: Color, label: String, solid: Bool) -> some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 2)
            Text(label).font(AppFont.caption(10)).foregroundStyle(Color.textSecondary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(icon: "moon.fill", label: "睡眠时长", value: "7h 45m", color: Color.sleepSecondary)
            statCard(icon: "heart.fill", label: "平均心率", value: "64 bpm", color: Color.healthPink)
        }
    }

    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(AppFont.caption(10)).foregroundStyle(Color.textSecondary)
                Text(value).font(AppFont.title(16))
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb").font(.system(size: 12)).foregroundStyle(Color.mindPrimary)
                Text("周总结").font(AppFont.body(13))
            }

            Text(variant == 0
                ? "本周您共记录了 5 次疗愈跟练。系统监测显示，您的情绪与健康数据在本周呈现出稳步向上的趋势：周初可能生理波动影响，睡眠质量与心情评分处于较低水平；随着您持续进行呼吸与触摸跟练，后半周的静息心率趋于平稳，心情记录由焦虑逐渐转稳。请继续保持这一节奏，关注身体的每一个积极反馈。"
                : variant == 1
                ? "本周的规律作息让您的睡眠质量显著提升。建议保持早睡早起的节奏。"
                : "本周情绪起伏较大，建议增加冥想和深呼吸练习以平衡自律神经。")
                .font(AppFont.body(13))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.summaryPink, in: RoundedRectangle(cornerRadius: 20))
    }

    private var quoteCard: some View {
        Text("\u{201C}每一个小的波动都是生活呼吸的证明，保持当下的觉察，就是最好的疗愈。\u{201D}")
            .font(AppFont.body(14))
            .foregroundStyle(Color.textPrimary)
            .multilineTextAlignment(.center)
            .italic()
            .lineSpacing(6)
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }
}
