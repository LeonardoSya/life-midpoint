import SwiftUI
import SwiftData

// P4.22 我的笔友 (2:23857)
struct PenPalListView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \PenPal.lastActiveAt, order: .reverse)
    private var penPals: [PenPal]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                headerRow

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(penPals) { pal in
                            penPalCard(name: pal.name, info: pal.info, time: relativeTime(pal.lastActiveAt))
                        }
                    }
                    .padding(.horizontal, 0)
                    .padding(.vertical, 4)
                }

                Spacer().frame(height: 34)

                calendarLetterPanel
            }
            .padding(.horizontal, 19)
            .padding(.top, 104)
            .padding(.bottom, 32)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
    }

    private var headerRow: some View {
        HStack {
            Text("我的笔友")
                .font(AppFont.body(16))
                .foregroundStyle(Color.textPrimary.opacity(0.8))
            Spacer()
            HStack(spacing: 4) {
                Text("查看全部")
                    .font(AppFont.body(13))
                Image(systemName: "chevron.right")
                    .font(.system(size: 9))
            }
            .foregroundStyle(Color.mindPrimary.opacity(0.7))
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: Date())
    }

    private func penPalCard(name: String, info: String, time: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(AppFont.title(16))
                .foregroundStyle(Color(hex: 0x454545))
            Text(info)
                .font(AppFont.body(11))
                .foregroundStyle(Color(hex: 0x9D9D9D))

            Spacer()

            HStack {
                Text(time)
                    .font(AppFont.body(12))
                    .foregroundStyle(Color(hex: 0x8A8A8A))
                Spacer()
                Circle()
                    .fill(.white)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "ellipsis")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.textSecondary)
                    )
            }
        }
        .padding(16)
        .frame(width: 150, height: 140)
        .background(Color.postCream.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.18), radius: 2, y: 4)
    }

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
                Image(systemName: "chevron.left")
                    .font(.system(size: 12))
                Spacer()
                Text("2026 二月")
                    .font(AppFont.title(14))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
            }
            .foregroundStyle(Color.textPrimary)

            HStack {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .font(AppFont.caption(11))
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(20...26, id: \.self) { day in
                    Text("\(day)")
                        .font(AppFont.body(13))
                        .foregroundStyle(day == 20 ? Color.inkBrownGold : Color.textPrimary)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle().fill(day == 20 ? Color.postCream : .clear)
                        )
                }
            }
        }
    }

    private var letterPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.brandMutedGold, lineWidth: 1)
                        .frame(width: 24, height: 16)
                        .padding(.horizontal, 2)
                }
                Spacer()
            }

            Text("寄给云端的朋友：")
                .font(AppFont.body(11))
                .foregroundStyle(Color.textSecondary)
            Text("此时\u{201C}云朵很美\u{201D}，身处旅行途中。\n觉察充满期待，寄出一份今日见闻。")
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(4)
            Text("来自：琥珀与猫")
                .font(AppFont.body(11))
                .foregroundStyle(Color.textSecondary)
                .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.paperWarm, in: RoundedRectangle(cornerRadius: 12))
    }
}

// P4.24 笔友详情 (2:23774)
struct PenPalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let name: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .center, spacing: 8) {
                    Circle()
                        .fill(Color.chipBackgroundSelected)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Text(String(name.prefix(1)))
                                .font(AppFont.title(24))
                                .foregroundStyle(Color.textPrimary)
                        )
                    Text(name)
                        .font(AppFont.title(18))
                    Text("往来 23 封书信")
                        .font(AppFont.caption(12))
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)

                ForEach(0..<5, id: \.self) { i in
                    letterRow(isFromMe: i % 2 == 0)
                }
            }
            .padding(24)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
    }

    private func letterRow(isFromMe: Bool) -> some View {
        HStack {
            if isFromMe { Spacer() }

            VStack(alignment: .leading, spacing: 4) {
                Text(isFromMe ? "寄出 →" : "← 收到")
                    .font(AppFont.caption(10))
                    .foregroundStyle(isFromMe ? Color.mindPrimary : Color.postReceivedInk)
                Text("今天的风很轻，我想把那些焦虑\n都吹散在云里...")
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(4)
            }
            .padding(16)
            .frame(maxWidth: 260, alignment: .leading)
            .background(isFromMe ? .white : Color.postCream)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            if !isFromMe { Spacer() }
        }
    }
}
