import SwiftUI

struct MindHomeView: View {
    var onBackToDiary: (() -> Void)? = nil
    var useOwnNavigationStack = true

    /// 是否在出现时弹出"情绪识别门"(仅从导航栏进入心境时为 true).
    @State private var showEmotionGate: Bool

    init(onBackToDiary: (() -> Void)? = nil,
         useOwnNavigationStack: Bool = true,
         presentsEmotionGate: Bool = false) {
        self.onBackToDiary = onBackToDiary
        self.useOwnNavigationStack = useOwnNavigationStack
        self._showEmotionGate = State(initialValue: presentsEmotionGate)
    }

    /// 分类图标映射。分类名称的唯一真值来源是 `KnowledgeLibrary.categories`,
    /// 这里只负责把名称映射到首页网格用的图标, 避免名称重复定义导致导航静默错配。
    private static let categoryIcons: [String: String] = [
        "身体与情绪": "waveform.path.ecg",
        "情绪急救": "plus.square",
        "关系与沟通": "bubble.left",
        "自我成长": "sparkles",
    ]

    @State private var path: NavigationPath = {
        #if DEBUG
        let raw = ProcessInfo.processInfo.environment["DEBUG_PUSH_MIND"] ?? ""
        var p = NavigationPath()
        switch raw {
        case "breathing": p.append(MindRoute.breathing)
        case "microBehavior": p.append(MindRoute.microBehavior)
        case "microEmotion": p.append(MindRoute.microEmotion)
        case "knowledge": p.append(MindRoute.knowledge(category: nil))
        case "emotionDetail": p.append(MindRoute.emotionDetail(name: "潮热"))
        default: break
        }
        return p
        #else
        return NavigationPath()
        #endif
    }()

    var body: some View {
        if useOwnNavigationStack {
            NavigationStack(path: $path) {
                content
                    .navigationDestination(for: MindRoute.self) { route in
                        Self.mindDestination(route)
                    }
            }
        } else {
            content
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 19) {
                if let onBackToDiary {
                    HStack {
                        ModuleHomeBackButton(action: onBackToDiary)
                        Spacer()
                    }
                }
                MindHeroCard()
                PracticeAndExperimentSection()
                knowledgeCategorySection
            }
            .padding(.horizontal, 24)
            .padding(.top, 37)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("心境")
                    .font(AppFont.title(24))
                    .tracking(1.44)
            }
        }
        .fullScreenCover(isPresented: $showEmotionGate) {
            EmotionRecognitionGate(onFinish: { showEmotionGate = false })
        }
    }

    @ViewBuilder
    static func mindDestination(_ route: MindRoute) -> some View {
        switch route {
        case .breathing: BreathingExerciseView()
        case .microBehavior: MicroBehaviorExperimentView()
        case .microEmotion: MicroEmotionStartView()
        case .psychologyCard(let articleId): PsychologyCardView(article: KnowledgeLibrary.article(for: articleId))
        case .knowledge(let category): KnowledgeBaseView(initialCategory: category)
        case .emotionDetail(let name): EmotionDetailView(emotion: name)
        }
    }

    enum MindRoute: Hashable {
        case breathing, microBehavior, microEmotion
        case psychologyCard(articleId: String)
        case knowledge(category: String?)
        case emotionDetail(name: String)
    }

    // MARK: - Knowledge Categories (2x2 Grid)

    private var knowledgeCategorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("探索知识分类")
                .font(AppFont.title(14))
                .tracking(0.7)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 24), GridItem(.flexible())], spacing: 32) {
                ForEach(KnowledgeLibrary.categories) { cat in
                    NavigationLink(value: MindRoute.knowledge(category: cat.name)) {
                        categoryItem(icon: Self.categoryIcons[cat.name] ?? "questionmark", name: cat.name)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.bottom, 48)
    }

    private func categoryItem(icon: String, name: String) -> some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.mintMistBg)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mindPrimary)
                )

            Text(name).bodyStyle(14).foregroundStyle(Color.textSecondary)
        }
    }
}
