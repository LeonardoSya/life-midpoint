import Foundation
import SwiftData

// MARK: - 用户档案 (单例: 全 app 只有 1 行)

/// Onboarding step 10 用户填写的"小时候自己"档案.
///
/// 单例模式: 通过 `AppDatabase.profile(in:)` 访问, 不存在自动创建.
/// 显示名 (`displayName`) 用于对话替换 "xx", `birthday` 用于"人生进度"等模块.
@Model
final class UserProfile {
    var displayName: String
    var birthday: Date?
    var createdAt: Date
    var updatedAt: Date

    init(displayName: String = "", birthday: Date? = nil) {
        self.displayName = displayName
        self.birthday = birthday
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }

    /// 渲染对话占位时使用 (空名 fallback 为"你").
    var displayNameOrFallback: String {
        let trimmed = displayName.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "你" : trimmed
    }
}

// MARK: - App 设置 (单例)

/// 全局偏好 + 状态标志.
///
/// 包含:
/// - Onboarding 完成标志 (按当前需求每次冷启动重播, 此字段保留供未来切换策略)
/// - 时间氛围模式 (Settings 页)
/// - 白噪音偏好 (Settings 页. 注意: 日记 tab 海浪由 MainContainerView 强制覆盖)
@Model
final class AppSettings {
    var hasCompletedOnboarding: Bool
    var ambianceMode: String        // "自动" / "白天" / "黄昏" / "夜晚"
    var whiteNoiseMode: String      // "关闭" / "海浪" / "风" / "雨"
    var firstLaunchAt: Date
    var lastActiveAt: Date

    init(
        hasCompletedOnboarding: Bool = false,
        ambianceMode: String = "自动",
        whiteNoiseMode: String = "关闭"
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.ambianceMode = ambianceMode
        self.whiteNoiseMode = whiteNoiseMode
        let now = Date()
        self.firstLaunchAt = now
        self.lastActiveAt = now
    }
}
