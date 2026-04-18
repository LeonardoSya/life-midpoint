import SwiftUI

// P7.9-P7.11 经期跟踪 (2:21604)
struct PeriodTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddPeriod = false
    @State private var selectedDay = 20

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                calendarCard
                cycleInfoCard
                symptomCard
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(Color.healthPinkLight.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left").foregroundStyle(Color.textPrimary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("经期跟踪").font(AppFont.title(17))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddPeriod = true } label: {
                    Image(systemName: "plus").foregroundStyle(Color.textPrimary)
                }
            }
        }
        .sheet(isPresented: $showAddPeriod) {
            AddPeriodView()
        }
    }

    private var calendarCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chevron.left")
                Spacer()
                Text("2026 年 3 月").font(AppFont.title(14))
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(Color.textPrimary)

            HStack {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day).font(AppFont.caption(10)).foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(1...31, id: \.self) { day in
                    periodDay(day)
                }
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private func periodDay(_ day: Int) -> some View {
        let isPeriod = day >= 18 && day <= 22
        let isToday = day == selectedDay

        return Text("\(day)")
            .font(AppFont.body(13))
            .foregroundStyle(isToday ? .white : Color.textPrimary)
            .frame(width: 32, height: 32)
            .background(
                ZStack {
                    if isPeriod { Circle().fill(Color.healthPinkDark.opacity(0.3)) }
                    if isToday { Circle().fill(Color.healthPink) }
                }
            )
    }

    private var cycleInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本次周期").font(AppFont.caption(11)).foregroundStyle(Color.textSecondary)

            HStack(spacing: 24) {
                infoItem("第 5 天", "经期中")
                infoItem("28 天", "平均周期")
                infoItem("3.21", "预测下次")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private func infoItem(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(AppFont.title(16)).foregroundStyle(Color.textPrimary)
            Text(label).font(AppFont.caption(10)).foregroundStyle(Color.textSecondary)
        }
    }

    private var symptomCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日症状").font(AppFont.caption(11)).foregroundStyle(Color.textSecondary)
            HStack(spacing: 8) {
                ForEach(["腹痛", "腰酸", "乏力"], id: \.self) { sym in
                    Text(sym)
                        .font(AppFont.body(12))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.healthPinkLight, in: Capsule())
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }
}

// P7.11 添加经期 (2:22127)
struct AddPeriodView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var startDate = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))

                Spacer()

                Button { dismiss() } label: {
                    Text("确认记录")
                        .font(AppFont.body(16)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color.healthPink, in: RoundedRectangle(cornerRadius: 24))
                }
            }
            .padding(24)
            .background(Color.healthPinkLight.ignoresSafeArea())
            .navigationTitle("添加经期")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
