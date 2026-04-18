import SwiftUI

enum AppModule: String, CaseIterable {
    case diary = "日记"
    case health = "健康"
    case mind = "心境"
    case postOffice = "邮局"
    case profile = "我的"

    init?(rawValueChinese raw: String) {
        switch raw.lowercased() {
        case "diary", "日记": self = .diary
        case "health", "健康": self = .health
        case "mind", "心境": self = .mind
        case "postoffice", "邮局": self = .postOffice
        case "profile", "settings", "我的": self = .profile
        default: return nil
        }
    }
}

struct MainContainerView: View {
    @State private var selectedModule: AppModule
    @State private var isDrawerOpen = false

    init() {
        #if DEBUG
        let raw = ProcessInfo.processInfo.environment["DEBUG_MODULE"] ?? ""
        let initial: AppModule = AppModule(rawValueChinese: raw) ?? .diary
        self._selectedModule = State(initialValue: initial)
        #else
        self._selectedModule = State(initialValue: .diary)
        #endif
    }

    var body: some View {
        ZStack {
            moduleContent
                .disabled(isDrawerOpen)

            if isDrawerOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.easeOut(duration: 0.25)) { isDrawerOpen = false } }
            }

            DrawerView(
                isOpen: $isDrawerOpen,
                selectedModule: $selectedModule
            )
        }
    }

    @ViewBuilder
    private var moduleContent: some View {
        let openDrawer = { withAnimation(.easeOut(duration: 0.25)) { isDrawerOpen = true } }
        switch selectedModule {
        case .diary:
            DiaryView(onMenuTap: openDrawer)
        case .health:
            HealthDashboardView(onMenuTap: openDrawer)
        case .mind:
            MindHomeView(onMenuTap: openDrawer)
        case .postOffice:
            PostOfficeView(onMenuTap: openDrawer)
        case .profile:
            SettingsView(onMenuTap: openDrawer)
        }
    }
}
