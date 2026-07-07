import SwiftUI
import SwiftData

// P4.22 我的笔友 (2:23857)
struct PenPalListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PenPal.lastActiveAt, order: .reverse)
    private var penPals: [PenPal]
    /// 只关心和笔友之间往来的信件 (排除写给自己/陌生人的信), 用于日历高亮与信件预览.
    @Query(filter: #Predicate<Letter> { $0.penPal != nil }, sort: \Letter.createdAt, order: .reverse)
    private var penPalLetters: [Letter]

    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()
    @State private var selectedPenPalName: String?
    @State private var penPalToDelete: PenPal?
    @State private var showWriteLetter = false
    @State private var writeLetterTarget: PenPal?

    private var repo: PostOfficeRepository { PostOfficeRepository(context: modelContext) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                backButton

                headerRow

                if penPals.isEmpty {
                    emptyPenPalsCard
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(penPals) { pal in
                                penPalCard(pal)
                            }
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 4)
                    }
                }

                Spacer().frame(height: 34)

                calendarLetterPanel
            }
            .padding(.horizontal, 19)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $selectedPenPalName) { name in
            PenPalDetailView(name: name)
        }
        .sheet(isPresented: $showWriteLetter) {
            WriteLetterView(presetPenPal: writeLetterTarget)
        }
        .alert("删除笔友", isPresented: deleteAlertBinding) {
            Button("取消", role: .cancel) { penPalToDelete = nil }
            Button("删除", role: .destructive) {
                if let pal = penPalToDelete { repo.deletePenPal(pal) }
                penPalToDelete = nil
            }
        } message: {
            Text("删除后, 与\u{201C}\(penPalToDelete?.name ?? "")\u{201D}的往来信件也会一并删除, 且无法恢复。")
        }
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(get: { penPalToDelete != nil }, set: { if !$0 { penPalToDelete = nil } })
    }

    private var backButton: some View {
        HStack {
            AppBackButton {
                #if DEBUG
                print("🔙 [PenPalListView] backButton tapped, calling dismiss()")
                #endif
                dismiss()
            }
            Spacer()
        }
    }

    private var headerRow: some View {
        HStack {
            Text("我的笔友")
                .font(AppFont.body(16))
                .foregroundStyle(Color.textPrimary.opacity(0.8))
            Spacer()
            Text(penPals.isEmpty ? "还没有笔友" : "共 \(penPals.count) 位")
                .font(AppFont.body(13))
                .foregroundStyle(Color.mindPrimary.opacity(0.7))
        }
    }

    // MARK: - 笔友卡片 (可点击进入详情, "..." 提供快捷操作)

    private var emptyPenPalsCard: some View {
        Text("暂时还没有笔友, 寄出的信如果得到了回应, 就会在这里留下笔友。")
            .font(AppFont.body(13))
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.postCream.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
    }

    private func penPalCard(_ pal: PenPal) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pal.name)
                .font(AppFont.title(16))
                .foregroundStyle(Color(hex: 0x454545))
            Text(pal.info)
                .font(AppFont.body(11))
                .foregroundStyle(Color(hex: 0x9D9D9D))

            Spacer()

            HStack {
                Text(pal.lastActiveAt.relativeChineseDescription())
                    .font(AppFont.body(12))
                    .foregroundStyle(Color(hex: 0x8A8A8A))
                Spacer()
                penPalMenu(pal)
            }
        }
        .padding(16)
        .frame(width: 150, height: 140)
        .background(Color.postCream.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.25), radius: 2, y: 4)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptic.light()
            selectedPenPalName = pal.name
        }
    }

    private func penPalMenu(_ pal: PenPal) -> some View {
        Menu {
            Button {
                Haptic.light()
                selectedPenPalName = pal.name
            } label: {
                Label("查看详情", systemImage: "envelope.open")
            }
            Button {
                Haptic.light()
                writeLetterTarget = pal
                showWriteLetter = true
            } label: {
                Label("写信给他/她", systemImage: "square.and.pencil")
            }
            Button(role: .destructive) {
                Haptic.light()
                penPalToDelete = pal
            } label: {
                Label("删除笔友", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: 0x8A8A8A))
        }
    }

    // MARK: - 日历 + 信件预览

    private var calendarLetterPanel: some View {
        VStack(spacing: 28) {
            calendarSection
            letterPreview
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: 0xFFF9F7).opacity(0.7))
        )
        .shadow(color: .black.opacity(0.16), radius: 4, y: 4)
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button { Haptic.light(); shiftMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14))
                }
                Spacer()
                Text(monthTitle)
                    .font(AppFont.title(18))
                    .foregroundStyle(Color(hex: 0x454545))
                Spacer()
                Button { Haptic.light(); shiftMonth(1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                }
            }
            .foregroundStyle(Color(hex: 0x454545))

            HStack {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .font(AppFont.caption(12))
                        .foregroundStyle(Color(hex: 0x454545, alpha: 0.8))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(monthGridCells) { cell in
                    calendarDayCell(cell)
                }
            }
        }
    }

    private func calendarDayCell(_ cell: PenPalCalendarCell) -> some View {
        let calendar = Calendar.current
        let selected = calendar.isDate(cell.date, inSameDayAs: selectedDate)
        let isToday = calendar.isDate(cell.date, inSameDayAs: Date())
        let hasLetters = hasLetters(on: cell.date)
        return Button {
            Haptic.light()
            selectedDate = cell.date
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: cell.date))")
                    .font(AppFont.body(14))
                    .foregroundStyle(
                        selected ? Color.white
                        : (cell.isCurrentMonth ? Color(hex: 0x454545, alpha: 0.8) : Color(hex: 0x454545, alpha: 0.3))
                    )
                    .frame(width: 28, height: 28)
                    .background(
                        Circle().fill(
                            selected ? Color(hex: 0x926247)
                            : (isToday ? Color.postCream : .clear)
                        )
                    )
                Circle()
                    .fill(hasLetters ? Color(hex: 0x926247).opacity(selected ? 0 : 0.7) : .clear)
                    .frame(width: 4, height: 4)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - 信件预览 (真实数据: 有信显示真实内容, 没有则引导去写信)

    private var letterPreview: some View {
        Group {
            if let letter = selectedDayLetters.first {
                realLetterCard(letter)
            } else {
                emptyDayCard
            }
        }
    }

    private func realLetterCard(_ letter: Letter) -> some View {
        let palName = letter.penPal?.name ?? "笔友"
        let isSent = letter.direction == "sent"
        return HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    ForEach(0..<6, id: \.self) { _ in
                        Rectangle()
                            .stroke(Color(hex: 0x7C5907, alpha: 0.6), lineWidth: 1)
                            .frame(width: 14, height: 16)
                    }
                }

                Text(isSent ? "寄给\(palName)：" : "来自\(palName)：")
                    .font(AppFont.body(10))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.top, 14)

                Text(letter.body)
                    .font(AppFont.title(12))
                    .foregroundStyle(Color(hex: 0x733F19))
                    .lineSpacing(4)
                    .padding(.top, 4)

                Text(isSent ? "来自：我" : "署名：\(letter.alias ?? palName)")
                    .font(AppFont.title(10))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.top, 12)
            }

            Spacer(minLength: 0)

            Rectangle()
                .stroke(Color(hex: 0x7C5907, alpha: 0.6), lineWidth: 1)
                .frame(width: 46, height: 53)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xEFDFC3), in: RoundedRectangle(cornerRadius: 6))
        .contentShape(Rectangle())
        .onTapGesture {
            Haptic.light()
            selectedPenPalName = letter.penPal?.name
        }
    }

    private var emptyDayCard: some View {
        VStack(spacing: 10) {
            Text(Calendar.current.isDate(selectedDate, inSameDayAs: Date())
                 ? "今天还没有书信往来"
                 : "这天没有书信往来")
                .font(AppFont.body(13))
                .foregroundStyle(Color.textSecondary)
            Button {
                Haptic.medium()
                writeLetterTarget = nil
                showWriteLetter = true
            } label: {
                Text("写一封信")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.postBrown)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.postCream, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(hex: 0xEFDFC3).opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - 日期计算

    private func hasLetters(on date: Date) -> Bool {
        let calendar = Calendar.current
        return penPalLetters.contains { calendar.isDate($0.sentAt ?? $0.createdAt, inSameDayAs: date) }
    }

    private var selectedDayLetters: [Letter] {
        let calendar = Calendar.current
        return penPalLetters.filter { calendar.isDate($0.sentAt ?? $0.createdAt, inSameDayAs: selectedDate) }
    }

    private var monthGridCells: [PenPalCalendarCell] {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else { return [] }
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        let leadingCount = calendar.component(.weekday, from: monthStart) - 1

        var cells: [PenPalCalendarCell] = []
        if leadingCount > 0, let prevStart = calendar.date(byAdding: .day, value: -leadingCount, to: monthStart) {
            for offset in 0..<leadingCount {
                if let date = calendar.date(byAdding: .day, value: offset, to: prevStart) {
                    cells.append(PenPalCalendarCell(date: date, isCurrentMonth: false))
                }
            }
        }
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                cells.append(PenPalCalendarCell(date: date, isCurrentMonth: true))
            }
        }
        while cells.count % 7 != 0, let last = cells.last?.date,
              let next = calendar.date(byAdding: .day, value: 1, to: last) {
            cells.append(PenPalCalendarCell(date: next, isCurrentMonth: false))
        }
        return cells
    }

    private func shiftMonth(_ offset: Int) {
        if let date = Calendar.current.date(byAdding: .month, value: offset, to: displayedMonth) {
            displayedMonth = date
        }
    }

    private var monthTitle: String {
        let names = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
        let comps = Calendar.current.dateComponents([.year, .month], from: displayedMonth)
        let month = comps.month ?? 1
        return "\(comps.year ?? 0) \(names[max(0, min(11, month - 1))])"
    }
}

private struct PenPalCalendarCell: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
}

// P4.24 笔友详情 (2:23774)
struct PenPalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let name: String

    @State private var showAllLetters = false
    @State private var showWriteLetter = false

    private var repo: PostOfficeRepository { PostOfficeRepository(context: modelContext) }

    /// 按名字实时查找对应的 `PenPal` (SwiftData 模型), 拿真实的头像/创建时间/往来信件.
    private var penPal: PenPal? {
        let target = name
        let predicate = #Predicate<PenPal> { $0.name == target }
        return try? modelContext.fetch(FetchDescriptor<PenPal>(predicate: predicate)).first
    }

    private var letters: [Letter] {
        guard let penPal else { return [] }
        return repo.letters(in: penPal)
    }

    private var displayedLetters: [Letter] {
        showAllLetters ? letters : Array(letters.prefix(3))
    }

    /// 友谊天数: 优先取"最早一封往来信件"的日期, 更能体现真实的往来时长;
    /// 若还没有任何信件, 则回落到笔友关系创建的时间.
    private var friendshipDays: Int {
        let earliestLetterDate = letters.map { $0.sentAt ?? $0.createdAt }.min()
        guard let startDate = earliestLetterDate ?? penPal?.createdAt else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0)
    }

    /// 用对方最近一封回信的内容当作"签名语录", 让详情页不再是千篇一律的假文案.
    private var quoteText: String {
        if let received = letters.first(where: { $0.direction == "received" }) {
            let firstLine = received.body.split(separator: "\n").first.map(String.init) ?? received.body
            return "\u{201C}\(firstLine)\u{201D}"
        }
        return "\u{201C}在安静的角落发现美。我提笔是为了在阳光消失前，捕捉住那细碎的光影。\u{201D}"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                backButton
                heroSection
                statsSection
                correspondenceSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showWriteLetter) {
            WriteLetterView(presetPenPal: penPal)
        }
    }

    private var backButton: some View {
        HStack {
            AppBackButton { dismiss() }
            Spacer()
        }
    }

    private var heroSection: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.mindPrimary.opacity(0.1))
                    .frame(width: 128, height: 128)
                    .overlay(
                        Text(penPal?.avatar ?? String(name.prefix(1)))
                            .font(AppFont.title(60))
                            .foregroundStyle(.black)
                    )

                Button {
                    Haptic.medium()
                    showWriteLetter = true
                } label: {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: 0x5B5042))
                        .padding(8)
                        .background(Color.postCream, in: RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
                        .rotationEffect(.degrees(12))
                        .offset(x: 6, y: 6)
                }
            }

            Text(name)
                .font(AppFont.body(30))
                .foregroundStyle(Color(hex: 0x383833))
                .padding(.top, 24)

            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 11))
                Text("江苏")
                    .font(AppFont.body(14))
            }
            .foregroundStyle(Color(hex: 0x65655E, alpha: 0.7))
            .padding(.top, 8)

            Text(quoteText)
                .font(AppFont.body(16))
                .foregroundStyle(Color(hex: 0x65655E))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.top, 24)
        }
        .frame(maxWidth: .infinity)
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            statCard(value: "\(letters.count)", label: "已往来信件",
                     bg: Color.postCream.opacity(0.8), showSparkle: false)
            statCard(value: "\(friendshipDays)", label: "友谊天数",
                     bg: Color(hex: 0xFCF8E4), showSparkle: true)
        }
    }

    private func statCard(value: String, label: String, bg: Color, showSparkle: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(value)
                    .font(AppFont.title(39))
                    .foregroundStyle(Color(hex: 0x724F51))
                if showSparkle {
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: 0x724F51).opacity(0.6))
                }
            }
            Spacer(minLength: 12)
            Text(label)
                .font(AppFont.body(13))
                .foregroundStyle(Color(hex: 0x65655E, alpha: 0.6))
                .tracking(1)
        }
        .frame(height: 88)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(bg, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 4)
    }

    private var correspondenceSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .firstTextBaseline) {
                Text("信件往来详情")
                    .font(AppFont.title(20))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                if letters.count > 3 {
                    Button {
                        Haptic.light()
                        showAllLetters.toggle()
                    } label: {
                        Text(showAllLetters ? "收起" : "查看全部")
                            .font(AppFont.body(12))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }

            if letters.isEmpty {
                emptyLettersCard
            } else {
                ForEach(displayedLetters) { letter in
                    LetterCard(entry: LetterEntry(
                        isFromMe: letter.direction == "sent",
                        time: shortDate(letter.sentAt ?? letter.createdAt),
                        content: letter.body
                    ))
                }
            }
        }
    }

    private var emptyLettersCard: some View {
        VStack(spacing: 12) {
            Text("还没有和\(name)的往来信件")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary)
            Button {
                Haptic.medium()
                showWriteLetter = true
            } label: {
                Text("写一封信给\(name)")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.postBrown)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.postCream, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
    }

    private func shortDate(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.month, .day], from: date)
        return "\(comps.month ?? 1).\(comps.day ?? 1)"
    }
}
