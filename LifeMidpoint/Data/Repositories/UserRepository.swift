import Foundation
import SwiftData

/// 用户档案 + App 设置仓储.
/// 全部都是单例式 (UserProfile / AppSettings 各只有一行).
@MainActor
struct UserRepository {
    let context: ModelContext

    // MARK: - UserProfile

    func profile() -> UserProfile {
        AppDatabase.profile(in: context)
    }

    /// 更新用户档案 (Onboarding step 10 提交时调用).
    func updateProfile(name: String, birthday: Date?) {
        let p = profile()
        p.displayName = name.trimmingCharacters(in: .whitespaces)
        p.birthday = birthday
        p.updatedAt = Date()
        try? context.save()
    }

    // MARK: - AppSettings

    func settings() -> AppSettings {
        AppDatabase.settings(in: context)
    }

    func updateAmbiance(_ value: String) {
        let s = settings()
        s.ambianceMode = value
        s.lastActiveAt = Date()
        try? context.save()
    }

    func updateWhiteNoise(_ value: String) {
        let s = settings()
        s.whiteNoiseMode = value
        s.lastActiveAt = Date()
        try? context.save()
    }

    func markOnboardingComplete() {
        let s = settings()
        s.hasCompletedOnboarding = true
        s.lastActiveAt = Date()
        try? context.save()
    }

    func markActive() {
        let s = settings()
        s.lastActiveAt = Date()
        try? context.save()
    }
}
