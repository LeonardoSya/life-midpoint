import SwiftUI

/// 统一的全屏页返回按钮。
///
/// 箭头图标本身只有 ~18pt, 但苹果人机指南建议的最小点击热区是 44x44pt——
/// 之前各个页面各自手写了一份"裸 Image + Button"的返回按钮, 没有显式撑大点击区域,
/// 在模拟器里用鼠标点(坐标精确)看不出问题, 但在真机上用手指点偏差稍大就经常点不中,
/// 表现成"返回按钮没反应"。这里统一成一个组件, 固定给到 44x44 的 `.contentShape`,
/// 后续任何页面加返回按钮都应该用这个, 不要再手搓。
struct AppBackButton: View {
    var tint: Color = Color.textPrimary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
