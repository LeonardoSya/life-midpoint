import SwiftUI

/// 信件卡片方向
enum LetterDirection {
    case sent, received

    var label: String { self == .sent ? "寄出→" : "←收回" }
    var accentColor: Color { self == .sent ? .mindPrimary : .postReceivedInk }
    var bgColor: Color { self == .sent ? .white : .postCream }
}

/// 信件卡片 (用于邮局首页 / 笔友详情)
struct LetterCard: View {
    let entry: LetterEntry

    var body: some View {
        let direction: LetterDirection = entry.isFromMe ? .sent : .received

        return HStack {
            if direction == .sent { Spacer() }

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text(direction.label)
                        .font(AppFont.body(10))
                        .foregroundStyle(direction.accentColor)
                        .tracking(-0.5)
                    Text(entry.time)
                        .font(AppFont.body(10))
                        .foregroundStyle(Color.textSecondary)
                }

                Text(entry.content)
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.textSecondary)
                    .lineSpacing(9.38)
            }
            .padding(.horizontal, direction == .sent ? 24 : 20)
            .padding(.vertical, 20)
            .frame(width: 274, alignment: .leading)
            .background(direction.bgColor)
            .clipShape(LetterShape(direction: direction))
            .shadow(color: .black.opacity(0.05), radius: 1, y: 1)

            if direction == .received { Spacer() }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Shapes

struct LetterShape: Shape {
    let direction: LetterDirection

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 32
        if direction == .sent {
            return Path(roundedRect: rect,
                        cornerRadii: .init(topLeading: r, bottomLeading: r, bottomTrailing: 0, topTrailing: r))
        } else {
            return Path(roundedRect: rect,
                        cornerRadii: .init(topLeading: r, bottomLeading: 0, bottomTrailing: r, topTrailing: r))
        }
    }
}

