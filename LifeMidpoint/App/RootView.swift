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
        case .diaryReview:
            // DiaryReviewView 内的"查看完整回忆"只会推出 .memoryDetail, 其余 case 在此预览路径下不会被触发。
            NavigationStack {
                DiaryReviewView(hasRecords: true)
                    .navigationDestination(for: DiaryView.DiaryRoute.self) { route in
                        if case .memoryDetail(let date, let title, let body) = route {
                            DiaryMemoryDetailView(date: date, title: title, bodyText: body)
                        }
                    }
            }
        case .diaryReviewEmpty: DiaryReviewView(hasRecords: false)
        case .diaryMemoryDetail:
            // 用一个占位根页面 + 自动 push 的方式包装, 这样返回按钮 (dismiss) 有真实的
            // 上一页可以弹回, 而不是像直接把 DiaryMemoryDetailView 当 NavigationStack
            // 根视图那样 (dismiss 在栈底是 no-op, 点击返回没有任何反应).
            NavigationStack {
                DebugPushRoot {
                    DiaryMemoryDetailView(
                        date: Date(),
                        title: "抱恙寻暖的微雨天",
                        bodyText: "今天感冒来得突然，全身酸软，连呼吸都有些沉重。晚上躺在床上，仿佛听见年老的自己轻轻走到床边，用温热的掌心覆在额头上，告诉我委屈也是被允许的。\n而年幼的那个我也从记忆里跑出来，笨拙地倒了一杯热水，叮嘱我把被子裹紧好好睡一觉。原来我从不是一个人在生病。"
                    )
                }
            }
        case .diaryLoading: DiaryLoadingView()
        case .postOffice: PostOfficeView()
        case .writeLetter: WriteLetterView()
        case .writeLetterDefault: WriteLetterDefaultView()
        case .stampSelection:
            NavigationStack {
                StampSelectionView(selectedStamp: StampLibrary.goldStamps[1]) { _ in }
            }
        case .letterPreview:
            NavigationStack {
                LetterPreviewView(
                    content: "此时云朵很美，身处旅行途中。觉察充满期待，寄出一份今日见闻。",
                    alias: "屋檐与猫",
                    recipientMode: "stranger",
                    mood: "旅行途中",
                    feeling: "充满期待",
                    weather: "云朵很美",
                    letterType: "今日见闻",
                    stamp: StampLibrary.goldStamps[1],
                    onSend: {},
                    onEdit: {}
                )
            }
        case .letterSent: LetterSentView()
        case .monthlyReport: NavigationStack { MonthlyReportView() }
        case .penPalList: NavigationStack { PenPalListView() }
        case .penPalDetail: NavigationStack { PenPalDetailView(name: "偷喝一口月亮") }
        case .stampAlbum: NavigationStack { StampAlbumView() }
        case .stampShowcase:
            // 同 .diaryMemoryDetail: 用占位根页面包一层, 让返回按钮弹回有真实效果可验证,
            // 而不是作为 NavigationStack 根视图时 dismiss 的 no-op.
            NavigationStack {
                DebugPushRoot { StampShowcaseView(stamp: StampLibrary.goldStamps[1]) }
            }
        case .stampObtained: StampObtainedView(stampImageName: "GoldStamp2")
        case .mind: MindHomeView()
        case .breathing: BreathingExerciseView()
        case .microBehavior: MicroBehaviorExperimentView()
        case .microEmotionStart: MicroEmotionStartView()
        case .microEmotionEnd: MicroEmotionEndView()
        case .psychologyCard: PsychologyCardView(article: KnowledgeLibrary.article(for: Self.debugArticleId))
        case .knowledgeBase:
            NavigationStack {
                KnowledgeBaseView(initialCategory: Self.debugCategory)
                    .navigationDestination(for: MindHomeView.MindRoute.self) { route in
                        MindHomeView.mindDestination(route)
                    }
            }
        case .health: HealthDashboardView()
        case .periodTracking: NavigationStack { PeriodTrackingView() }
        case .addPeriod: AddPeriodView()
        case .symptomTracking: NavigationStack { SymptomTrackingView() }
        case .symptomDetail: NavigationStack { SymptomDetailView(symptomName: "潮热") }
        case .sleep: NavigationStack { SleepView() }
        case .heartRate: NavigationStack { HeartRateView() }
        case .healthSummary: NavigationStack { HealthSummaryView() }
        case .medicationRecord: NavigationStack { MedicationRecordView() }
        case .medicationReminder: NavigationStack { MedicationReminderView() }
        case .editReminder: NavigationStack { EditReminderView() }
        case .myMedications: NavigationStack { MyMedicationsView() }
        case .settings: SettingsView()
        case .weeklySummary: NavigationStack { WeeklySummaryView(variant: 0) }
        case .emotionPicker:
            Color.pageBackground.ignoresSafeArea()
                .overlay(ScrollView { EmotionPickerSheet().padding(12) })
        case .emotionDetail:
            NavigationStack { EmotionDetailView(emotion: Self.debugEmotionName) }
        case .emotionGate:
            EmotionRecognitionGate(onFinish: {})
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

    #if DEBUG
    /// 用 DEBUG_EMOTION 环境变量切换 EmotionDetail 预览的情绪, 默认"疲惫".
    private static var debugEmotionName: String {
        let raw = ProcessInfo.processInfo.environment["DEBUG_EMOTION"] ?? ""
        return raw.isEmpty ? "疲惫" : raw
    }

    /// 用 DEBUG_ARTICLE 环境变量切换 PsychologyCard 预览的文章 id, 默认潮热.
    /// 传入未知 id 时回落到默认, 避免 article(for:) 的 fail-fast 让截图调试崩溃.
    private static var debugArticleId: String {
        let raw = ProcessInfo.processInfo.environment["DEBUG_ARTICLE"] ?? ""
        let exists = KnowledgeLibrary.allArticles.contains { $0.id == raw }
        return exists ? raw : KnowledgeLibrary.defaultArticleId
    }

    /// 用 DEBUG_CATEGORY 环境变量切换知识库预览的初始分类, 默认 nil(第一个分类).
    private static var debugCategory: String? {
        let raw = ProcessInfo.processInfo.environment["DEBUG_CATEGORY"] ?? ""
        return raw.isEmpty ? nil : raw
    }
    #endif
}

#if DEBUG
/// 调试预览专用: 提供一个占位根页面, 挂载后立即自动 push 到 `destination`.
/// 用于需要验证"返回按钮能否弹回上一页"的单页调试入口 —
/// 直接把目标视图当 NavigationStack 根视图时, dismiss() 在栈底是 no-op,
/// 无法验证真实的返回效果, 包一层占位根页面后返回才有地方可去.
private struct DebugPushRoot<Destination: View>: View {
    @ViewBuilder let destination: () -> Destination
    @State private var isPushed = true

    var body: some View {
        Color.pageBackground.ignoresSafeArea()
            .overlay {
                Text("调试根页面 · 返回后应显示此页")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
            }
            .navigationDestination(isPresented: $isPushed) {
                destination()
            }
    }
}
#endif
