import SwiftUI

// MARK: - 选择邮票

struct StampSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedStamp: StampInfo
    let onSelect: (StampInfo) -> Void

    private let categories = ["人生中点", "四季花草", "给未来的信", "童年的糖罐"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)
    private var stamps: [StampInfo] { Array(StampLibrary.goldStamps.prefix(14)) }

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header

                    categoryChips

                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(stamps) { stamp in
                            Button {
                                Haptic.selection()
                                onSelect(stamp)
                            } label: {
                                stampCell(stamp)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 52)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.textPrimary)
            }
            Spacer()
            Text("选择邮票")
                .font(AppFont.title(18))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, 28)
        .padding(.top, 58)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                        .font(AppFont.body(10))
                        .foregroundStyle(Color.inkBrownDark.opacity(0.65))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.paperWarm.opacity(0.45), in: Capsule())
                }
            }
            .padding(.horizontal, 28)
        }
    }

    private func stampCell(_ stamp: StampInfo) -> some View {
        Image(stamp.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 93, height: 121)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .padding(6)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(
                        selectedStamp.id == stamp.id ? Color.inkBrownDark.opacity(0.8) : Color.stampDashed.opacity(0.22),
                        style: StrokeStyle(lineWidth: selectedStamp.id == stamp.id ? 2 : 1.5, dash: selectedStamp.id == stamp.id ? [] : [4, 3])
                    )
            )
            .shadow(color: Color.inkBrownAvatar.opacity(0.16), radius: 10, y: 4)
    }
}

// MARK: - 信件预览

struct LetterPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let content: String
    let alias: String
    let recipientMode: String
    let mood: String?
    let feeling: String?
    let weather: String?
    let letterType: String?
    let stamp: StampInfo
    let onSend: () -> Void
    let onEdit: () -> Void

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Spacer()

                letterCard
                    .padding(.horizontal, 26)

                Button {
                    Haptic.medium()
                    onSend()
                } label: {
                    Text("唤来信鸽")
                        .font(AppFont.body(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(hex: 0x926247), in: Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                Button {
                    Haptic.light()
                    onEdit()
                } label: {
                    Text("重新编辑")
                        .font(AppFont.body(16))
                        .foregroundStyle(Color(hex: 0x926247))
                        .underline()
                }
                .padding(.top, 20)

                Spacer()
            }
            .responsiveFill()
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.textPrimary)
            }
            Spacer()
            Text("信件预览")
                .font(AppFont.title(18))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, 24)
        .padding(.top, 58)
    }

    private var letterCard: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.paperWarm)
                    .frame(height: 220)

                VStack(alignment: .leading, spacing: 8) {
                    stampSlots

                    Text(recipientMode == "self" ? "写给 自己：" : "寄给 陌生的人：")
                        .font(AppFont.body(10))
                        .foregroundStyle(Color.textPrimary)
                        .padding(.top, 6)

                    Text(previewSentence)
                        .font(AppFont.title(14))
                        .foregroundStyle(Color.textPrimary)
                        .lineSpacing(8)
                        .frame(maxWidth: 250, alignment: .leading)

                    HStack {
                        Spacer()
                        Text("来自：\(alias)")
                            .font(AppFont.body(10))
                            .foregroundStyle(Color.textPrimary)
                    }
                    .padding(.top, 26)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
            }

            Image(stamp.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 94)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(5)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.stampDashed.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                )
                .rotationEffect(.degrees(12))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
                .offset(x: -6, y: -40)
        }
    }

    private var stampSlots: some View {
        HStack(spacing: 4) {
            ForEach(0..<6, id: \.self) { _ in
                Rectangle()
                    .stroke(Color.inkBrownDark.opacity(0.32), lineWidth: 1)
                    .frame(width: 14, height: 14)
            }
            Spacer()
            Rectangle()
                .stroke(Color.inkBrownDark.opacity(0.32), lineWidth: 1)
                .frame(width: 54, height: 70)
        }
    }

    private var previewSentence: String {
        if let weather, let mood, let letterType {
            return "此时\(weather)，身处\(mood)。\n觉察\(feeling ?? "心情平静")，寄出一份\(letterType)。"
        }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "愿那些说不出口的话，也能被温柔地送达。" : trimmed
    }
}
