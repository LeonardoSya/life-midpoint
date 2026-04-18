import SwiftUI

/// 区块标题: 左侧主标题 + 可选右侧链接
struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var trailingText: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).titleStyle(20)
                if let subtitle {
                    Text(subtitle).secondaryStyle(12)
                }
            }
            Spacer()
            if let trailingText {
                Button {
                    Haptic.light()
                    trailingAction?()
                } label: {
                    Text(trailingText).secondaryStyle(12)
                }
            }
        }
    }
}

/// 小标签: TYPE 标签风格 (uppercase, tracking)
struct CategoryLabel: View {
    let text: String
    var color: Color = .textSecondary

    var body: some View {
        Text(text)
            .font(AppFont.body(12))
            .foregroundStyle(color)
            .tracking(1.2)
    }
}
