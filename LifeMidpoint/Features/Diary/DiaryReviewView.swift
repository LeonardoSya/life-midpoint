import SwiftUI
import SwiftData

/// 日记总结（月历）页。
///
/// 对应 Figma:
/// - 有记录: 月历 + 当日卡片 (标题 / 摘要 / 小清单 / 邮票)
/// - 无记录: 月历 + 空状态卡片
struct DiaryReviewView: View {
    let hasRecords: Bool

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \DiaryEntry.entryDate, order: .reverse)
    private var entries: [DiaryEntry]

    @State private var displayedMonth: Date = Self.mockMonth
    @State private var selectedDate: Date = Self.mockSelectedDate

    private static let mockMonth = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1)) ?? Date()
    private static let mockSelectedDate = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 12)) ?? Date()
    private static let mockEntry = DiaryReviewMockEntry(
        date: mockSelectedDate,
        title: "疲惫但平静",
        body: "下午在公园散步，让我的思绪慢慢沉下来。我开始留意生活中那些安静的细节，比如树叶轻轻晃动的样子。只是偶尔还会有一种被困住的感觉，也隐隐察觉到自己的体力不如从前了..."
    )

    private var selectedEntry: DiaryEntry? {
        entries.first { Calendar.current.isDate($0.entryDate, inSameDayAs: selectedDate) }
    }

    private var selectedMockEntry: DiaryReviewMockEntry? {
        Calendar.current.isDate(Self.mockEntry.date, inSameDayAs: selectedDate) ? Self.mockEntry : nil
    }

    private var hasAnyRecord: Bool {
        selectedEntry != nil || selectedMockEntry != nil
    }

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    calendarHeader
                        .padding(.top, 64)

                    calendarGrid

                    legend
                        .padding(.top, 0)

                    dayCard
                        .padding(.top, 18)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 42)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if let latest = entries.first {
                selectedDate = latest.entryDate
                displayedMonth = latest.entryDate
            }
        }
    }

    // MARK: - Calendar

    private var calendarHeader: some View {
        HStack {
            Button { shiftMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Text(monthTitle(displayedMonth))
                .font(AppFont.title(22))
                .foregroundStyle(Color.textPrimary)
                .tracking(2)

            Spacer()

            Button { shiftMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(.horizontal, 24)
    }

    private var calendarGrid: some View {
        VStack(spacing: 15) {
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(AppFont.numeric(10))
                        .foregroundStyle(Color.textSecondary.opacity(0.82))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 7), spacing: 12) {
                ForEach(monthCells, id: \.id) { cell in
                    if let date = cell.date {
                        dayButton(date)
                    } else {
                        Color.clear.frame(width: 37.5, height: 37.5)
                    }
                }
            }
            .padding(.horizontal, 28)
        }
    }

    private func dayButton(_ date: Date) -> some View {
        let day = Calendar.current.component(.day, from: date)
        let hasEntry = entries.contains { Calendar.current.isDate($0.entryDate, inSameDayAs: date) }
            || Calendar.current.isDate(Self.mockEntry.date, inSameDayAs: date)
        let selected = Calendar.current.isDate(date, inSameDayAs: selectedDate)

        return Button {
            selectedDate = date
        } label: {
            ZStack {
                Circle()
                    .fill(dayColor(for: date, hasEntry: hasEntry))
                    .frame(width: selected ? 44.5 : 37.5, height: selected ? 44.5 : 37.5)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(selected ? 0.95 : 0), lineWidth: 3)
                    )
                    .shadow(color: selected ? .black.opacity(0.12) : .clear, radius: 12, y: 8)

                Text("\(day)")
                    .font(AppFont.numeric(14))
                    .foregroundStyle(dayTextColor(for: date))

                if hasEntry {
                    Circle()
                        .fill(Color.textPrimary.opacity(0.75))
                        .frame(width: 4, height: 4)
                        .offset(y: selected ? 13 : 12)
                }
            }
            .frame(width: 44.5, height: 44.5)
        }
        .buttonStyle(.plain)
    }

    private var legend: some View {
        HStack(spacing: 22) {
            legendItem("情绪良好", color: Color(hex: 0xD5E9BF))
            legendItem("情绪一般", color: Color(hex: 0xD2E6EC))
            legendItem("情绪困扰", color: Color(hex: 0xFD795A))
        }
        .frame(maxWidth: .infinity)
        .opacity(0.7)
    }

    private func legendItem(_ text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(text)
                .font(AppFont.body(10))
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Day Card

    @ViewBuilder
    private var dayCard: some View {
        if let entry = selectedEntry {
            recordedCard(entry)
        } else if let mock = selectedMockEntry {
            recordedCard(mock)
        } else {
            emptyCard
        }
    }

    private func recordedCard(_ entry: DiaryEntry) -> some View {
        recordedCardContent(
            date: entry.entryDate,
            title: entry.title,
            body: entry.body,
            hasContent: true
        )
    }

    private func recordedCard(_ entry: DiaryReviewMockEntry) -> some View {
        recordedCardContent(
            date: entry.date,
            title: entry.title,
            body: entry.body,
            hasContent: true
        )
    }

    private var emptyCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dayTitle(selectedDate))
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary.opacity(0.8))
                    Text("心情未知")
                        .font(AppFont.title(20))
                        .foregroundStyle(Color.textPrimary)
                }
                Spacer()
                weatherIcon
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("这里空空如也...")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.textSecondary.opacity(0.72))
                Text("（点击书写这一天）")
                    .font(AppFont.body(11))
                    .foregroundStyle(Color.textSecondary.opacity(0.46))
            }

            cardMeta(entry: nil, hasContent: false)
        }
        .padding(28)
        .background(cardBackground)
        .shadow(color: .black.opacity(0.08), radius: 24, y: 14)
    }

    private func recordedCardContent(date: Date, title: String, body: String, hasContent: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayTitle(date))
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary.opacity(0.8))

                    Text(title)
                        .font(AppFont.title(20))
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()
                weatherIcon
            }

            Text(excerpt(body))
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(8)
                .frame(maxWidth: .infinity, alignment: .leading)

            cardDivider

            cardMeta(entry: nil, hasContent: hasContent)
        }
        .padding(33)
        .background(cardBackground)
        .shadow(color: Color.textPrimary.opacity(0.06), radius: 16, y: 12)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.white.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color.stampDashed.opacity(0.1))
            .frame(height: 1)
    }

    private var weatherIcon: some View {
        Image(systemName: "sun.max")
            .font(.system(size: 18, weight: .light))
            .foregroundStyle(Color.textSecondary)
            .padding(8)
            .background(Color.mintMistBg.opacity(0.7), in: Circle())
    }

    private func cardMeta(entry: DiaryEntry?, hasContent: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日小确幸")
                .font(AppFont.body(11))
                .foregroundStyle(Color.textSecondary.opacity(0.58))

            HStack {
                Text("我的信件")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.textPrimary.opacity(0.72))

                Spacer()

                metaPill(icon: "envelope", text: hasContent ? "1寄出" : "0送出")
                metaPill(icon: "tray", text: hasContent ? "2收到" : "1收到")
            }

            HStack(alignment: .center) {
                Text("我的邮票")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.textPrimary.opacity(0.72))

                Spacer()

                if hasContent {
                    Image("GoldStamp2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 36)
                }
            }

            HStack {
                Spacer()
                Text("查看完整回忆")
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.textPrimary.opacity(0.72))
                Image(systemName: "arrow.right")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textPrimary.opacity(0.72))
            }
            .padding(.top, 6)
        }
    }

    private func metaPill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(text)
                .font(AppFont.body(10))
        }
        .foregroundStyle(Color.textSecondary.opacity(0.7))
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.72), in: Capsule())
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Helpers

    private struct CalendarCell: Identifiable {
        let id = UUID()
        let date: Date?
    }

    private var monthCells: [CalendarCell] {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) ?? displayedMonth
        let days = calendar.range(of: .day, in: .month, for: start)?.count ?? 30
        let isFigmaMockMonth = Calendar.current.isDate(displayedMonth, equalTo: Self.mockMonth, toGranularity: .month)
        let weekday = calendar.component(.weekday, from: start)
        let blanks = isFigmaMockMonth ? 2 : max(0, weekday - 1)

        let blankCells = Array(repeating: CalendarCell(date: nil), count: blanks)
        let dateCells = (1...days).compactMap { day -> CalendarCell? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: start) else { return nil }
            return CalendarCell(date: date)
        }
        return blankCells + dateCells
    }

    private func shiftMonth(_ offset: Int) {
        displayedMonth = Calendar.current.date(byAdding: .month, value: offset, to: displayedMonth) ?? displayedMonth
        selectedDate = displayedMonth
    }

    private func monthTitle(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        let month = comps.month ?? 1
        let year = comps.year ?? 2026
        return "\(chineseMonth(month))   \(year)"
    }

    private func chineseMonth(_ month: Int) -> String {
        ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"][max(0, min(11, month - 1))]
    }

    private func dayTitle(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.month, .day], from: date)
        return "\(comps.month ?? 1)月\(comps.day ?? 1)日"
    }

    private func dayColor(for date: Date, hasEntry: Bool) -> Color {
        if hasEntry { return Color(hex: 0xD2E6EC, alpha: 0.4) }
        let day = Calendar.current.component(.day, from: date)
        if [3, 14, 26].contains(day) { return Color(hex: 0xFD795A, alpha: 0.2) }
        if [5, 8, 9, 15, 16, 22, 23, 28, 29].contains(day) { return Color(hex: 0xD5E9BF, alpha: 0.4) }
        if [1, 4, 6, 10, 12, 13, 18, 19, 20, 24, 25, 30, 31].contains(day) { return Color(hex: 0xD2E6EC, alpha: 0.4) }
        return Color.chipBackgroundIdle
    }

    private func dayTextColor(for date: Date) -> Color {
        let day = Calendar.current.component(.day, from: date)
        if [3, 14, 26].contains(day) { return Color(hex: 0x791903) }
        if [5, 8, 9, 15, 16, 22, 23, 28, 29].contains(day) { return Color(hex: 0x344426) }
        if [1, 4, 6, 10, 12, 13, 18, 19, 20, 24, 25, 30, 31].contains(day) { return Color(hex: 0x304247) }
        return Color.textSecondary
    }

    private func excerpt(_ body: String) -> String {
        let trimmed = body.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count > 118 ? "\"\(trimmed.prefix(118))...\"" : "\"\(trimmed)\""
    }
}

private struct DiaryReviewMockEntry {
    let date: Date
    let title: String
    let body: String
}
