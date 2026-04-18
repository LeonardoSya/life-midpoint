import SwiftUI

struct MindHomeView: View {
    var onMenuTap: () -> Void = {}

    private let categories: [(icon: String, name: String)] = [
        ("waveform.path.ecg", "身体与情绪"),
        ("plus.square", "情绪急救"),
        ("bubble.left", "关系与沟通"),
        ("sparkles", "自我成长")
    ]

    @State private var path: NavigationPath = {
        #if DEBUG
        let raw = ProcessInfo.processInfo.environment["DEBUG_PUSH_MIND"] ?? ""
        var p = NavigationPath()
        switch raw {
        case "breathing": p.append(MindRoute.breathing)
        case "microBehavior": p.append(MindRoute.microBehavior)
        case "microEmotion": p.append(MindRoute.microEmotion)
        case "knowledge": p.append(MindRoute.knowledge)
        case "emotionDetail": p.append(MindRoute.emotionDetail(name: "潮热"))
        default: break
        }
        return p
        #else
        return NavigationPath()
        #endif
    }()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 19) {
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onMenuTap) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.textPrimary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("心境")
                        .font(AppFont.title(24))
                        .tracking(1.44)
                }
            }
            .navigationDestination(for: MindRoute.self) { route in
                switch route {
                case .breathing: BreathingExerciseView()
                case .microBehavior: MicroBehaviorExperimentView()
                case .microEmotion: MicroEmotionStartView()
                case .psychologyCard: PsychologyCardView()
                case .knowledge: KnowledgeBaseView()
                case .emotionDetail(let name): EmotionDetailView(emotion: name)
                }
            }
        }
    }

    enum MindRoute: Hashable {
        case breathing, microBehavior, microEmotion, psychologyCard, knowledge
        case emotionDetail(name: String)
    }

    // MARK: - Knowledge Categories (2x2 Grid)

    private var knowledgeCategorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("探索知识分类")
                .font(AppFont.title(14))
                .tracking(0.7)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 24), GridItem(.flexible())], spacing: 32) {
                ForEach(categories, id: \.name) { cat in
                    NavigationLink(value: MindRoute.knowledge) {
                        categoryItem(icon: cat.icon, name: cat.name)
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
