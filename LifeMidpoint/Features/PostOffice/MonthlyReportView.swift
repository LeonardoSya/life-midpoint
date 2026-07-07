import SwiftUI

// P4.17-P4.21 邮局月报 (2:19764)
struct MonthlyReportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Int = 12
    @State private var showWriteLetter = false

    private let daysInMonth = 31

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    calendarLetterCard
                    myPenPalsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showWriteLetter) { WriteLetterView() }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.textPrimary)
            }
            Spacer()
            Text("邮局月报")
                .font(AppFont.title(17))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private var calendarLetterCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            calendarContent
            letterPreview
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: 0xAFB3B2, alpha: 0.1), lineWidth: 1)
        )
        .shadow(color: Color(hex: 0x2F3333, alpha: 0.04), radius: 16, y: 12)
    }

    private var calendarContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
                Text("三月 2026")
                    .font(AppFont.body(16))
                    .foregroundStyle(Color.textPrimary.opacity(0.8))
            }

            HStack(spacing: 12) {
                legendDot(color: Color(hex: 0xA5B4FC), label: "写给自己的信")
                legendDot(color: Color(hex: 0x9CAF88), label: "寄给她人的信")
                legendDot(color: Color(hex: 0xFD795A), label: "收到的回信")
            }

            calendarGrid
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
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
                    .font(AppFont.body(13))
                    .foregroundStyle(day == selectedDate ? Color.textPrimary : Color.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(day == selectedDate ? Color.postCream : Color.clear)
                    )
                    .overlay {
                        if day == selectedDate {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.inkBrownGold, lineWidth: 1)
                        }
                    }

                // Letter dots for specific days
                HStack(spacing: 2) {
                    if day == 12 {
                        letterDot(0x9CAF88)
                        letterDot(0xFD795A)
                        letterDot(0xA5B4FC)
                    }
                    if day == 10 { letterDot(0xA5B4FC) }
                    if day == 15 { letterDot(0xFD795A) }
                    if day == 18 { letterDot(0x9CAF88) }
                }
                .frame(height: 6)
            }
        }
    }

    private func letterDot(_ hex: UInt) -> some View {
        Circle().fill(Color(hex: hex)).frame(width: 4, height: 4)
    }

    private var letterPreview: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    ForEach(0..<6, id: \.self) { _ in
                        Rectangle()
                            .stroke(Color(hex: 0x7C5907, alpha: 0.6), lineWidth: 1)
                            .frame(width: 14, height: 16)
                    }
                }

                Text("寄给 陌生的人：")
                    .font(AppFont.title(10))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.top, 14)

                monthlySentence
                    .padding(.top, 4)

                Text("来自：屋檐与猫")
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
    }

    private var monthlySentence: some View {
        let base = AppFont.title(12)
        let hi = AppFont.title(13)
        let hiColor = Color(hex: 0x733F19)
        return VStack(alignment: .leading, spacing: 2) {
            Text("此时").font(base).foregroundStyle(Color.textPrimary)
            + Text("云朵很美").font(hi).foregroundStyle(hiColor)
            + Text("，身处").font(base).foregroundStyle(Color.textPrimary)
            + Text("旅行途中").font(hi).foregroundStyle(hiColor)
            + Text("。").font(base).foregroundStyle(Color.textPrimary)

            Text("觉察").font(base).foregroundStyle(Color.textPrimary)
            + Text("充满期待").font(hi).foregroundStyle(hiColor)
            + Text("，寄出一份").font(base).foregroundStyle(Color.textPrimary)
            + Text("今日见闻").font(hi).foregroundStyle(hiColor)
            + Text("。").font(base).foregroundStyle(Color.textPrimary)
        }
        .lineSpacing(4)
    }

    private var myPenPalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Text("我的笔友")
                    .font(AppFont.body(16))
                    .foregroundStyle(Color.textPrimary.opacity(0.8))
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                HStack(spacing: 4) {
                    Text("查看全部")
                        .font(AppFont.caption(12))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9))
                }
                .foregroundStyle(Color.mindPrimary.opacity(0.7))
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
                    .foregroundStyle(Color.mindPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.mindPrimary.opacity(0.05), in: Capsule())
            }
        }
        .padding(17)
        .background(Color.postCardBg, in: RoundedRectangle(cornerRadius: 12))
    }
}
