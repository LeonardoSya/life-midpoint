import Foundation

// MARK: - Diary State Machine
//
// idle → guided → recording → childSpeaking → elderSpeaking → loading → summary

enum DiaryFlowState: String, CaseIterable {
    case idle               // 初始未触发 (2:20317)
    case guided             // 引导对话 (2:20349)
    case recording          // 用户输入多条 (2:20402)
    case childSpeaking      // 小孩说话 (2:20624)
    case elderSpeaking      // 老人说话/完成记录 (2:20550)
    case loading            // AI 加载中 (2:20663)
    case summary            // 日记总结 (2:20603)
}

struct DiaryNPCDialogue {
    let speaker: DiaryNPC
    let text: String
}

enum DiaryNPC: String {
    case child = "小女孩"
    case middle = "中年自己"
    case elder = "奶奶"
}

@MainActor
final class DiaryStateMachine: ObservableObject {
    @Published var state: DiaryFlowState = .idle
    @Published var messages: [ChatMessage] = []
    @Published var isGeneratingDiary = false

    func advance() {
        switch state {
        case .idle:
            state = .guided
        case .guided:
            state = .recording
        case .recording:
            state = .childSpeaking
        case .childSpeaking:
            state = .elderSpeaking
        case .elderSpeaking:
            state = .loading
            simulateGeneration()
        case .loading, .summary:
            break
        }
    }

    private func simulateGeneration() {
        isGeneratingDiary = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            isGeneratingDiary = false
            state = .summary
        }
    }

    func reset() {
        state = .idle
        messages.removeAll()
        isGeneratingDiary = false
    }
}
