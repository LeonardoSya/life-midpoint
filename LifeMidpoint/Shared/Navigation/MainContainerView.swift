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
    @StateObject private var audio = AudioPlayer.shared

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
            .onAppear { syncAmbient(for: selectedModule) }
            .onChange(of: selectedModule) { _, new in
                syncAmbient(for: new)
            }
            .onDisappear { audio.stop(channel: .ambient) }
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

    /// 基于当前 tab 同步 ambient 白噪音.
    /// - 日记页: 海浪 (符合设计稿"海边咖啡厅"意象, 轻柔陪伴记录)
    /// - 其他 tab: 停止 ambient, 避免干扰
    /// Diary tab 内部 push 子页 (回顾日记/情绪详情等) 不会触发 selectedModule 变化,
    /// 所以海浪会持续播放, 不会在跳转瞬间断掉.
    private func syncAmbient(for module: AppModule) {
        switch module {
        case .diary:
            guard audio.currentAmbient != AudioAssets.whiteNoiseWaves else { return }
            audio.play(file: AudioAssets.whiteNoiseWaves,
                       channel: .ambient,
                       loop: true,
                       volume: 0.35)
        default:
            audio.stop(channel: .ambient)
        }
    }
}
