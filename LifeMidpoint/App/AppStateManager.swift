import SwiftUI
import SwiftData

enum AppPhase {
    case auth
    case onboarding
    case main
}

/// App 级状态机.
///
/// 启动流程: **onboarding → login → main**
/// - 冷启动直接进 onboarding (产品要求每次重播 14 步开场动画)
/// - onboarding 完成 → 跳到登录页
/// - 登录完成 → 进入主界面
///
/// 内存层 (`@Published`) 缓存的同时, **用户档案** 通过 `UserRepository` 持久化到 SwiftData.
/// `hasCompletedOnboarding` 当前不从数据库恢复 (每次冷启动重播),
/// 但姓名/生日会跨启动保留, step 11/12 对话替换 "xx" 时使用.
@MainActor
final class AppStateManager: ObservableObject {
    @Published var phase: AppPhase = .onboarding
    @Published var isAuthenticated = false

    /// 当前进程是否已经完成 onboarding. 不持久化 -> 每次冷启动重播.
    @Published var hasCompletedOnboarding: Bool = false

    /// 来自 UserProfile.displayName, 内存缓存便于 SwiftUI 反应式更新.
    @Published var userName: String = ""
    @Published var userBirthday: Date?

    private let userRepo: UserRepository

    init() {
        let context = AppDatabase.shared.mainContext
        self.userRepo = UserRepository(context: context)

        // 从数据库恢复持久化档案
        let profile = AppDatabase.profile(in: context)
        self.userName = profile.displayName
        self.userBirthday = profile.birthday

        #if DEBUG
        // DEBUG: 允许通过环境变量覆盖姓名, 方便验证 step 11/12 的 xx 替换
        if let override = ProcessInfo.processInfo.environment["DEBUG_USER_NAME"], !override.isEmpty {
            self.userName = override
        }
        #endif

        userRepo.markActive()
    }

    /// 对话文案中 "xx" 占位符的实际渲染值.
    /// 用户未填写时 fallback 到 "你" 以保持语义流畅.
    var displayName: String {
        userName.trimmingCharacters(in: .whitespaces).isEmpty ? "你" : userName
    }

    // MARK: - Onboarding

    /// Onboarding step 10 提交时调用: 同时更新内存缓存 + 持久化到数据库.
    func saveProfile(name: String, birthday: Date?) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        userName = trimmed
        userBirthday = birthday
        userRepo.updateProfile(name: trimmed, birthday: birthday)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        userRepo.markActive()
        // Onboarding 完成后, 已登录则直接进主界面, 否则跳到登录页
        phase = isAuthenticated ? .main : .auth
    }

    // MARK: - Auth

    func completeLogin() {
        isAuthenticated = true
        // 走完 onboarding 进 main; 万一从其他流程进 login (重新登录) 也回 main
        phase = .main
    }

    func logout() {
        isAuthenticated = false
        // 退出后回到 onboarding (与冷启动行为一致, 让用户再走一遍开场)
        hasCompletedOnboarding = false
        phase = .onboarding
    }
}
