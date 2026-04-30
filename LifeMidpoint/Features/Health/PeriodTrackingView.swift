import SwiftUI

// MARK: - 经期跟踪 (2:21604)

struct PeriodTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddPeriod = false
    @State private var selectedDay = 3

    var body: some View {
        ZStack {
            Color(hex: 0xF9F9F8, alpha: 0.6).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    periodTabs
                    calendarPanel
                    recordSection
                    symptomDetailPanel
                    tipPanel
                }
                .padding(.horizontal, 20)
                .padding(.top, 90)
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
                Button { } label: {
                    Image(systemName: "ellipsis")
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
            tabItem("日", selected: false)
            tabItem("月", selected: true)
            tabItem("年", selected: false)
        }
        .padding(4)
        .frame(maxWidth: .infinity)
        .overlay(Capsule().stroke(Color.cultured, lineWidth: 1))
    }

    private func tabItem(_ label: String, selected: Bool) -> some View {
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

    private var calendarPanel: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("二月")
                    .font(AppFont.title(18))
                Spacer()
                Image(systemName: "chevron.left").frame(width: 38, height: 38).background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                Image(systemName: "chevron.right").frame(width: 38, height: 38).background(Color.white, in: RoundedRectangle(cornerRadius: 12))
            }
            HStack(spacing: 6) {
                ForEach(0..<6, id: \.self) { index in
                    calendarDayCell(day: ["日", "一", "二", "三", "四", "五"][index],
                                    date: ["01", "02", "03", "04", "05", "06"][index],
                                    selected: index == 2)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 26))
    }

    private func calendarDayCell(day: String, date: String, selected: Bool) -> some View {
        VStack(spacing: 8) {
            Text(day)
                .font(AppFont.body(15))
                .foregroundStyle(selected ? Color(hex: 0xFCF0ED) : Color.mutedGray)
            Text(date)
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

    private var recordSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("记录").font(AppFont.title(18))
            recordRow(title: "出血", value: "经期", plusColor: Color(hex: 0xF65555))
            Text("其他症状")
                .font(AppFont.title(16))
                .foregroundStyle(Color(hex: 0xFF9181))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func recordRow(title: String, value: String, plusColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle().fill(Color(hex: 0xFF9181)).frame(width: 5, height: 5)
                Text(title).font(AppFont.title(16)).foregroundStyle(Color(hex: 0xFF9181))
            }
            HStack {
                Text(value).font(AppFont.body(14)).foregroundStyle(Color(hex: 0xFF9181))
                Spacer()
                Text("+").font(AppFont.title(19)).foregroundStyle(plusColor)
            }
            .padding(.horizontal, 12)
            .frame(height: 29)
            .background(Color(hex: 0xF8ECEA), in: Capsule())
        }
    }

    private var symptomDetailPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("症状详情").font(AppFont.body(18))
                Spacer()
                Image(systemName: "ellipsis").frame(width: 32, height: 32).background(Color.white, in: Circle())
            }
            symptomDropRow("点滴出血", icon: "drop")
            symptomDropRow("Arm location", icon: "figure.arms.open")
        }
        .padding(12)
        .background(Color.cultured, in: RoundedRectangle(cornerRadius: 30))
    }

    private func symptomDropRow(_ title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Circle().fill(Color(hex: 0xF8E4E1).opacity(0.9)).frame(width: 40, height: 40)
                .overlay(Image(systemName: icon).foregroundStyle(Color.healthPink))
            Text(title).font(AppFont.body(15))
            Spacer()
            HStack {
                Text("未设置").font(AppFont.body(14))
                Image(systemName: "chevron.down").font(.system(size: 11))
            }
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(Color.cultured, in: RoundedRectangle(cornerRadius: 16))
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
}

// MARK: - 添加经期 (2:22127)

struct AddPeriodView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                formCard
                    .padding(.horizontal, 28)
                .padding(.top, 92)
                    .padding(.bottom, 44)
            }
        }
        .overlay(alignment: .top) { topBar }
    }

    private var topBar: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea(edges: .top).frame(height: 108)
            HStack {
                Button { dismiss() } label: { Image(systemName: "arrow.left").foregroundStyle(Color.mindPrimary) }
                Spacer()
                Text("经期历史").font(AppFont.title(24))
                Spacer()
                Image(systemName: "ellipsis").frame(width: 39, height: 39).background(Color.white, in: Circle())
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
                Button { Haptic.light() } label: {
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

            Text("起始日期")
                .font(AppFont.title(17))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Image(systemName: "calendar")
                .font(.system(size: 14))
                .foregroundStyle(Color.textPrimary.opacity(0.8))
                .frame(width: 40, height: 40)
                .background(Color.white, in: Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
        }
    }

    private var dateGrid: some View {
        VStack(spacing: 12) {
            calendarControls

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 7) {
                ForEach(Array(calendarDays.enumerated()), id: \.offset) { index, day in
                    calendarDateCell(day, selected: index == 17, faded: index < 3 || index > 32)
                }
            }
        }
    }

    private var calendarControls: some View {
        HStack(spacing: 8) {
            monthYearControl(title: "一月")
            monthYearControl(title: "2026")
        }
    }

    private func monthYearControl(title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "chevron.left")
                .font(.system(size: 12, weight: .medium))
                .frame(width: 34, height: 34)
                .background(Color.cultured, in: Circle())
            Text(title)
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .frame(width: 34, height: 34)
                .background(Color.cultured, in: Circle())
        }
        .frame(maxWidth: .infinity)
    }

    private var calendarDays: [String] {
        [
            "28", "29", "30", "01", "02", "03", "04",
            "05", "06", "07", "08", "09", "10", "11",
            "12", "13", "14", "15", "16", "17", "18",
            "19", "20", "21", "22", "23", "24", "25",
            "26", "27", "28", "29", "30", "01", "02"
        ]
    }

    private func calendarDateCell(_ day: String, selected: Bool, faded: Bool) -> some View {
        Text(day)
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

    private var addRows: some View {
        VStack(spacing: 12) {
            addRow("出血量", value: "中等")
            addRow("症状", value: "无")
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
    }

    private func addRow(_ title: String, value: String) -> some View {
        HStack {
            Circle()
                .fill(Color(hex: 0xFFB0A4))
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "waveform").font(.system(size: 14)).foregroundStyle(.white))
            Text(title).font(AppFont.title(16))
            Spacer()
            HStack(spacing: 14) {
                Text(value).font(AppFont.body(14))
                Image(systemName: "chevron.down").font(.system(size: 12))
            }
            .padding(.horizontal, 18)
            .frame(height: 42)
            .background(Color.white, in: Capsule())
        }
        .padding(8)
        .background(Color.cultured, in: RoundedRectangle(cornerRadius: 18))
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button("取消") { dismiss() }
                .font(AppFont.body(16))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(Color.cultured, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.16), radius: 4, y: 4)
            Button("保存") { dismiss() }
                .font(AppFont.body(16))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(Color(hex: 0xFFB0A4), in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.16), radius: 4, y: 4)
        }
    }
}
