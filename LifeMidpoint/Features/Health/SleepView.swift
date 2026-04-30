import SwiftUI

// MARK: - 睡眠跟踪 (2:22235)

struct SleepView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HealthShell(title: "睡眠跟踪", trailingIcon: "calendar", onBack: { dismiss() }) {
            VStack(spacing: 16) {
                dateSelector
                sleepDial
                durationCard
                sleepCards
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 34)
        }
    }

    private var dateSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Text("周四").font(AppFont.title(18))
                Text("二月六日").font(AppFont.body(14)).foregroundStyle(Color.steelBlue)
            }
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 9) {
                        Circle().fill(i == 3 ? Color.white : Color(hex: 0xF5EBF8)).frame(width: 9, height: 9)
                        Text(["六", "日", "一", "二", "三", "四", "五"][i]).font(AppFont.body(12)).foregroundStyle(i == 3 ? .white : Color.steelBlue)
                        Text(["03", "04", "05", "06", "07", "08", "09"][i]).font(AppFont.body(15)).foregroundStyle(i == 3 ? .white : Color.deepCharcoal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(i == 3 ? Color(hex: 0xD7BBD7).opacity(0.9) : Color.white, in: RoundedRectangle(cornerRadius: 30))
                }
            }
        }
        .padding(.top, 14)
    }

    private var sleepDial: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: 0xF5EBF8), lineWidth: 42)
                .frame(width: 220, height: 220)
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(Color(hex: 0xD7BBD7).opacity(0.55), style: StrokeStyle(lineWidth: 42, lineCap: .round))
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-92))
            VStack(spacing: 6) {
                Text("09小时")
                    .font(AppFont.title(27))
                Text("15分")
                    .font(AppFont.body(16))
                    .foregroundStyle(Color.textSecondary)
            }
            Text("12").font(AppFont.body(15)).offset(y: -100)
            Text("3").font(AppFont.body(15)).offset(x: 102)
            Text("6").font(AppFont.body(15)).offset(y: 100)
            Text("9").font(AppFont.body(15)).offset(x: -102)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }

    private var durationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("睡眠时长").font(AppFont.title(20))
            VStack(spacing: 12) {
                HStack {
                    Circle().fill(Color(hex: 0xF5EBF8)).frame(width: 40, height: 40).overlay(Image(systemName: "bed.double").foregroundStyle(Color(hex: 0xD7BBD7)))
                    VStack(alignment: .leading, spacing: 5) {
                        Text("睡眠状态").font(AppFont.body(17))
                        Text("通常需要7-9个小时").font(AppFont.body(14)).foregroundStyle(Color.mutedGray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").frame(width: 40, height: 40).background(Color(hex: 0xD7BBD7), in: RoundedRectangle(cornerRadius: 16))
                }
                Rectangle().fill(Color.cultured).frame(height: 1)
                HStack(spacing: 8) {
                    sleepMetric(icon: "timer", value: "09", unit: "小时")
                    sleepMetric(icon: "figure.walk", value: "66", unit: "pts")
                }
            }
            .padding(16)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 30))
        }
    }

    private func sleepMetric(icon: String, value: String, unit: String) -> some View {
        HStack(spacing: 12) {
            Circle().fill(Color(hex: 0xF5EBF8)).frame(width: 40, height: 40).overlay(Image(systemName: icon).foregroundStyle(Color.steelBlue))
            Text(value).font(AppFont.body(17)) + Text(unit).font(AppFont.body(13)).foregroundColor(Color.mutedGray)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.cultured, in: RoundedRectangle(cornerRadius: 20))
    }

    private var sleepCards: some View {
        HStack(spacing: 8) {
            sleepSmallCard(icon: "bed.double", time: "10:40 AM")
            sleepSmallCard(icon: "cup.and.saucer", time: "01:40 AM")
        }
    }

    private func sleepSmallCard(icon: String, time: String) -> some View {
        HStack {
            Circle().fill(Color(hex: 0xF5EBF8)).frame(width: 39, height: 39).overlay(Image(systemName: icon).foregroundStyle(Color(hex: 0xD7BBD7)))
            Spacer()
            Image(systemName: "timer").font(.system(size: 11)).foregroundStyle(Color.steelBlue)
            Text(time).font(AppFont.body(12)).foregroundStyle(Color.steelBlue)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 82)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.cultured, lineWidth: 1))
    }
}

// MARK: - 心率 (2:22320)

struct HeartRateView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HealthShell(title: "静息心率", trailingIcon: "calendar", onBack: { dismiss() }) {
            VStack(spacing: 16) {
                periodTabs
                heartChartCard
                summaryCard
                historyRows
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
        }
    }

    private var periodTabs: some View {
        HStack(spacing: 4) {
            Text("Day").frame(maxWidth: .infinity)
            Text("Week").frame(maxWidth: .infinity).foregroundStyle(.black).background(Color(hex: 0xFFB0A4), in: Capsule())
            Text("Month").frame(maxWidth: .infinity)
        }
        .font(AppFont.body(15))
        .foregroundStyle(Color.steelBlue)
        .padding(4)
        .frame(height: 54)
        .overlay(Capsule().stroke(Color.cultured, lineWidth: 1))
    }

    private var heartChartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading) {
                    Text("二月").font(AppFont.body(17)).foregroundStyle(Color.mutedGray)
                    Text("0-120 rht").font(AppFont.body(15)).foregroundStyle(Color.mutedGray)
                }
                Spacer()
                Image(systemName: "chevron.left").frame(width: 38, height: 38).background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                Image(systemName: "chevron.right").frame(width: 38, height: 38).background(Color.white, in: RoundedRectangle(cornerRadius: 12))
            }
            HStack(spacing: 6) {
                ForEach(["Sun\n01", "Mon\n02", "Wed\n03", "Wed\n04", "Thu\n05"], id: \.self) { label in
                    Text(label)
                        .font(AppFont.body(13))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(label.contains("03") ? .white : Color.mutedGray)
                        .frame(maxWidth: .infinity, minHeight: 72)
                        .background(label.contains("03") ? Color(hex: 0xFFB0A4) : Color.white, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            ZStack {
                VStack(spacing: 29) {
                    ForEach(["120rht", "80rht", "40rht", "0rht"], id: \.self) { _ in
                Rectangle().stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3])).foregroundStyle(Color.mutedGray.opacity(0.5)).frame(height: 1)
                    }
                }
                HeartSparkline().stroke(Color.white, lineWidth: 2).frame(height: 86)
                Text("72 Rht").font(AppFont.body(12)).padding(10).background(Color(hex: 0xFFB0A4), in: RoundedRectangle(cornerRadius: 12)).offset(x: -24, y: -28)
            }
            .frame(height: 130)
        }
        .padding(18)
        .background(Color(hex: 0xF9EFED), in: RoundedRectangle(cornerRadius: 26))
    }

    private var summaryCard: some View {
        HealthInsightCard(title: "静息心率", icon: "heart") {
            Text("静息心率 72 次/分。今日心率走势平稳，较上周平均上升了 5 bpm。建议继续保持当前的运动节奏。")
        }
    }

    private var historyRows: some View {
        VStack(spacing: 8) {
            heartRow("60 Rht", date: "周日，1月15日", checked: true)
            heartRow("50 Rht", date: "周三，1月24日", checked: false)
        }
    }

    private func heartRow(_ value: String, date: String, checked: Bool) -> some View {
        HStack(spacing: 12) {
            Circle().fill(Color(hex: 0xFFB0A4)).frame(width: 42, height: 42).overlay(Image(systemName: "heart").foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 5) {
                Text(value).font(AppFont.body(19))
                Text(date).font(AppFont.body(15)).foregroundStyle(Color.steelBlue)
            }
            Spacer()
            Image(systemName: checked ? "checkmark.square.fill" : "square.fill").foregroundStyle(Color(hex: 0xFFB0A4))
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct HealthShell<Content: View>: View {
    let title: String
    let trailingIcon: String?
    let onBack: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                content()
            }
            .padding(.top, 92)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) {
            ZStack {
                Color.pageBackground.ignoresSafeArea(edges: .top).frame(height: 108)
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.mindPrimary)
                    }
                    Spacer()
                    Text(title).font(AppFont.title(24)).tracking(1.44)
                    Spacer()
                    if let trailingIcon {
                        Image(systemName: trailingIcon)
                            .font(.system(size: 14))
                            .frame(width: 39, height: 39)
                            .background(Color.white, in: Circle())
                    } else {
                        Color.clear.frame(width: 39, height: 39)
                    }
                }
                .padding(.horizontal, 34)
                .padding(.top, 42)
            }
        }
    }
}

private struct HealthInsightCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle().fill(Color(hex: 0xFFB0A4)).frame(width: 42, height: 42).overlay(Image(systemName: icon).foregroundStyle(.white))
                Text(title).font(AppFont.title(20))
            }
            content()
                .font(AppFont.body(15))
                .foregroundStyle(Color.deepCharcoal)
                .lineSpacing(4)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: 0xF9EFED), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
    }
}

private struct HeartSparkline: Shape {
    func path(in rect: CGRect) -> Path {
        let points: [CGFloat] = [0.55, 0.42, 0.58, 0.36, 0.68, 0.48, 0.50, 0.60]
        var path = Path()
        for (index, point) in points.enumerated() {
            let x = rect.minX + rect.width * CGFloat(index) / CGFloat(points.count - 1)
            let y = rect.minY + rect.height * point
            if index == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        return path
    }
}
