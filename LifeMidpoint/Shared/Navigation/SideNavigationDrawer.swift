import SwiftUI

/// 日记页专用侧边导航抽屉。
///
/// 只从 DiaryView 首页触发；进入其他模块后不再显示模块切换入口。
struct SideNavigationDrawer: View {
    let selectedModule: AppModule
    let onSelect: (AppModule) -> Void
    let onClose: () -> Void

    private let items: [(module: AppModule, icon: String)] = [
        (.diary, "book.closed"),
        (.health, "heart"),
        (.mind, "leaf"),
        (.postOffice, "envelope"),
        (.profile, "person")
    ]

    var body: some View {
        ZStack(alignment: .leading) {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 18) {
                ForEach(items, id: \.module) { item in
                    drawerButton(module: item.module, icon: item.icon)
                }
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule().stroke(Color.white.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: Color.textPrimary.opacity(0.12), radius: 18, x: 0, y: 10)
            .padding(.leading, 18)
            .transition(.move(edge: .leading).combined(with: .opacity))
        }
    }

    private func drawerButton(module: AppModule, icon: String) -> some View {
        let selected = module == selectedModule
        return Button {
            Haptic.selection()
            onSelect(module)
        } label: {
            VStack(spacing: 5) {
                Image(systemName: selected ? "\(icon).fill" : icon)
                    .font(.system(size: 17, weight: selected ? .semibold : .regular))
                    .frame(width: 34, height: 28)
                Text(module.rawValue)
                    .font(AppFont.body(9))
            }
            .foregroundStyle(selected ? Color.textPrimary : Color.textSecondary.opacity(0.62))
            .frame(width: 54, height: 54)
            .background(
                Circle()
                    .fill(selected ? Color.white.opacity(0.68) : Color.white.opacity(0.18))
            )
        }
        .buttonStyle(.plain)
    }
}

/// 非日记模块首页左上角返回日记按钮。
/// 放在各模块根页面内部，push 到子页面后自然消失。
struct ModuleHomeBackButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            Haptic.light()
            action()
        } label: {
            Image(systemName: "arrow.left")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .frame(width: 42, height: 42)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }
}
