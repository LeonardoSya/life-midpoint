import SwiftUI

struct HealthDashboardView: View {
    var onMenuTap: () -> Void = {}

    @State private var path: NavigationPath = {
        #if DEBUG
        let raw = ProcessInfo.processInfo.environment["DEBUG_PUSH_HEALTH"] ?? ""
        var p = NavigationPath()
        switch raw {
        case "period": p.append(HealthRoute.period)
        case "heartRate": p.append(HealthRoute.heartRate)
        case "symptom": p.append(HealthRoute.symptom)
        case "sleep": p.append(HealthRoute.sleep)
        case "summary": p.append(HealthRoute.summary)
        case "medication": p.append(HealthRoute.medication)
        default: break
        }
        return p
        #else
        return NavigationPath()
        #endif
    }()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    healthCardsGrid
                    healthReportLink
                    medicationLink
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(Color.pageBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: HealthRoute.self) { route in
                switch route {
                case .period: PeriodTrackingView()
                case .heartRate: HeartRateView()
                case .symptom: SymptomTrackingView()
                case .symptomDetail(let name): SymptomDetailView(symptomName: name)
                case .sleep: SleepView()
                case .summary: HealthSummaryView()
                case .medication: MedicationRecordView()
                case .reminder: MedicationReminderView()
                case .myMedications: MyMedicationsView()
                }
            }
        }
    }

    enum HealthRoute: Hashable {
        case period, heartRate, symptom, symptomDetail(name: String), sleep
        case summary, medication, reminder, myMedications
    }

    private var header: some View {
        HStack {
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
            }
            Spacer()
            Text("身体数据")
                .font(AppFont.title(18))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 18)
        }
        .padding(.vertical, 8)
    }

    // MARK: - 2x2 Cards Grid

    private var healthCardsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
            NavigationLink(value: HealthRoute.period) {
                healthCard(
                    title: "经期跟踪",
                    icon: "clock.arrow.circlepath",
                    color: Color.healthPinkLight,
                    iconColor: Color.healthPink
                ) {
                    HStack(spacing: 2) {
                        ForEach(0..<10, id: \.self) { i in
                            Circle()
                                .fill(i < 5 ? Color.healthPinkDark : Color.healthPinkSoft)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            NavigationLink(value: HealthRoute.heartRate) {
                healthCard(
                    title: "静息心率",
                    icon: "heart.fill",
                    color: Color.healthPinkLight,
                    iconColor: Color.healthPink
                ) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("今日心率 66 BPM")
                            .font(AppFont.body(10))
                            .foregroundStyle(Color.textSecondary)
                        heartRateGraph
                    }
                }
            }
            .buttonStyle(.plain)

            NavigationLink(value: HealthRoute.symptom) {
                healthCard(
                    title: "症状跟踪",
                    icon: "waveform.path.ecg",
                    color: Color.chipBackgroundAlt,
                    iconColor: Color.mutedGray
                ) {
                    HStack(spacing: 8) {
                        symptomTag("潮热")
                        symptomTag("失眠")
                        symptomTag("盗汗")
                    }
                }
            }
            .buttonStyle(.plain)

            NavigationLink(value: HealthRoute.sleep) {
                healthCard(
                    title: "睡眠时长",
                    icon: "moon.fill",
                    color: Color.sleepBg,
                    iconColor: Color.sleepSecondary
                ) {
                    sleepBarChart
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func healthCard<Content: View>(
        title: String,
        icon: String,
        color: Color,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.textSecondary)
            }

            content()
        }
        .padding(16)
        .background(color, in: RoundedRectangle(cornerRadius: 20))
    }

    private func symptomTag(_ text: String) -> some View {
        Text(text)
            .font(AppFont.body(11))
            .foregroundStyle(Color.textSecondary)
    }

    private var heartRateGraph: some View {
        Path { path in
            let points: [CGFloat] = [0.5, 0.3, 0.6, 0.2, 0.7, 0.4, 0.5, 0.3, 0.6]
            let width: CGFloat = 120
            let height: CGFloat = 30
            for (i, p) in points.enumerated() {
                let x = width * CGFloat(i) / CGFloat(points.count - 1)
                let y = height * (1 - p)
                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
        }
        .stroke(Color.healthPink, lineWidth: 1.5)
        .frame(height: 30)
    }

    private var sleepBarChart: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.sleepSecondary.opacity(0.6))
                        .frame(width: 12, height: CGFloat.random(in: 15...35))
                    Text(day)
                        .font(.system(size: 7))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    // MARK: - Health Report

    private var healthReportLink: some View {
        NavigationLink(value: HealthRoute.summary) {
            healthReportCard
        }
        .buttonStyle(.plain)
    }

    private var medicationLink: some View {
        NavigationLink(value: HealthRoute.medication) {
            medicationCard
        }
        .buttonStyle(.plain)
    }

    private var healthReportCard: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.sleepBg)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.sleepSecondary)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("健康数据报告")
                    .font(AppFont.body(14))

                Text("深度睡眠不足，且呈现入睡困难与中途惊醒并存的不稳定波动；\u{201C}潮热\u{201D}及\u{201C}心悸\u{201D}症状与\u{201C}压力过载\u{201D}导致的心率加快相关；建议通过优化环境与生理调节相结合的方式进行干预...")
                    .font(AppFont.body(12))
                    .foregroundStyle(Color.textSecondary)
                    .lineSpacing(4)
                    .lineLimit(4)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(24)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Medication

    private var medicationCard: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.sleepBg)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "pills.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.sleepSecondary)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text("服药记录")
                    .font(AppFont.body(14))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                    medItem("大豆异黄酮 09:00", checked: true)
                    medItem("鱼油", checked: false)
                    medItem("雌激素制剂 11:00", checked: true)
                    medItem("褪黑素", checked: false)
                }
            }

            Image("MedicationIllustration")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
        }
        .padding(24)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
    }

    private func medItem(_ text: String, checked: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: checked ? "checkmark.square.fill" : "square")
                .font(.system(size: 10))
                .foregroundStyle(checked ? Color.sleepSecondary : Color.textSecondary)
            Text(text)
                .font(AppFont.body(9))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        }
    }
}
