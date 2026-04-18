import SwiftUI

/// 底部 TabBar: 替代左侧 Drawer, 5 个一级模块平铺
///
/// 设计:
/// - 半透明毛玻璃背景, 贴合 app 暖色调
/// - 选中态: 填充图标 + textPrimary 深色
/// - 非选中态: 线框图标 + textSecondary 淡化
/// - 点击触发 Haptic.selection 反馈
struct BottomTabBar: View {
    @Binding var selectedModule: AppModule

    private let items: [TabItem] = [
        TabItem(module: .diary,      icon: "book.closed",     activeIcon: "book.closed.fill"),
        TabItem(module: .health,     icon: "heart",           activeIcon: "heart.fill"),
        TabItem(module: .mind,       icon: "leaf",            activeIcon: "leaf.fill"),
        TabItem(module: .postOffice, icon: "envelope",        activeIcon: "envelope.fill"),
        TabItem(module: .profile,    icon: "person",          activeIcon: "person.fill")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                tabButton(item)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .padding(.bottom, 0)
        .background(.ultraThinMaterial)
    }

    private func tabButton(_ item: TabItem) -> some View {
        let selected = selectedModule == item.module
        return Button {
            guard !selected else { return }
            Haptic.selection()
            withAnimation(.easeOut(duration: 0.2)) {
                selectedModule = item.module
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: selected ? item.activeIcon : item.icon)
                    .font(.system(size: 18, weight: selected ? .semibold : .regular))
                    .frame(height: 22)

                Text(item.module.rawValue)
                    .font(AppFont.body(9))
                    .tracking(0.4)
            }
            .foregroundStyle(selected ? Color.textPrimary.opacity(0.9) : Color.textSecondary.opacity(0.45))
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct TabItem: Identifiable {
    let module: AppModule
    let icon: String
    let activeIcon: String

    var id: AppModule { module }
}
