import SwiftUI

// P4.17-P4.21 邮局月报 (2:19764)
struct MonthlyReportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Int = 12
    @State private var showWriteLetter = false

    private let daysInMonth = 31

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                calendarCard
                letterPreview
                myPenPalsSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .sheet(isPresented: $showWriteLetter) { WriteLetterView() }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(Color.textPrimary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("邮局月报")
                    .font(AppFont.title(17))
            }
        }
    }

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
                Text("三月 2026")
                    .font(AppFont.title(14))
                    .foregroundStyle(Color.textPrimary)
            }

            HStack(spacing: 12) {
                legendDot(color: Color.sleepSecondary, label: "写给自己的信")
                legendDot(color: Color.mutedGray, label: "寄给她人的信")
                legendDot(color: Color.healthPink, label: "收到的回信")
            }

            calendarGrid
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(AppFont.caption(10))
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var calendarGrid: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(AppFont.caption(11))
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(1...daysInMonth, id: \.self) { day in
                    dayCell(day)
                }
            }
        }
    }

    private func dayCell(_ day: Int) -> some View {
        Button {
            selectedDate = day
        } label: {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(AppFont.body(14))
                    .foregroundStyle(day == selectedDate ? .white : Color.textPrimary)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle().fill(day == selectedDate ? Color.textSecondary : .clear)
                    )

                // Letter dots for specific days
                HStack(spacing: 2) {
                    if day == 10 { Circle().fill(Color.sleepSecondary).frame(width: 4, height: 4) }
                    if day == 12 || day == 15 {
                        Circle().fill(Color.healthPink).frame(width: 4, height: 4)
                    }
                    if day == 18 { Circle().fill(Color.mutedGray).frame(width: 4, height: 4) }
                }
                .frame(height: 6)
            }
        }
    }

    private var letterPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.brandMutedGold, lineWidth: 1)
                        .frame(width: 28, height: 18)
                        .padding(.horizontal, 2)
                }
                Spacer()
            }

            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.brandMutedGold, lineWidth: 1)
                .frame(width: 40, height: 40)
                .overlay(alignment: .topTrailing) { EmptyView() }

            VStack(alignment: .leading, spacing: 4) {
                Text("寄给 陌生的人：")
                    .font(AppFont.body(12))
                    .foregroundStyle(Color.textSecondary)

                Text("此时\u{201C}云朵很美\u{201D}，身处旅行途中。")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.textSecondary)

                Text("觉察充满期待，寄出一份今日见闻。")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.textSecondary)

                Text("来自：琥珀与猫")
                    .font(AppFont.body(12))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.paperWarm, in: RoundedRectangle(cornerRadius: 12))
    }

    private var myPenPalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("我的笔友")
                    .font(AppFont.title(16))
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text("查看全部")
                    .font(AppFont.caption(12))
                    .foregroundStyle(Color.textSecondary)
            }

            penPalRow(avatar: "云", name: "云端的朋友", count: 5)
            penPalRow(avatar: "野", name: "旷野之息", count: 3)
        }
    }

    private func penPalRow(avatar: String, name: String, count: Int) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.chipBackgroundSelected)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(avatar)
                        .font(AppFont.title(14))
                        .foregroundStyle(Color.textPrimary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.textPrimary)
                Text("已通信 \(count) 次")
                    .font(AppFont.caption(10))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Button { showWriteLetter = true } label: {
                Text("发送新信")
                    .font(AppFont.body(12))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().stroke(Color.borderLight, lineWidth: 1))
            }
        }
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 12))
    }
}
