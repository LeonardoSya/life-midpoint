import SwiftUI

enum AppPhase {
    case auth
    case onboarding
    case main
}

@MainActor
final class AppStateManager: ObservableObject {
    @Published var phase: AppPhase = .auth
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    func completeLogin() {
        isAuthenticated = true
        phase = hasCompletedOnboarding ? .main : .onboarding
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        phase = .main
    }

    func logout() {
        isAuthenticated = false
        phase = .auth
    }
}
