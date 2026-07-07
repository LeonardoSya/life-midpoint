import SwiftUI

/// 主操作按钮 (绿色填充胶囊)
struct PrimaryButton: View {
    let title: String
    var color: Color = .mindPrimary
    var foreground: Color = .white
    var fullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            Haptic.medium()
            action()
        } label: {
            Text(title)
                .font(AppFont.title(16))
                .foregroundStyle(foreground)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.vertical, 16)
                .padding(.horizontal, fullWidth ? 0 : 32)
                .background(color, in: RoundedRectangle(cornerRadius: 28))
        }
    }
}

/// 次要操作 (描边胶囊)
struct SecondaryButton: View {
    let title: String
    var color: Color = .textSecondary
    let action: () -> Void

    var body: some View {
        Button {
            Haptic.light()
            action()
        } label: {
            Text(title)
                .font(AppFont.body(14))
                .foregroundStyle(color)
                .padding(.horizontal, 32)
                .padding(.vertical, 10)
                .background(Capsule().stroke(Color.borderLight, lineWidth: 1))
        }
    }
}

