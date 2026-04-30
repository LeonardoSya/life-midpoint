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
    @State private var path: NavigationPath
    @State private var activeModule: AppModule
    @State private var showDiaryStampObtained = false
    @StateObject private var audio = AudioPlayer.shared
    @State private var showSideNavigation = false

    init() {
        #if DEBUG
        let raw = ProcessInfo.processInfo.environment["DEBUG_MODULE"] ?? ""
        let initial: AppModule = AppModule(rawValueChinese: raw) ?? .diary
        var initialPath = NavigationPath()
        if initial != .diary {
            initialPath.append(initial)
        }
        self._path = State(initialValue: initialPath)
        self._activeModule = State(initialValue: initial)
        #else
        self._path = State(initialValue: NavigationPath())
        self._activeModule = State(initialValue: .diary)
        #endif
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .leading) {
                DiaryView(onMenuTap: {
                    withAnimation(drawerAnimation) {
                        showSideNavigation = true
                    }
                }, useOwnNavigationStack: false, onNavigate: { route in
                    path.append(route)
                })

                if showSideNavigation {
                    SideNavigationDrawer(
                        selectedModule: activeModule,
                        onSelect: { module in
                            navigateToModule(module)
                        },
                        onClose: {
                            withAnimation(drawerAnimation) {
                                showSideNavigation = false
                            }
                        }
                    )
                    .zIndex(20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AppModule.self) { module in
                moduleDestination(module)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .navigationDestination(for: HealthDashboardView.HealthRoute.self) { route in
                HealthDashboardView(useOwnNavigationStack: false).healthDestination(route)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .navigationDestination(for: MindHomeView.MindRoute.self) { route in
                MindHomeView(useOwnNavigationStack: false).mindDestination(route)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .navigationDestination(for: PostOfficeView.PostOfficeRoute.self) { route in
                PostOfficeView(useOwnNavigationStack: false).postOfficeDestination(route)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .navigationDestination(for: SettingsView.SettingsRoute.self) { route in
                SettingsView(useOwnNavigationStack: false).settingsDestination(route)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .navigationDestination(for: DiaryView.DiaryRoute.self) { route in
                diaryDestination(route)
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
        .onAppear { syncAmbient(for: activeModule) }
        .onChange(of: path.count) { _, count in
            if count == 0 {
                activeModule = .diary
            }
            syncAmbient(for: activeModule)
        }
        .fullScreenCover(isPresented: $showDiaryStampObtained) {
            StampObtainedView(stampImageName: "GoldStamp2")
        }
        .onDisappear { audio.stop(channel: .ambient) }
    }

    @ViewBuilder
    private func moduleDestination(_ module: AppModule) -> some View {
        switch module {
        case .diary:
            EmptyView()
        case .health:
            HealthDashboardView(onBackToDiary: popToDiary, useOwnNavigationStack: false)
        case .mind:
            MindHomeView(onBackToDiary: popToDiary, useOwnNavigationStack: false)
        case .postOffice:
            PostOfficeView(onBackToDiary: popToDiary, useOwnNavigationStack: false)
        case .profile:
            SettingsView(onBackToDiary: popToDiary, useOwnNavigationStack: false)
        }
    }

    @ViewBuilder
    private func diaryDestination(_ route: DiaryView.DiaryRoute) -> some View {
        switch route {
        case .review(let hasRecords):
            DiaryReviewView(hasRecords: hasRecords)
        case .summary(let text):
            DiarySummaryView(summaryText: text) {
                showDiaryStampObtained = true
            }
        case .emotion(let name):
            EmotionDetailView(emotion: name)
        }
    }

    private var drawerAnimation: Animation {
        .spring(response: 0.32, dampingFraction: 0.86, blendDuration: 0.04)
    }

    private func navigateToModule(_ module: AppModule) {
        guard module != .diary else {
            withAnimation(drawerAnimation) {
                showSideNavigation = false
            }
            return
        }
        withAnimation(drawerAnimation) {
            showSideNavigation = false
        }
        activeModule = module
        path = NavigationPath()
        path.append(module)
    }

    private func popToDiary() {
        guard path.count > 0 else { return }
        path = NavigationPath()
        activeModule = .diary
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
