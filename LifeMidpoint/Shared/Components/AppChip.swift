import SwiftUI

/// 通用 Chip 选择器 (描边或填充)
struct AppChip: View {
    let text: String
    var icon: String? = nil
    var isSelected: Bool = false
    var style: ChipStyle = .outlined
    var action: () -> Void = {}

    enum ChipStyle {
        case outlined          // 描边
        case filledNeutral     // 灰色填充
        case filledAccent      // 主题色填充
        case filledDark        // 黑底白字
    }

    var body: some View {
        Button {
            Haptic.selection()
            action()
        } label: {
            HStack(spacing: 4) {
                if let icon { Image(systemName: icon).font(.system(size: 11)) }
                Text(text).font(AppFont.body(13))
            }
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(background)
        }
    }

    private var foregroundColor: Color {
        switch (isSelected, style) {
        case (true, .filledDark): return .white
        case (true, .filledAccent): return .white
        case (true, _): return .textPrimary
        case (false, _): return .textSecondary
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .outlined:
            Capsule().stroke(isSelected ? Color.textPrimary : Color.borderLight, lineWidth: 1)
        case .filledNeutral:
            Capsule().fill(isSelected ? Color.chipBackgroundSelected : Color.chipBackgroundIdle)
        case .filledAccent:
            Capsule().fill(isSelected ? Color.mindPrimary : Color.mindChipBg)
        case .filledDark:
            Capsule().fill(isSelected ? Color.textPrimary : Color.chipBackgroundIdle)
        }
    }
}
