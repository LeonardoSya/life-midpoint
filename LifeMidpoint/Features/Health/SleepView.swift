import SwiftUI

// P7.14-P7.15 睡眠 (2:22235)
struct SleepView: View {
    @Environment(\.dismiss) private var dismiss

    private let days = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                summaryCard
                weeklyChart
                qualityCard
            }
            .padding(24)
        }
        .background(Color.sleepBg.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: { Image(systemName: "arrow.left").foregroundStyle(Color.textPrimary) }
            }
            ToolbarItem(placement: .principal) { Text("睡眠时长").font(AppFont.title(17)) }
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("昨晚").font(AppFont.caption(10)).foregroundStyle(Color.textSecondary)
                Text("7h 45m").font(AppFont.title(22))
            }
            Divider()
            VStack(alignment: .leading, spacing: 4) {
                Text("本周平均").font(AppFont.caption(10)).foregroundStyle(Color.textSecondary)
                Text("7h 12m").font(AppFont.title(22))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周睡眠").font(AppFont.caption(11)).foregroundStyle(Color.textSecondary)

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                    VStack(spacing: 4) {
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.sleepPrimary)
                                .frame(height: CGFloat.random(in: 10...40))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.sleepSecondary)
                                .frame(height: CGFloat.random(in: 20...50))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.sleepLight)
                                .frame(height: CGFloat.random(in: 10...25))
                        }
                        .frame(width: 20)
                        Text(day).font(AppFont.caption(10)).foregroundStyle(Color.textSecondary)
                    }
                }
            }

            HStack(spacing: 12) {
                legend(color: Color.sleepPrimary, label: "深睡")
                legend(color: Color.sleepSecondary, label: "浅睡")
                legend(color: Color.sleepLight, label: "REM")
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private func legend(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(AppFont.caption(10)).foregroundStyle(Color.textSecondary)
        }
    }

    private var qualityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("睡眠质量").font(AppFont.body(14))
                Spacer()
                Text("78 分").font(AppFont.title(18)).foregroundStyle(Color.sleepPrimary)
            }
            Text("深睡不足，建议晚上 11 点前就寝，避免睡前使用电子设备。")
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }
}

// P7.16-P7.17 心率 (2:22320)
struct HeartRateView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                currentCard
                trendCard
                zonesCard
            }
            .padding(24)
        }
        .background(Color.healthPinkLight.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: { Image(systemName: "arrow.left").foregroundStyle(Color.textPrimary) }
            }
            ToolbarItem(placement: .principal) { Text("静息心率").font(AppFont.title(17)) }
        }
    }

    private var currentCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今日静息心率").font(AppFont.caption(11)).foregroundStyle(Color.textSecondary)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("66").font(AppFont.title(42))
                Text("BPM").font(AppFont.body(14)).foregroundStyle(Color.textSecondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("近 7 天趋势").font(AppFont.caption(11)).foregroundStyle(Color.textSecondary)

            Canvas { ctx, size in
                let points: [CGFloat] = [0.5, 0.3, 0.6, 0.4, 0.7, 0.5, 0.4]
                let step = size.width / CGFloat(points.count - 1)
                var path = Path()
                for (i, p) in points.enumerated() {
                    let pt = CGPoint(x: CGFloat(i) * step, y: size.height * (1 - p))
                    if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
                }
                ctx.stroke(path, with: .color(Color.healthPink), lineWidth: 2)
            }
            .frame(height: 80)
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var zonesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("心率区间").font(AppFont.caption(11)).foregroundStyle(Color.textSecondary)
            HStack {
                zoneItem("静息", "58-68", Color.mindMuted)
                zoneItem("轻度", "68-100", Color.summaryDecoration)
                zoneItem("中度", "100-140", Color.healthPink)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private func zoneItem(_ label: String, _ range: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(AppFont.body(12))
            Text(range).font(AppFont.caption(10)).foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
