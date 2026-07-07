import SwiftUI

struct HealthDashboardView: View {
    var onBackToDiary: (() -> Void)? = nil
    var useOwnNavigationStack = true

    @Environment(\.dismiss) private var dismiss
    @State private var path: NavigationPath = {
        #if DEBUG
        let raw = ProcessInfo.processInfo.environment["DEBUG_PUSH_HEALTH"] ?? ""
        var p = NavigationPath()
        switch raw {
        case "period": p.append(HealthRoute.period)
        case "heartRate": p.append(HealthRoute.heartRate)
        case "symptom": p.append(HealthRoute.symptom)
        case "symptomDetail": p.append(HealthRoute.symptomDetail(name: "潮热"))
        case "sleep": p.append(HealthRoute.sleep)
        case "summary": p.append(HealthRoute.summary)
        case "medication": p.append(HealthRoute.medication)
        case "editReminder": p.append(HealthRoute.editReminder)
        default: break
        }
        return p
        #else
        return NavigationPath()
        #endif
    }()

    var body: some View {
        if useOwnNavigationStack {
            NavigationStack(path: $path) {
                content
                    .navigationDestination(for: HealthRoute.self) { route in
                        healthDestination(route)
                    }
            }
        } else {
            content
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 21) {
                header

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())],
                    spacing: 12
                ) {
                    NavigationLink(value: HealthRoute.period) { periodCard }.buttonStyle(.plain)
                    NavigationLink(value: HealthRoute.heartRate) { heartRateCard }.buttonStyle(.plain)
                    NavigationLink(value: HealthRoute.symptom) { symptomCard }.buttonStyle(.plain)
                    NavigationLink(value: HealthRoute.sleep) { sleepCard }.buttonStyle(.plain)
                }

                NavigationLink(value: HealthRoute.summary) { reportCard }.buttonStyle(.plain)
                NavigationLink(value: HealthRoute.medication) { medicationCard }.buttonStyle(.plain)
            }
            .padding(.horizontal, 17)
            .padding(.top, 8)
            .padding(.bottom, 36)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    func healthDestination(_ route: HealthRoute) -> some View {
        switch route {
        case .period: PeriodTrackingView()
        case .heartRate: HeartRateView()
        case .symptom: SymptomTrackingView()
        case .symptomDetail(let name): SymptomDetailView(symptomName: name)
        case .sleep: SleepView()
        case .summary: HealthSummaryView()
        case .medication: MedicationRecordView()
        case .reminder: MedicationReminderView()
        case .editReminder: EditReminderView()
        case .myMedications: MyMedicationsView()
        }
    }

    enum HealthRoute: Hashable {
        case period, heartRate, symptom, symptomDetail(name: String), sleep
        case summary, medication, reminder, editReminder, myMedications
    }

    private var header: some View {
        ZStack {
            HStack {
                Button {
                    Haptic.light()
                    if let onBackToDiary {
                        onBackToDiary()
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 38, height: 38)
                }
                .buttonStyle(.plain)
                Spacer()
            }

            Text("身体数据")
                .font(AppFont.title(24))
                .foregroundStyle(Color.textPrimary)
                .tracking(1.44)
        }
        .frame(height: 42)
    }

    private var periodCard: some View {
        HealthFeatureCard(
            title: "经期跟踪",
            icon: "timer",
            iconTint: .white,
            iconBg: Color(hex: 0xFF9181),
            bg: Color(hex: 0xF8ECEA),
            contentAlignment: .center
        ) {
            VStack(alignment: .leading, spacing: 6) {
                Text("经期第 5 天 · 距下次 23 天")
                    .font(AppFont.body(10))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(alignment: .center, spacing: 4) {
                    ForEach(0..<7, id: \.self) { index in
                        if index == 4 {
                            periodDayMarker
                        } else {
                            Capsule()
                                .fill(Color.white)
                                .frame(width: 14, height: 44)
                                .overlay(alignment: .bottom) {
                                    Capsule()
                                        .fill(Color(hex: 0xF3A5BD))
                                        .frame(width: 7, height: CGFloat([24, 18, 30, 20, 28, 35, 14][index]))
                                        .padding(.bottom, 4)
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var periodDayMarker: some View {
        VStack(spacing: 3) {
            Circle()
                .fill(Color(hex: 0xF3A5BD))
                .frame(width: 5, height: 5)
            WaterDropShape()
                .stroke(Color(hex: 0xF3A5BD), lineWidth: 2)
                .frame(width: 24, height: 34)
                .overlay(alignment: .bottom) {
                    Text("5")
                        .font(AppFont.numeric(12))
                        .foregroundStyle(Color(hex: 0xF3A5BD))
                        .padding(.bottom, 6)
                }
        }
        .frame(width: 24, height: 48, alignment: .bottom)
    }

    private var heartRateCard: some View {
        HealthFeatureCard(title: "静息心率", icon: "heart", iconTint: .white, iconBg: Color(hex: 0xFF9D96), bg: Color(hex: 0xF8ECEA)) {
            VStack(alignment: .leading, spacing: 5) {
                Text("今日心率 66 BPM")
                    .font(AppFont.body(10))
                    .foregroundStyle(Color.textSecondary)
                HeartLineGraph()
                    .stroke(Color.healthPink.opacity(0.55), lineWidth: 2)
                    .frame(height: 32)
            }
            .padding(8)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var symptomCard: some View {
        HealthFeatureCard(
            title: "症状跟踪",
            icon: "sun.max",
            iconTint: .white,
            iconBg: Color(hex: 0xD7BBD7),
            bg: Color(hex: 0xF7F1F8),
            contentAlignment: .center
        ) {
            HStack(spacing: 8) {
                ForEach(["潮\n热", "失\n眠", "盗\n汗"], id: \.self) { symptom in
                    Text(symptom)
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .frame(width: 38, height: 64)
                        .background(Color.white, in: Capsule())
                }
            }
        }
    }

    private var sleepCard: some View {
        HealthFeatureCard(
            title: "睡眠时长",
            icon: "bed.double",
            iconTint: .white,
            iconBg: Color(hex: 0xD7BBD7),
            bg: Color(hex: 0xF7F1F8),
            contentAlignment: .center
        ) {
            VStack(alignment: .leading, spacing: 6) {
                Text("昨晚 9 小时 · 评分 66")
                    .font(AppFont.body(10))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array([18, 30, 23, 20, 34, 24, 16].enumerated()), id: \.offset) { index, height in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(index == 4 ? Color(hex: 0xB9A1E8) : Color(hex: 0xC9BEEA).opacity(0.55))
                                .frame(width: 12, height: CGFloat(height))
                            Text(["一", "二", "三", "四", "五", "六", "日"][index])
                                .font(AppFont.body(7))
                                .foregroundStyle(Color.textSecondary.opacity(0.7))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var reportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color(hex: 0x7BC5E2))
                    .frame(width: 42, height: 42)
                    .overlay(Image(systemName: "scope").foregroundStyle(.white))
                Text("健康数据报告")
                    .font(AppFont.title(18))
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 13))
            }

            Text("深度睡眠不足，且呈现入睡困难与中途惊醒并存的不稳定波动；“潮热”及“心悸”症状与“压力过载”导致的心率加快相关；建议通过优化环境与生理调节相结合的方式进行干预...")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(4)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 4))
                .lineLimit(4)
                .padding(.leading, 16)
        }
        .padding(20)
        .background(Color(hex: 0xE9F6FB), in: RoundedRectangle(cornerRadius: 24))
    }

    private var medicationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color(hex: 0x7BC5E2))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "pills.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                Text("服药记录")
                    .font(AppFont.title(18))
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 13))
            }

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    medMini("大豆异黄酮", time: "09:00", done: true)
                    medMini("雌激素制剂", time: "11:00", done: true)
                    medMini("鱼油", time: nil, done: false)
                    medMini("褪黑素", time: nil, done: false)
                }
                Spacer(minLength: 6)
                Image("MedicationIllustration")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 4))
            .padding(.leading, 16)
        }
        .padding(20)
        .background(Color(hex: 0xE9F6FB), in: RoundedRectangle(cornerRadius: 24))
    }

    private func medMini(_ name: String, time: String?, done: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: done ? "checkmark.square.fill" : "square.fill")
                .font(.system(size: 15))
                .foregroundStyle(done ? Color(hex: 0x7BC5E2) : Color.gray.opacity(0.38))
            Text(displayMedicationLabel(name: name, time: time))
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
        }
    }

    private func displayMedicationLabel(name: String, time: String?) -> String {
        guard let time else { return name }
        return "\(name) \(time)"
    }
}

private struct HealthFeatureCard<Content: View>: View {
    let title: String
    let icon: String
    let iconTint: Color
    let iconBg: Color
    let bg: Color
    var contentAlignment: Alignment = .leading
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 10) {
                Circle()
                    .fill(iconBg)
                    .frame(width: 36, height: 36)
                    .overlay(Image(systemName: icon).font(.system(size: 15)).foregroundStyle(iconTint))

                Text(title)
                    .font(AppFont.title(15))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .layoutPriority(1)

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
            }

            content()
                .frame(maxWidth: .infinity, alignment: contentAlignment)
        }
        .padding(14)
        .frame(height: 148, alignment: .topLeading)
        .background(bg, in: RoundedRectangle(cornerRadius: 18))
    }
}

/// 水滴形状: 顶部尖角, 底部圆形, 用于经期当日标记.
private struct WaterDropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let cx = rect.midX
        let r = w / 2
        let cy = rect.maxY - r
        path.move(to: CGPoint(x: cx, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: cy),
            control: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.32)
        )
        path.addArc(
            center: CGPoint(x: cx, y: cy),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addQuadCurve(
            to: CGPoint(x: cx, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.32)
        )
        path.closeSubpath()
        return path
    }
}

private struct HeartLineGraph: Shape {
    func path(in rect: CGRect) -> Path {
        let points: [CGFloat] = [0.52, 0.45, 0.50, 0.47, 0.48, 0.62, 0.41, 0.42, 0.55, 0.54]
        var path = Path()
        for (index, p) in points.enumerated() {
            let x = rect.minX + rect.width * CGFloat(index) / CGFloat(points.count - 1)
            let y = rect.minY + rect.height * p
            if index == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        return path
    }
}
