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
        moduleContent
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomTabBar(selectedModule: $selectedModule)
            }
    }

    @ViewBuilder
    private var moduleContent: some View {
        switch selectedModule {
        case .diary:      DiaryView()
        case .health:     HealthDashboardView()
        case .mind:       MindHomeView()
        case .postOffice: PostOfficeView()
        case .profile:    SettingsView()
        }
    }
}
