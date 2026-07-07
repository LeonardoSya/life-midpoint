import SwiftUI

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
