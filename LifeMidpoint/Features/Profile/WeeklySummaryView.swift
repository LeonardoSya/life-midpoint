import SwiftUI

// P8.7-P8.12 周总结 (2:22455)
struct WeeklySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let variant: Int // 0/1/2 - 三种变体

    // 图表配色 (对齐 Figma 2:22455). 用计算属性, 避免影响成员初始化器.
    private var moodColor: Color { Color(hex: 0x556350) }   // 心情指数 (绿, 实线)
    private var sleepColor: Color { Color(hex: 0xFFCCC5) }  // 睡眠时长 (粉, 实线)
    private var heartColor: Color { Color(hex: 0xF5A623) }  // 平均心率 (橙, 虚线)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                titleSection
                    .padding(.top, 38)
                chartCard
                statsRow
                summaryCard
                quoteCard
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) { backButton }
    }

    /// 自定义返回按钮 (而非系统导航栏 toolbar): 页面被嵌入其他模块的
    /// NavigationStack 时, 父级会统一隐藏系统导航栏 (`.toolbar(.hidden, for: .navigationBar)`),
    /// 若返回按钮放在系统 toolbar 里会被一并隐藏、点不到, 因此这里跟其余全屏页
    /// (如 DiaryReviewView / StampAlbumView) 一样用悬浮按钮 + dismiss() 实现.
    private var backButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "arrow.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .frame(width: 38, height: 38)
        }
        .buttonStyle(.plain)
        .padding(.leading, 18)
        .padding(.top, 8)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("本周回顾")
                .font(AppFont.body(14))
                .tracking(0.35)
                .foregroundStyle(Color.textSecondary)
            Text("情绪与节奏")
                .font(AppFont.title(30))
                .tracking(-0.75)
                .foregroundStyle(Color.textPrimary)
            Text("过去一周，你的情绪呈现出平稳上升的趋势。早晨的呼吸练习显著降低了心率峰值。")
                .font(AppFont.body(16))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(6)
        }
    }

    // 折线图: 直接置于页面背景上 (设计稿无白卡)
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 0) {
                legend(color: moodColor, label: "心情指数", solid: true)
                Spacer()
                legend(color: sleepColor, label: "睡眠时长", solid: true)
                Spacer()
                legend(color: heartColor, label: "平均心率", solid: false)
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
                ctx.stroke(moodPath, with: .color(moodColor), lineWidth: 2.5)

                // Sleep line (pink, solid)
                var sleepPath = Path()
                let sleep: [CGFloat] = [0.5, 0.4, 0.6, 0.5, 0.55, 0.5, 0.55]
                for (i, p) in sleep.enumerated() {
                    let pt = CGPoint(x: CGFloat(i) * step, y: size.height * (1 - p))
                    if i == 0 { sleepPath.move(to: pt) } else { sleepPath.addLine(to: pt) }
                }
                ctx.stroke(sleepPath, with: .color(sleepColor), lineWidth: 2)

                // Heart rate (orange, dashed)
                var hrPath = Path()
                let hr: [CGFloat] = [0.35, 0.3, 0.4, 0.35, 0.3, 0.32, 0.28]
                for (i, p) in hr.enumerated() {
                    let pt = CGPoint(x: CGFloat(i) * step, y: size.height * (1 - p))
                    if i == 0 { hrPath.move(to: pt) } else { hrPath.addLine(to: pt) }
                }
                ctx.stroke(hrPath, with: .color(heartColor),
                           style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            }
            .frame(height: 200)

            HStack {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                    Text(day).font(AppFont.caption(10)).tracking(1).foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func legend(color: Color, label: String, solid: Bool) -> some View {
        HStack(spacing: 6) {
            HStack(spacing: 2) {
                Canvas { ctx, size in
                    var p = Path()
                    let midY = size.height / 2
                    p.move(to: CGPoint(x: 0, y: midY))
                    p.addLine(to: CGPoint(x: size.width, y: midY))
                    ctx.stroke(p, with: .color(color),
                               style: StrokeStyle(lineWidth: solid ? 3 : 1.5,
                                                  lineCap: .round,
                                                  dash: solid ? [] : [3, 2]))
                }
                .frame(width: 14, height: 8)
                Circle()
                    .fill(solid ? color : Color.cardBackground)
                    .overlay(Circle().stroke(color, lineWidth: solid ? 0 : 1))
                    .frame(width: solid ? 7 : 6, height: solid ? 7 : 6)
            }
            Text(label).font(AppFont.caption(12)).foregroundStyle(Color.textSecondary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            statCard(icon: "moon.fill", label: "睡眠时长", value: "7h 45m",
                     tint: Color(hex: 0x465736), background: Color.clear)
            statCard(icon: "heart.fill", label: "平均心率", value: "64 bpm",
                     tint: Color(hex: 0x43555A), background: Color(hex: 0xF8E4E1).opacity(0.5))
        }
    }

    private func statCard(icon: String, label: String, value: String, tint: Color, background: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(AppFont.caption(12)).tracking(0.6).foregroundStyle(tint)
                Text(value).font(AppFont.title(20)).foregroundStyle(tint)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: 24))
    }

    private var summaryCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color(hex: 0x495745))
                .frame(width: 39, alignment: .leading)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("周总结")
                    .font(AppFont.title(20))
                    .foregroundStyle(Color(hex: 0x495745))

                Text(variant == 0
                    ? "本周您共记录了 5 次疗愈跟练。系统监测显示，您的情绪与健康数据在本周呈现出稳步回升的趋势：周初受生理波动影响，睡眠质量与心情评分处于较低水平；随着您持续进行呼吸与触摸跟练，后半周的静息心率趋于平稳，心情记录也由焦虑逐渐缓和。请继续保持这一节奏，关注身体的每一个积极反馈。"
                    : variant == 1
                    ? "本周的规律作息让您的睡眠质量显著提升。建议保持早睡早起的节奏。"
                    : "本周情绪起伏较大，建议增加冥想和深呼吸练习以平衡自律神经。")
                    .font(AppFont.body(14))
                    .foregroundStyle(Color(hex: 0x485544))
                    .lineSpacing(6)
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, 21)
        .padding(.bottom, 25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.summaryPink, in: RoundedRectangle(cornerRadius: 40))
    }

    private var quoteCard: some View {
        Text("\u{201C}每一个小的波动都是生活呼吸的证明，保持当下的觉察，就是最好的疗愈。\u{201D}")
            .font(AppFont.body(16))
            .foregroundStyle(Color.textSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(Color(hex: 0xF3F4F3), in: RoundedRectangle(cornerRadius: 32))
    }
}
