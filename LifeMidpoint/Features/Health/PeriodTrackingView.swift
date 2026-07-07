import SwiftUI

// MARK: - 经期跟踪 (2:21604)

struct PeriodTrackingView: View {
    private enum PeriodTab: String, CaseIterable {
        case day = "日", month = "月", year = "年"
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showAddPeriod = false
    @State private var selectedTab: PeriodTab = .month
    @State private var anchorDate = Date()
    @State private var bleedingQuickValue = "经期"
    @State private var showSymptomDetail = true
    @State private var dripBleeding = "未设置"
    @State private var otherSymptom = "未设置"

    private let dripOptions = ["未设置", "少量", "中等", "大量"]
    private let symptomOptions = ["未设置", "头痛", "腹痛", "乏力", "情绪波动", "潮热"]

    var body: some View {
        ZStack {
            Color(hex: 0xF9F9F8, alpha: 0.6).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    periodTabs
                    calendarPanel
                    recordSection
                    if showSymptomDetail {
                        symptomDetailPanel
                    }
                    tipPanel
                }
                .padding(.horizontal, 20)
                .padding(.top, 104)
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) { topBar }
        .sheet(isPresented: $showAddPeriod) { AddPeriodView() }
    }

    private var topBar: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea(edges: .top).frame(height: 108)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.mindPrimary)
                }
                Spacer()
                Text("经期跟踪")
                    .font(AppFont.title(24))
                    .tracking(1.44)
                Spacer()
                Button { showAddPeriod = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.textPrimary)
                }
            }
            .padding(.horizontal, 34)
            .padding(.top, 42)
        }
    }

    private var periodTabs: some View {
        HStack(spacing: 4) {
            ForEach(PeriodTab.allCases, id: \.self) { tab in
                tabItem(tab.rawValue, selected: selectedTab == tab) {
                    Haptic.light()
                    selectedTab = tab
                }
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity)
        .overlay(Capsule().stroke(Color.cultured, lineWidth: 1))
    }

    private func tabItem(_ label: String, selected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Circle()
                    .fill(selected ? Color(hex: 0xFFB0A4) : Color.white)
                    .frame(width: 38, height: 38)
                    .overlay(Image(systemName: "calendar").font(.system(size: 14)).foregroundStyle(selected ? .white : Color.steelBlue))
                Text(label)
                    .font(AppFont.body(15))
                    .foregroundStyle(selected ? Color(hex: 0xFF9181) : Color.steelBlue)
            }
            .frame(maxWidth: .infinity)
            .background(selected ? Color(hex: 0xF8E4E1, alpha: 0.33) : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var calendarPanel: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(calendarTitle)
                    .font(AppFont.title(18))
                Spacer()
                Button { Haptic.light(); shiftAnchor(-1) } label: {
                    Image(systemName: "chevron.left").frame(width: 38, height: 38).background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                Button { Haptic.light(); shiftAnchor(1) } label: {
                    Image(systemName: "chevron.right").frame(width: 38, height: 38).background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            HStack(spacing: 6) {
                ForEach(weekStripDates, id: \.self) { date in
                    calendarDayCell(date: date, selected: Calendar.current.isDate(date, inSameDayAs: anchorDate))
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 26))
    }

    /// 以 `anchorDate` 所在周为基准的 7 天条带, 保证选中日始终落在条带内.
    private var weekStripDates: [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: anchorDate)
        guard let weekStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: calendar.startOfDay(for: anchorDate)) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private func calendarDayCell(date: Date, selected: Bool) -> some View {
        let calendar = Calendar.current
        let weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]
        let weekdayLabel = weekdaySymbols[calendar.component(.weekday, from: date) - 1]
        return Button {
            Haptic.light()
            anchorDate = date
        } label: {
            VStack(spacing: 8) {
                Text(weekdayLabel)
                    .font(AppFont.body(15))
                    .foregroundStyle(selected ? Color(hex: 0xFCF0ED) : Color.mutedGray)
                Text(String(format: "%02d", calendar.component(.day, from: date)))
                    .font(AppFont.body(15))
                    .foregroundStyle(selected ? Color.black : Color.black.opacity(0.6))
                    .frame(width: 38, height: 38)
                    .background(Color(hex: 0xFCEDED), in: Circle())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 2)
            .background(selected ? Color(hex: 0xFFB0A4) : Color.white, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private var recordSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("记录").font(AppFont.title(18))
            recordRow(title: "出血", value: bleedingQuickValue) {
                cycleBleeding()
            }
            Button {
                Haptic.light()
                withAnimation(.easeInOut(duration: 0.2)) { showSymptomDetail.toggle() }
            } label: {
                HStack(spacing: 4) {
                    Text("其他症状")
                        .font(AppFont.title(16))
                        .foregroundStyle(Color(hex: 0xFF9181))
                    Image(systemName: showSymptomDetail ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: 0xFF9181))
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func recordRow(title: String, value: String, onTap: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle().fill(Color(hex: 0xFF9181)).frame(width: 5, height: 5)
                Text(title).font(AppFont.title(16)).foregroundStyle(Color(hex: 0xFF9181))
            }
            Button(action: onTap) {
                HStack {
                    Text(value).font(AppFont.body(14)).foregroundStyle(Color(hex: 0xFF9181))
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 29)
                .background(Color(hex: 0xF8ECEA), in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var symptomDetailPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("症状详情").font(AppFont.body(18))
                Spacer()
                Menu {
                    Button("重置症状详情", systemImage: "arrow.counterclockwise") {
                        Haptic.light()
                        dripBleeding = "未设置"
                        otherSymptom = "未设置"
                    }
                } label: {
                    Image(systemName: "ellipsis").frame(width: 32, height: 32).background(Color.white, in: Circle())
                        .foregroundStyle(Color.textPrimary)
                }
            }
            symptomDropRow("点滴出血", icon: "drop", selection: $dripBleeding, options: dripOptions)
            symptomDropRow("症状", icon: "drop.fill", selection: $otherSymptom, options: symptomOptions)
        }
        .padding(12)
        .background(Color.cultured, in: RoundedRectangle(cornerRadius: 30))
    }

    private func symptomDropRow(_ title: String, icon: String, selection: Binding<String>, options: [String]) -> some View {
        HStack(spacing: 12) {
            Circle().fill(Color(hex: 0xF8E4E1).opacity(0.9)).frame(width: 40, height: 40)
                .overlay(Image(systemName: icon).foregroundStyle(Color.healthPink))
            Text(title).font(AppFont.body(15))
            Spacer()
            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        Haptic.light()
                        selection.wrappedValue = option
                    } label: {
                        if option == selection.wrappedValue {
                            Label(option, systemImage: "checkmark")
                        } else {
                            Text(option)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue).font(AppFont.body(14))
                    Image(systemName: "chevron.down").font(.system(size: 11))
                }
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 12)
                .frame(height: 32)
                .background(Color.cultured, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(8)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var tipPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle().fill(Color(hex: 0xFFB0A4)).frame(width: 42, height: 42).overlay(Image(systemName: "waveform.path.ecg").foregroundStyle(.white))
                Text("提示").font(AppFont.title(18))
            }
            Text("通常在经期开始的前 3 天，你的潮热症状出现的频次会增加 40%。建议从明天起换上轻薄透气的棉质睡衣。")
                .font(AppFont.body(15))
                .foregroundStyle(Color.deepCharcoal)
                .padding(16)
                .background(Color(hex: 0xFFB0A4, alpha: 0.3), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(14)
    }

    // MARK: - Actions

    /// 依据当前 日/月/年 tab, 用对应步长移动 `anchorDate`.
    private func shiftAnchor(_ direction: Int) {
        let component: Calendar.Component
        switch selectedTab {
        case .day: component = .day
        case .month: component = .month
        case .year: component = .year
        }
        if let date = Calendar.current.date(byAdding: component, value: direction, to: anchorDate) {
            anchorDate = date
        }
    }

    private var calendarTitle: String {
        let calendar = Calendar.current
        switch selectedTab {
        case .day:
            let comps = calendar.dateComponents([.month, .day], from: anchorDate)
            return "\(comps.month ?? 1)月\(comps.day ?? 1)日"
        case .month:
            let names = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
            let month = calendar.component(.month, from: anchorDate)
            return names[max(0, min(11, month - 1))]
        case .year:
            return "\(calendar.component(.year, from: anchorDate))"
        }
    }

    /// 出血记录 "+" 循环 经期 → 点滴 → 无, 非"无"时写入一条 `SymptomLog`.
    private func cycleBleeding() {
        Haptic.light()
        let options = ["经期", "点滴", "无"]
        let currentIndex = options.firstIndex(of: bleedingQuickValue) ?? 0
        bleedingQuickValue = options[(currentIndex + 1) % options.count]
        guard bleedingQuickValue != "无" else { return }
        modelContext.insert(SymptomLog(
            name: "出血 · \(bleedingQuickValue)",
            iconSystemName: "drop.fill",
            severity: bleedingQuickValue == "经期" ? 2 : 1,
            date: anchorDate
        ))
        try? modelContext.save()
    }
}

// MARK: - 添加经期 (2:22127)

struct AddPeriodView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()
    @State private var bleedingLevel = "中等"
    @State private var symptomChoice = "无"
    @State private var showDatePicker = false

    private let bleedingOptions = ["无", "少量", "中等", "大量"]
    private let symptomOptions = ["无", "腹痛", "头痛", "乏力", "潮热", "情绪波动"]

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                formCard
                    .padding(.horizontal, 28)
                .padding(.top, 104)
                    .padding(.bottom, 44)
            }
        }
        .overlay(alignment: .top) { topBar }
        .sheet(isPresented: $showDatePicker) { datePickerSheet }
    }

    private var topBar: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea(edges: .top).frame(height: 108)
            HStack {
                Button { dismiss() } label: { Image(systemName: "arrow.left").foregroundStyle(Color.mindPrimary) }
                Spacer()
                Text("经期历史").font(AppFont.title(24))
                Spacer()
                Menu {
                    Button("清空本次填写", systemImage: "arrow.counterclockwise") { resetForm() }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 39, height: 39)
                        .background(Color.white, in: Circle())
                }
            }
            .padding(.horizontal, 34)
            .padding(.top, 42)
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                Text("选择经期历史日期")
                    .font(AppFont.title(20))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Button {
                    Haptic.light()
                    startNewEntry()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: 0xFFB0A4), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        )
                }
                .buttonStyle(.plain)
            }

            startDateRow
            dateGrid
            addRows
            actionButtons
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
    }

    private var startDateRow: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color(hex: 0xFFB0A4))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "timer")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("起始日期")
                    .font(AppFont.title(17))
                    .foregroundStyle(Color.textPrimary)
                Text(formattedSelectedDate)
                    .font(AppFont.body(12))
                    .foregroundStyle(Color.textPrimary.opacity(0.5))
            }

            Spacer()

            Button {
                Haptic.light()
                showDatePicker = true
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textPrimary.opacity(0.8))
                    .frame(width: 40, height: 40)
                    .background(Color.white, in: Circle())
                    .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var datePickerSheet: some View {
        NavigationStack {
            DatePicker("起始日期", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .navigationTitle("选择起始日期")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") {
                            displayedMonth = selectedDate
                            showDatePicker = false
                        }
                    }
                }
        }
        .presentationDetents([.medium])
        .onDisappear { displayedMonth = selectedDate }
    }

    private var dateGrid: some View {
        VStack(spacing: 12) {
            calendarControls

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 7) {
                ForEach(monthGridCells) { cell in
                    calendarDateCell(cell)
                }
            }
        }
    }

    private var calendarControls: some View {
        HStack(spacing: 8) {
            monthYearControl(title: monthTitle, onPrev: { shiftMonth(-1) }, onNext: { shiftMonth(1) })
            monthYearControl(title: yearTitle, onPrev: { shiftYear(-1) }, onNext: { shiftYear(1) })
        }
    }

    private func monthYearControl(title: String, onPrev: @escaping () -> Void, onNext: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            Button { Haptic.light(); onPrev() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 34, height: 34)
                    .background(Color.cultured, in: Circle())
            }
            .buttonStyle(.plain)

            Text(title)
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity)

            Button { Haptic.light(); onNext() } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 34, height: 34)
                    .background(Color.cultured, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    /// 月历格子, 含上下月补位天数, 固定按周对齐, 与 Figma 静态稿的 5 行布局一致.
    private struct PeriodCalendarCell: Identifiable {
        let id = UUID()
        let date: Date
        let isCurrentMonth: Bool
    }

    private var monthGridCells: [PeriodCalendarCell] {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else { return [] }
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        let leadingCount = calendar.component(.weekday, from: monthStart) - 1

        var cells: [PeriodCalendarCell] = []
        if leadingCount > 0, let prevStart = calendar.date(byAdding: .day, value: -leadingCount, to: monthStart) {
            for offset in 0..<leadingCount {
                if let date = calendar.date(byAdding: .day, value: offset, to: prevStart) {
                    cells.append(PeriodCalendarCell(date: date, isCurrentMonth: false))
                }
            }
        }
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                cells.append(PeriodCalendarCell(date: date, isCurrentMonth: true))
            }
        }
        while cells.count % 7 != 0, let last = cells.last?.date,
              let next = calendar.date(byAdding: .day, value: 1, to: last) {
            cells.append(PeriodCalendarCell(date: next, isCurrentMonth: false))
        }
        return cells
    }

    private func calendarDateCell(_ cell: PeriodCalendarCell) -> some View {
        let selected = Calendar.current.isDate(cell.date, inSameDayAs: selectedDate)
        let faded = !cell.isCurrentMonth
        return Button {
            Haptic.light()
            selectedDate = cell.date
        } label: {
            Text(dayLabel(cell.date))
                .font(AppFont.body(12))
                .foregroundStyle(selected ? Color.white : Color.textPrimary.opacity(faded ? 0.32 : 0.78))
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selected ? Color(hex: 0xFFB0A4) : Color.white.opacity(0.9))
                )
                .overlay(alignment: .bottomLeading) {
                    if !faded || selected {
                        Circle()
                            .fill(Color(hex: 0xFFB0A4).opacity(selected ? 0.95 : 0.22))
                            .frame(width: 5, height: 5)
                            .padding(4)
                    }
                }
                .overlay {
                    if faded {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: 0xF8ECEA), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                            .opacity(0.55)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var addRows: some View {
        VStack(spacing: 12) {
            addRow("出血量", selection: $bleedingLevel, options: bleedingOptions)
            addRow("症状", selection: $symptomChoice, options: symptomOptions)
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
    }

    private func addRow(_ title: String, selection: Binding<String>, options: [String]) -> some View {
        HStack {
            Circle()
                .fill(Color(hex: 0xFFB0A4))
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "waveform").font(.system(size: 14)).foregroundStyle(.white))
            Text(title).font(AppFont.title(16))
            Spacer()
            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        Haptic.light()
                        selection.wrappedValue = option
                    } label: {
                        if option == selection.wrappedValue {
                            Label(option, systemImage: "checkmark")
                        } else {
                            Text(option)
                        }
                    }
                }
            } label: {
                HStack(spacing: 14) {
                    Text(selection.wrappedValue).font(AppFont.body(14))
                    Image(systemName: "chevron.down").font(.system(size: 12))
                }
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 18)
                .frame(height: 42)
                .background(Color.white, in: Capsule())
            }
        }
        .padding(8)
        .background(Color.cultured, in: RoundedRectangle(cornerRadius: 18))
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button("取消") {
                Haptic.light()
                dismiss()
            }
                .font(AppFont.body(16))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(Color.cultured, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.16), radius: 4, y: 4)
            Button("保存") {
                Haptic.success()
                saveRecord()
                dismiss()
            }
                .font(AppFont.body(16))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(Color(hex: 0xFFB0A4), in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.16), radius: 4, y: 4)
        }
    }

    // MARK: - Actions

    private func shiftMonth(_ offset: Int) {
        if let date = Calendar.current.date(byAdding: .month, value: offset, to: displayedMonth) {
            displayedMonth = date
        }
    }

    private func shiftYear(_ offset: Int) {
        if let date = Calendar.current.date(byAdding: .year, value: offset, to: displayedMonth) {
            displayedMonth = date
        }
    }

    private func startNewEntry() {
        displayedMonth = Date()
        selectedDate = Date()
        bleedingLevel = "中等"
        symptomChoice = "无"
    }

    private func resetForm() {
        Haptic.light()
        startNewEntry()
    }

    /// 保存这段经期记录: 写入 `MenstrualPeriod`, 出血量/症状非"无"时同步写一条 `SymptomLog`.
    private func saveRecord() {
        let period = MenstrualPeriod(startDate: selectedDate)
        modelContext.insert(period)

        if bleedingLevel != "无" {
            modelContext.insert(SymptomLog(
                name: "出血量 · \(bleedingLevel)",
                iconSystemName: "drop.fill",
                severity: severity(for: bleedingLevel),
                date: selectedDate
            ))
        }
        if symptomChoice != "无" {
            modelContext.insert(SymptomLog(
                name: symptomChoice,
                iconSystemName: "waveform.path.ecg",
                severity: 2,
                date: selectedDate
            ))
        }
        try? modelContext.save()
    }

    private func severity(for bleedingLevel: String) -> Int {
        switch bleedingLevel {
        case "少量": return 1
        case "中等": return 2
        case "大量": return 3
        default: return 0
        }
    }

    private var monthTitle: String {
        let names = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
        let month = Calendar.current.component(.month, from: displayedMonth)
        return names[max(0, min(11, month - 1))]
    }

    private var yearTitle: String {
        "\(Calendar.current.component(.year, from: displayedMonth))"
    }

    private var formattedSelectedDate: String {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        return "\(comps.year ?? 2026)年\(comps.month ?? 1)月\(comps.day ?? 1)日"
    }

    private func dayLabel(_ date: Date) -> String {
        String(format: "%02d", Calendar.current.component(.day, from: date))
    }
}
