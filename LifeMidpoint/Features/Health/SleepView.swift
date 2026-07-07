import SwiftUI

// MARK: - 睡眠跟踪 (2:22235)

struct SleepView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var anchorDate = Calendar.current.startOfDay(for: Date())
    @State private var entries: [SleepDay] = []
    @State private var showEditSheet = false
    @State private var showStageDetail = false
    @State private var draftBedTime = Date()
    @State private var draftWakeTime = Date()
    @State private var isDraggingBed = false
    @State private var isDraggingWake = false

    /// 表盘环形半径, 与 `sleepDial` 中 220pt 直径的圆保持一致.
    private let dialRadius: CGFloat = 110

    private var repo: HealthRepository { HealthRepository(context: modelContext) }

    var body: some View {
        HealthShell(title: "睡眠跟踪", trailingIcon: "calendar", onBack: { dismiss() }, onTrailingTap: {
            showEditSheet = true
        }) {
            VStack(spacing: 16) {
                dateSelector
                sleepDial
                durationCard
                sleepCards
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 34)
        }
        .onAppear {
            refreshEntries()
            prepareDraft()
        }
        .onChange(of: anchorDate) { _, _ in prepareDraft() }
        .sheet(isPresented: $showEditSheet) { editSheet }
        .sheet(isPresented: $showStageDetail) { stageDetailSheet }
    }

    // MARK: - 日期选择

    private var dateSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Text(weekdayTitle).font(AppFont.title(18))
                Text(monthDayTitle).font(AppFont.body(14)).foregroundStyle(Color.steelBlue)
            }
            HStack(spacing: 4) {
                ForEach(weekStripDates, id: \.self) { date in
                    dayCell(date)
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let calendar = Calendar.current
        let selected = calendar.isDate(date, inSameDayAs: anchorDate)
        let isFuture = date > Date()
        let weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]
        let weekdayLabel = weekdaySymbols[calendar.component(.weekday, from: date) - 1]
        let dayLabel = String(format: "%02d", calendar.component(.day, from: date))
        return Button {
            Haptic.light()
            anchorDate = calendar.startOfDay(for: date)
        } label: {
            VStack(spacing: 9) {
                Circle().fill(selected ? Color.white : Color(hex: 0xF5EBF8)).frame(width: 9, height: 9)
                Text(weekdayLabel).font(AppFont.body(12)).foregroundStyle(selected ? .white : Color.steelBlue)
                Text(dayLabel).font(AppFont.body(15)).foregroundStyle(selected ? .white : Color.deepCharcoal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .opacity(isFuture ? 0.4 : 1)
            .background(selected ? Color(hex: 0xD7BBD7).opacity(0.9) : Color.white, in: RoundedRectangle(cornerRadius: 30))
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }

    // MARK: - 表盘 (可拖动的 24 小时环形入睡/起床选择器)

    private var sleepDial: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: 0xF5EBF8), lineWidth: 42)
                .frame(width: dialRadius * 2, height: dialRadius * 2)
            Circle()
                .trim(from: 0, to: arcSpan)
                .stroke(Color(hex: 0xD7BBD7).opacity(0.55), style: StrokeStyle(lineWidth: 42, lineCap: .round))
                .frame(width: dialRadius * 2, height: dialRadius * 2)
                .rotationEffect(.degrees(Double(bedFraction) * 360 - 90))
            VStack(spacing: 6) {
                Text("\(draftDurationMinutes / 60)小时")
                    .font(AppFont.title(27))
                Text("\(draftDurationMinutes % 60)分")
                    .font(AppFont.body(16))
                    .foregroundStyle(Color.textSecondary)
                if !hasRecord {
                    Text("拖动图标调整")
                        .font(AppFont.body(11))
                        .foregroundStyle(Color.textSecondary.opacity(0.8))
                }
            }
            // 24 小时刻度: 0 点在正上方, 顺时针依次为 6/12/18 点.
            Text("0").font(AppFont.body(15)).offset(y: -dialRadius + 10)
            Text("6").font(AppFont.body(15)).offset(x: dialRadius - 8)
            Text("12").font(AppFont.body(15)).offset(y: dialRadius - 10)
            Text("18").font(AppFont.body(15)).offset(x: -dialRadius + 10)

            dialMarker(icon: "moon.fill", fraction: bedFraction, isDragging: isDraggingBed)
                .gesture(dragGesture(isBed: true))

            dialMarker(icon: "sun.max.fill", fraction: wakeFraction, isDragging: isDraggingWake)
                .gesture(dragGesture(isBed: false))
        }
        .frame(width: dialRadius * 2, height: dialRadius * 2)
        .coordinateSpace(name: "sleepDial")
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }

    /// 圆环上的入睡/起床拖动手柄. 位置严格按 `fraction` (0...1, 0=正上方/顺时针) 落在
    /// 圆环中心线上, 保证与背景环对齐, 不再是之前写死的偏移量.
    private func dialMarker(icon: String, fraction: CGFloat, isDragging: Bool) -> some View {
        Circle()
            .fill(Color(hex: 0xD7BBD7))
            .frame(width: isDragging ? 36 : 30, height: isDragging ? 36 : 30)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
            )
            .shadow(color: Color.black.opacity(isDragging ? 0.2 : 0), radius: 5, y: 2)
            .offset(markerOffset(for: fraction))
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isDragging)
            .contentShape(Circle().inset(by: -10))
    }

    /// 拖动手柄的手势: 拖动时实时按角度换算成时间并刷新表盘; 松手时如果几乎没有
    /// 位移则视为点击 (打开精确编辑弹窗), 否则视为拖动完成 (直接保存新时间).
    private func dragGesture(isBed: Bool) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("sleepDial"))
            .onChanged { value in
                if isBed {
                    if !isDraggingBed { isDraggingBed = true; Haptic.light() }
                    draftBedTime = applyTimeFraction(clockFraction(at: value.location), to: draftBedTime)
                } else {
                    if !isDraggingWake { isDraggingWake = true; Haptic.light() }
                    draftWakeTime = applyTimeFraction(clockFraction(at: value.location), to: draftWakeTime)
                }
            }
            .onEnded { value in
                let moved = hypot(value.translation.width, value.translation.height) > 4
                if isBed { isDraggingBed = false } else { isDraggingWake = false }
                if moved {
                    Haptic.success()
                    commitDraft()
                } else {
                    Haptic.light()
                    showEditSheet = true
                }
            }
    }

    /// 手柄在圆环上的位置 (以表盘中心为原点的偏移量). `fraction` 0 对应正上方, 顺时针增大.
    private func markerOffset(for fraction: CGFloat) -> CGSize {
        let angle = Double(fraction) * 2 * .pi
        return CGSize(width: dialRadius * CGFloat(sin(angle)), height: -dialRadius * CGFloat(cos(angle)))
    }

    /// 将拖动落点 (相对于 "sleepDial" 坐标空间, 原点在左上角) 转换为 0...1 的时间比例.
    private func clockFraction(at location: CGPoint) -> CGFloat {
        let dx = Double(location.x - dialRadius)
        let dy = Double(location.y - dialRadius)
        var angle = atan2(dx, -dy)
        if angle < 0 { angle += 2 * .pi }
        return CGFloat(angle / (2 * .pi))
    }

    /// 用 0...1 的时间比例替换 `date` 的时:分, 保留其原有的"天" (拖动只改时间点, 不改天).
    private func applyTimeFraction(_ fraction: CGFloat, to date: Date) -> Date {
        let totalMinutes = Int((fraction * 24 * 60).rounded())
        let snapped = (max(0, min(1439, totalMinutes)) / 5) * 5
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        return calendar.date(bySettingHour: snapped / 60, minute: snapped % 60, second: 0, of: dayStart) ?? date
    }

    // MARK: - 时长卡片

    private var durationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("睡眠时长").font(AppFont.title(20))
            VStack(spacing: 12) {
                Button {
                    Haptic.light()
                    showStageDetail = true
                } label: {
                    HStack {
                        Circle().fill(Color(hex: 0xF5EBF8)).frame(width: 40, height: 40).overlay(Image(systemName: "bed.double").foregroundStyle(Color(hex: 0xD7BBD7)))
                        VStack(alignment: .leading, spacing: 5) {
                            Text("睡眠状态").font(AppFont.body(17)).foregroundStyle(Color.deepCharcoal)
                            Text(sleepStatusSubtitle).font(AppFont.body(14)).foregroundStyle(Color.mutedGray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color(hex: 0xD7BBD7), in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .buttonStyle(.plain)
                Rectangle().fill(Color.cultured).frame(height: 1)
                HStack(spacing: 8) {
                    sleepMetric(icon: "timer", value: hoursText, unit: "小时") {
                        showEditSheet = true
                    }
                    sleepMetric(icon: "moon.zzz.fill", value: scoreText, unit: "pts") {
                        showStageDetail = true
                    }
                }
            }
            .padding(16)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 30))
        }
    }

    private func sleepMetric(icon: String, value: String, unit: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptic.light()
            action()
        } label: {
            HStack(spacing: 12) {
                Circle().fill(Color(hex: 0xF5EBF8)).frame(width: 40, height: 40).overlay(Image(systemName: icon).foregroundStyle(Color.steelBlue))
                Text(value).font(AppFont.body(17)).foregroundStyle(Color.deepCharcoal) + Text(unit).font(AppFont.body(13)).foregroundColor(Color.mutedGray)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.cultured, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private var sleepCards: some View {
        HStack(spacing: 8) {
            sleepSmallCard(icon: "bed.double", time: bedTimeText) {
                showEditSheet = true
            }
            sleepSmallCard(icon: "cup.and.saucer", time: wakeTimeText) {
                showEditSheet = true
            }
        }
    }

    private func sleepSmallCard(icon: String, time: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptic.light()
            action()
        } label: {
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
        .buttonStyle(.plain)
    }

    // MARK: - 编辑弹窗

    private var editSheet: some View {
        NavigationStack {
            Form {
                DatePicker("入睡时间", selection: $draftBedTime, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                DatePicker("起床时间", selection: $draftWakeTime, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                HStack {
                    Text("本次睡眠时长")
                    Spacer()
                    Text("\(draftDurationMinutes / 60)小时\(draftDurationMinutes % 60)分").foregroundStyle(Color.textSecondary)
                }
            }
            .navigationTitle("记录睡眠")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        prepareDraft()
                        showEditSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Haptic.success()
                        commitDraft()
                        showEditSheet = false
                    }
                }
            }
        }
        .presentationDetents([.height(320)])
    }

    // MARK: - 睡眠状态详情

    private var stageDetailSheet: some View {
        let breakdown = stageBreakdown
        return NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("睡眠质量 \(previewScore) 分")
                        .font(AppFont.title(20))
                    Text(qualityComment(previewScore))
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.mutedGray)
                }
                VStack(spacing: 10) {
                    stageRow(label: "深睡", minutes: breakdown.deep, total: breakdown.total, color: Color(hex: 0x6E5A9E))
                    stageRow(label: "浅睡", minutes: breakdown.light, total: breakdown.total, color: Color(hex: 0xD7BBD7))
                    stageRow(label: "REM", minutes: breakdown.rem, total: breakdown.total, color: Color(hex: 0xFFB0A4))
                }
                if !hasRecord {
                    Text("以上为按当前入睡/起床时间估算的分布，拖动圆环手柄或保存后会持续记录真实数据。")
                        .font(AppFont.body(12))
                        .foregroundStyle(Color.mutedGray)
                }
                Spacer()
            }
            .padding(24)
            .navigationTitle("睡眠状态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { showStageDetail = false }
                }
            }
        }
        .presentationDetents([.height(400)])
    }

    /// 深睡/浅睡/REM 分布. 已有记录时用持久化数据; 否则按当前拖动出的时长实时估算.
    private var stageBreakdown: (deep: Int, light: Int, rem: Int, total: Int) {
        if let entry = selectedEntry, !isDraggingBed, !isDraggingWake {
            return (entry.deepMinutes, entry.lightMinutes, entry.remMinutes, entry.totalMinutes)
        }
        let total = draftDurationMinutes
        let deep = Int(Double(total) * 0.22)
        let light = Int(Double(total) * 0.55)
        let rem = max(0, total - deep - light)
        return (deep, light, rem, total)
    }

    private func stageRow(label: String, minutes: Int, total: Int, color: Color) -> some View {
        let fraction = total > 0 ? CGFloat(minutes) / CGFloat(total) : 0
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label).font(AppFont.body(14)).foregroundStyle(Color.deepCharcoal)
                Spacer()
                Text("\(minutes)分钟").font(AppFont.body(13)).foregroundStyle(Color.mutedGray)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.cultured)
                    Capsule().fill(color).frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - 数据

    private func refreshEntries() {
        entries = repo.recentSleep(days: 30)
    }

    private func entry(on date: Date) -> SleepDay? {
        entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private var selectedEntry: SleepDay? { entry(on: anchorDate) }

    /// 当前选中日是否已有真实持久化记录 (区别于表盘的默认/拖动中预览值).
    private var hasRecord: Bool { selectedEntry != nil }

    private func prepareDraft() {
        let calendar = Calendar.current
        if let entry = selectedEntry, let bed = entry.bedTime, let wake = entry.wakeTime {
            draftBedTime = bed
            draftWakeTime = wake
        } else {
            let dayStart = calendar.startOfDay(for: anchorDate)
            draftWakeTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: dayStart) ?? dayStart
            draftBedTime = calendar.date(byAdding: .day, value: -1, to: dayStart)
                .flatMap { calendar.date(bySettingHour: 23, minute: 0, second: 0, of: $0) } ?? dayStart
        }
        isDraggingBed = false
        isDraggingWake = false
    }

    /// 将当前拖动/表单中的入睡+起床时间写入 SwiftData.
    private func commitDraft() {
        let minutes = draftDurationMinutes
        let deep = Int(Double(minutes) * 0.22)
        let light = Int(Double(minutes) * 0.55)
        let rem = max(0, minutes - deep - light)
        let score = min(100, max(40, 100 - abs(480 - minutes) / 4))
        repo.upsertSleep(
            date: draftWakeTime, totalMinutes: minutes, deep: deep, light: light, rem: rem,
            score: score, bedTime: draftBedTime, wakeTime: draftWakeTime
        )
        refreshEntries()
    }

    private func durationMinutes(bed: Date, wake: Date) -> Int {
        let raw = Int(wake.timeIntervalSince(bed) / 60)
        return raw > 0 ? raw : raw + 24 * 60
    }

    private var draftDurationMinutes: Int { durationMinutes(bed: draftBedTime, wake: draftWakeTime) }

    private func qualityComment(_ score: Int) -> String {
        switch score {
        case 85...: return "睡眠质量很好，继续保持当前作息。"
        case 70..<85: return "睡眠质量还不错，可以再多留意深睡时长。"
        default: return "睡眠质量偏低，建议提前入睡、减少睡前用屏时间。"
        }
    }

    private var hoursText: String { String(format: "%02d", draftDurationMinutes / 60) }

    /// 已有记录且未在拖动时展示持久化质量分, 否则按当前时长实时估算.
    private var previewScore: Int {
        if let entry = selectedEntry, !isDraggingBed, !isDraggingWake {
            return entry.qualityScore
        }
        return min(100, max(40, 100 - abs(480 - draftDurationMinutes) / 4))
    }

    private var scoreText: String { "\(previewScore)" }

    private var sleepStatusSubtitle: String {
        hasRecord ? "质量 \(previewScore) 分 · 点击查看深浅睡分布" : "拖动圆环上的图标设置入睡与起床时间"
    }

    private var bedTimeText: String { formattedClock(draftBedTime) }

    private var wakeTimeText: String { formattedClock(draftWakeTime) }

    private func formattedClock(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: date)
    }

    /// 入睡/起床时间在 24 小时表盘上的位置比例 (0...1, 0=正上方=0点, 顺时针增大).
    private func timeFraction(_ date: Date) -> CGFloat {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = Double(comps.hour ?? 0) + Double(comps.minute ?? 0) / 60.0
        return CGFloat(hour / 24.0)
    }

    private var bedFraction: CGFloat { timeFraction(draftBedTime) }
    private var wakeFraction: CGFloat { timeFraction(draftWakeTime) }

    /// 从入睡到起床, 顺时针跨过的表盘弧长比例 (处理跨过 0 点的情况).
    private var arcSpan: CGFloat {
        let raw = wakeFraction - bedFraction
        return raw >= 0 ? raw : raw + 1
    }

    private var weekdayTitle: String {
        let weekdaySymbols = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        return weekdaySymbols[Calendar.current.component(.weekday, from: anchorDate) - 1]
    }

    private var monthDayTitle: String {
        let monthNames = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
        let comps = Calendar.current.dateComponents([.month, .day], from: anchorDate)
        return "\(monthNames[max(0, min(11, (comps.month ?? 1) - 1))])\(comps.day ?? 1)日"
    }

    /// 以 `anchorDate` 所在周为基准的 7 天条带.
    private var weekStripDates: [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: anchorDate)
        guard let weekStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: calendar.startOfDay(for: anchorDate)) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
}

// MARK: - 心率 (2:22320)

private enum HeartRatePeriod: String, CaseIterable {
    case day = "Day", week = "Week", month = "Month"
}

struct HeartRateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: HeartRatePeriod = .week
    @State private var anchorDate = Calendar.current.startOfDay(for: Date())
    @State private var entries: [HeartRateDay] = []
    @State private var showAddSheet = false
    @State private var draftDate = Date()
    @State private var draftBpm = 70

    private var repo: HealthRepository { HealthRepository(context: modelContext) }

    var body: some View {
        HealthShell(title: "静息心率", trailingIcon: "calendar", onBack: { dismiss() }, onTrailingTap: {
            draftDate = anchorDate
            draftBpm = selectedEntryBpm ?? entries.last?.restingBpm ?? 70
            showAddSheet = true
        }) {
            VStack(spacing: 16) {
                periodTabs
                heartChartCard
                summaryCard
                historySection
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
        }
        .onAppear { refreshEntries() }
        .sheet(isPresented: $showAddSheet) { addSheet }
    }

    // MARK: - Tabs

    private var periodTabs: some View {
        HStack(spacing: 4) {
            ForEach(HeartRatePeriod.allCases, id: \.self) { tab in
                Button {
                    Haptic.light()
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(selectedTab == tab ? .black : Color.steelBlue)
                        .background(selectedTab == tab ? Color(hex: 0xFFB0A4) : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .font(AppFont.body(15))
        .padding(4)
        .frame(height: 54)
        .overlay(Capsule().stroke(Color.cultured, lineWidth: 1))
    }

    // MARK: - Chart Card

    private var heartChartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(periodTitle).font(AppFont.body(17)).foregroundStyle(Color.mutedGray)
                    Text("0-120 rht").font(AppFont.body(13)).foregroundStyle(Color.mutedGray.opacity(0.7))
                }
                Spacer()
                navButton(icon: "chevron.left") { shiftAnchor(-1) }
                navButton(icon: "chevron.right") { shiftAnchor(1) }
            }

            selectedReadout

            switch selectedTab {
            case .day: dayDetailNote
            case .week: weekChartBody
            case .month: monthChartBody
            }
        }
        .padding(18)
        .background(Color(hex: 0xF9EFED), in: RoundedRectangle(cornerRadius: 26))
    }

    private func navButton(icon: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptic.light()
            action()
        } label: {
            Image(systemName: icon).frame(width: 38, height: 38).background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var selectedReadout: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let bpm = selectedEntryBpm {
                Text("\(bpm)").font(AppFont.title(32))
                Text("次/分").font(AppFont.body(14)).foregroundStyle(Color.mutedGray)
                if let delta = trendDelta, delta != 0 {
                    HStack(spacing: 2) {
                        Image(systemName: delta > 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(abs(delta))")
                    }
                    .font(AppFont.body(12))
                    .foregroundStyle(delta > 0 ? Color(hex: 0xD1573F) : Color(hex: 0x4C8C6B))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.7), in: Capsule())
                }
            } else {
                Text("暂无记录").font(AppFont.body(16)).foregroundStyle(Color.mutedGray)
            }
            Spacer()
        }
    }

    private var dayDetailNote: some View {
        Text(dayDetailText)
            .font(AppFont.body(14))
            .foregroundStyle(Color.deepCharcoal)
            .lineSpacing(3)
            .padding(.top, 2)
    }

    private var weekChartBody: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                ForEach(weekStripDates, id: \.self) { date in
                    dayCell(date: date)
                }
            }
            HStack(alignment: .top, spacing: 8) {
                axisLabels
                sparklineArea
            }
        }
    }

    private func dayCell(date: Date) -> some View {
        let calendar = Calendar.current
        let selected = calendar.isDate(date, inSameDayAs: anchorDate)
        let isFuture = date > Date()
        let weekdaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let label = "\(weekdaySymbols[calendar.component(.weekday, from: date) - 1])\n\(String(format: "%02d", calendar.component(.day, from: date)))"
        return Button {
            Haptic.light()
            anchorDate = date
        } label: {
            Text(label)
                .font(AppFont.body(13))
                .multilineTextAlignment(.center)
                .foregroundStyle(selected ? .white : Color.mutedGray.opacity(isFuture ? 0.4 : 1))
                .frame(maxWidth: .infinity, minHeight: 72)
                .background(selected ? Color(hex: 0xFFB0A4) : Color.white.opacity(isFuture ? 0.45 : 1), in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }

    private var axisLabels: some View {
        VStack(spacing: 0) {
            ForEach(["120rht", "80rht", "40rht", "0rht"], id: \.self) { label in
                Text(label)
                    .font(AppFont.body(10))
                    .foregroundStyle(Color.mutedGray)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(width: 36, height: 130)
    }

    private var sparklineArea: some View {
        GeometryReader { geo in
            let count = max(weekStripDates.count, 1)
            let slot = geo.size.width / CGFloat(count)
            ZStack {
                gridLines
                HeartSparkline(points: sparklinePoints).stroke(Color.white, lineWidth: 2)
                if let index = weekStripDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: anchorDate) }),
                   selectedEntryBpm != nil {
                    Circle()
                        .fill(Color(hex: 0xF2C94C))
                        .frame(width: 10, height: 10)
                        .position(x: slot * (CGFloat(index) + 0.5), y: geo.size.height * sparklinePoints[index])
                }
            }
        }
        .frame(height: 130)
    }

    private var gridLines: some View {
        VStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { _ in
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    .foregroundStyle(Color.mutedGray.opacity(0.5))
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private var monthChartBody: some View {
        HStack(alignment: .bottom, spacing: 14) {
            ForEach(monthlyWeeklyAverages, id: \.label) { week in
                VStack(spacing: 6) {
                    Text(week.avg != nil ? "\(week.avg!)" : "--")
                        .font(AppFont.body(11))
                        .foregroundStyle(Color.mutedGray)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: 0xFFB0A4).opacity(week.avg != nil ? 1 : 0.3))
                        .frame(width: 26, height: max(18, CGFloat(week.avg ?? 20) / 120 * 120))
                    Text(week.label)
                        .font(AppFont.body(11))
                        .foregroundStyle(Color.mutedGray)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 170, alignment: .bottom)
    }

    private var summaryCard: some View {
        HealthInsightCard(title: "静息心率", icon: "heart") {
            Text(summaryText)
        }
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("历史记录").font(AppFont.title(18))
                Spacer()
                Button {
                    Haptic.light()
                    draftDate = Date()
                    draftBpm = entries.last?.restingBpm ?? 70
                    showAddSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("记录")
                    }
                    .font(AppFont.body(14))
                    .foregroundStyle(Color(hex: 0xFF9181))
                }
                .buttonStyle(.plain)
            }
            if entries.isEmpty {
                Text("还没有心率记录，点击上方“记录”添加第一条。")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.mutedGray)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 8) {
                    ForEach(entries.sorted(by: { $0.date > $1.date }).prefix(10), id: \.persistentModelID) { entry in
                        heartRow(entry)
                    }
                }
            }
        }
    }

    private func heartRow(_ entry: HeartRateDay) -> some View {
        Button {
            Haptic.light()
            anchorDate = entry.date
            selectedTab = .week
        } label: {
            HStack(spacing: 12) {
                Circle().fill(Color(hex: 0xFFB0A4)).frame(width: 42, height: 42).overlay(Image(systemName: "heart.fill").foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(entry.restingBpm) Rht").font(AppFont.body(19)).foregroundStyle(Color.textPrimary)
                    Text(formattedDate(entry.date)).font(AppFont.body(15)).foregroundStyle(Color.steelBlue)
                }
                Spacer()
                Button {
                    Haptic.light()
                    delete(entry)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.mutedGray)
                        .frame(width: 32, height: 32)
                        .background(Color.cultured, in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(
                Calendar.current.isDate(entry.date, inSameDayAs: anchorDate) ? Color(hex: 0xFFB0A4).opacity(0.15) : Color.white,
                in: RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add sheet

    private var addSheet: some View {
        NavigationStack {
            Form {
                DatePicker("日期", selection: $draftDate, in: ...Date(), displayedComponents: .date)
                Stepper(value: $draftBpm, in: 30...220) {
                    HStack {
                        Text("静息心率")
                        Spacer()
                        Text("\(draftBpm) 次/分").foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .navigationTitle("记录心率")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Haptic.success()
                        repo.upsertHeartRate(date: draftDate, bpm: draftBpm)
                        refreshEntries()
                        anchorDate = Calendar.current.startOfDay(for: draftDate)
                        showAddSheet = false
                    }
                }
            }
        }
        .presentationDetents([.height(280)])
    }

    // MARK: - Data helpers

    private func refreshEntries() {
        entries = repo.recentHeartRate(days: 90)
    }

    private func delete(_ entry: HeartRateDay) {
        repo.deleteHeartRate(entry)
        refreshEntries()
    }

    private func bpm(on date: Date) -> Int? {
        entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }?.restingBpm
    }

    private var selectedEntryBpm: Int? { bpm(on: anchorDate) }

    private var trendDelta: Int? {
        guard let current = selectedEntryBpm,
              let prevDate = Calendar.current.date(byAdding: .day, value: -1, to: anchorDate),
              let previous = bpm(on: prevDate) else { return nil }
        return current - previous
    }

    private var dayDetailText: String {
        guard let bpm = selectedEntryBpm else {
            return "这一天还没有静息心率记录，点击右上角日历图标可以补录。"
        }
        if let delta = trendDelta {
            if delta == 0 { return "与前一天持平，心率保持稳定。" }
            return delta > 0
                ? "比前一天升高了 \(delta) 次/分，注意休息和放松。"
                : "比前一天降低了 \(abs(delta)) 次/分，恢复情况不错。"
        }
        return "静息心率 \(bpm) 次/分，处于正常范围内。"
    }

    private var summaryText: String {
        guard !entries.isEmpty else {
            return "还没有心率记录。点击上方日历图标或“记录”按钮，开始追踪你的静息心率变化趋势。"
        }
        let recent = entries.suffix(7)
        let avg = recent.map(\.restingBpm).reduce(0, +) / max(recent.count, 1)
        let latest = entries.sorted(by: { $0.date > $1.date }).first?.restingBpm ?? avg
        let comparison = latest > avg
            ? "略高于近期平均水平，建议留意休息与压力管理。"
            : "整体保持平稳，继续保持当前的作息节奏。"
        return "静息心率 \(latest) 次/分。最近 7 天平均 \(avg) 次/分。\(comparison)"
    }

    /// 以 `anchorDate` 所在周为基准的 7 天条带.
    private var weekStripDates: [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: anchorDate)
        guard let weekStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: calendar.startOfDay(for: anchorDate)) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    /// 归一化到 0...1 的纵坐标 (0=顶部=120bpm, 1=底部=0bpm), 缺失日用最近已知值兜底避免折线断裂.
    private var sparklinePoints: [CGFloat] {
        var lastKnown = entries.first?.restingBpm ?? 70
        return weekStripDates.map { date in
            if let value = bpm(on: date) {
                lastKnown = value
                return pointFraction(value)
            }
            return pointFraction(lastKnown)
        }
    }

    private func pointFraction(_ bpm: Int) -> CGFloat {
        max(0, min(1, 1 - CGFloat(bpm) / 120.0))
    }

    /// `anchorDate` 所在月份按周切分的平均心率, 用于 Month tab 的柱状概览.
    private var monthlyWeeklyAverages: [(label: String, avg: Int?)] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: anchorDate) else { return [] }
        var result: [(String, Int?)] = []
        var cursor = monthInterval.start
        var weekIndex = 1
        while cursor < monthInterval.end {
            let weekEnd = min(calendar.date(byAdding: .day, value: 7, to: cursor) ?? monthInterval.end, monthInterval.end)
            let bucket = entries.filter { $0.date >= cursor && $0.date < weekEnd }
            let avg = bucket.isEmpty ? nil : bucket.map(\.restingBpm).reduce(0, +) / bucket.count
            result.append(("第\(weekIndex)周", avg))
            weekIndex += 1
            cursor = weekEnd
        }
        return result
    }

    private var periodTitle: String {
        let calendar = Calendar.current
        let monthNames = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
        switch selectedTab {
        case .day:
            let comps = calendar.dateComponents([.month, .day], from: anchorDate)
            return "\(comps.month ?? 1)月\(comps.day ?? 1)日"
        case .week:
            return monthNames[max(0, min(11, calendar.component(.month, from: anchorDate) - 1))]
        case .month:
            return "\(calendar.component(.year, from: anchorDate))年 \(monthNames[max(0, min(11, calendar.component(.month, from: anchorDate) - 1))])"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let weekdaySymbols = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        let weekday = weekdaySymbols[calendar.component(.weekday, from: date) - 1]
        let comps = calendar.dateComponents([.month, .day], from: date)
        return "\(weekday)，\(comps.month ?? 1)月\(comps.day ?? 1)日"
    }

    /// 依据当前 Day/Week/Month tab, 用对应步长移动 `anchorDate`.
    private func shiftAnchor(_ direction: Int) {
        let component: Calendar.Component
        switch selectedTab {
        case .day: component = .day
        case .week: component = .weekOfYear
        case .month: component = .month
        }
        if let date = Calendar.current.date(byAdding: component, value: direction, to: anchorDate) {
            anchorDate = date
        }
    }
}

private struct HealthShell<Content: View>: View {
    let title: String
    let trailingIcon: String?
    let onBack: () -> Void
    var onTrailingTap: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                content()
            }
            .padding(.top, 104)
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
                        Button(action: { onTrailingTap?() }) {
                            Image(systemName: trailingIcon)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textPrimary)
                                .frame(width: 39, height: 39)
                                .background(Color.white, in: Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(onTrailingTap == nil)
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

/// 心率折线. `points` 为归一化到 0...1 的纵坐标序列 (0=顶部, 1=底部).
private struct HeartSparkline: Shape {
    var points: [CGFloat]

    func path(in rect: CGRect) -> Path {
        guard points.count > 1 else { return Path() }
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
