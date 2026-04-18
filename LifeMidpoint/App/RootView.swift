import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppStateManager

    var body: some View {
        #if DEBUG
        debugContent
        #else
        normalFlow
        #endif
    }

    #if DEBUG
    @ViewBuilder
    private var debugContent: some View {
        switch DebugPreview.mode {
        case .normal: normalFlow
        case .main: MainContainerView()
        case .login: LoginView()
        case .onboarding: OnboardingFlowView()
        case .diary: DiaryView()
        case .diaryReview: DiaryReviewView(hasRecords: true)
        case .diaryReviewEmpty: DiaryReviewView(hasRecords: false)
        case .diaryLoading: DiaryLoadingView()
        case .postOffice: PostOfficeView()
        case .writeLetter: WriteLetterView()
        case .writeLetterDefault: WriteLetterDefaultView()
        case .letterShowcase: LetterShowcaseView()
        case .letterSent: LetterSentView()
        case .monthlyReport: NavigationStack { MonthlyReportView() }
        case .penPalList: NavigationStack { PenPalListView() }
        case .penPalDetail: NavigationStack { PenPalDetailView(name: "偷喝一口月亮") }
        case .stampAlbum: NavigationStack { StampAlbumView() }
        case .stampShowcase: StampShowcaseView(stamp: StampLibrary.goldStamps[1])
        case .stampObtained: StampObtainedView(stampImageName: "GoldStamp2")
        case .mind: MindHomeView()
        case .breathing: BreathingExerciseView()
        case .microBehavior: MicroBehaviorExperimentView()
        case .microEmotionStart: MicroEmotionStartView()
        case .microEmotionEnd: MicroEmotionEndView()
        case .psychologyCard: PsychologyCardView()
        case .knowledgeBase: NavigationStack { KnowledgeBaseView() }
        case .health: HealthDashboardView()
        case .periodTracking: NavigationStack { PeriodTrackingView() }
        case .symptomTracking: NavigationStack { SymptomTrackingView() }
        case .symptomDetail: NavigationStack { SymptomDetailView(symptomName: "潮热") }
        case .sleep: NavigationStack { SleepView() }
        case .heartRate: NavigationStack { HeartRateView() }
        case .healthSummary: NavigationStack { HealthSummaryView() }
        case .medicationRecord: NavigationStack { MedicationRecordView() }
        case .medicationReminder: NavigationStack { MedicationReminderView() }
        case .editReminder: EditReminderView()
        case .myMedications: NavigationStack { MyMedicationsView() }
        case .settings: SettingsView()
        case .weeklySummary: NavigationStack { WeeklySummaryView(variant: 0) }
        case .emotionPicker:
            Color.black.opacity(0.4).overlay(EmotionPickerSheet().padding())
        case .emotionDetail: EmotionDetailView(emotion: "疲惫")
        case .diarySummary:
            DiarySummaryView(summaryText: "3月24日 疲惫但平静的晴天\n\n今天才意识到，最近其实一直有点乱。")
        }
    }
    #endif

    @ViewBuilder
    private var normalFlow: some View {
        switch appState.phase {
        case .auth: LoginView().transition(.opacity)
        case .onboarding: OnboardingFlowView().transition(.opacity)
        case .main: MainContainerView().transition(.opacity)
        }
    }
}
