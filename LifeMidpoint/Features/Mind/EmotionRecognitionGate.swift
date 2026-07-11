import SwiftUI

/// 情绪识别门: 从导航栏进入"心境"前的情绪识别流程.
///
/// 流程: 弹窗1(选择情绪 + 强烈程度) → "确认记录"(写情绪记录 + 发"情绪采样者"邮票) →
/// 弹窗2(对应情绪的详情/引导) → "不了，我想自己看看"进入心境首页.
/// 在弹窗1点"跳过", 同样直接进入心境首页(不发邮票).
struct EmotionRecognitionGate: View {
    @Environment(\.modelContext) private var modelContext

    /// 关闭整个门, 露出底下的心境首页.
    let onFinish: () -> Void

    /// 情绪采样邮票: "情绪采样者"(gold_2), 与微情绪实验奖励同款.
    private static let emotionStampId = "gold_2"

    @State private var path = NavigationPath()

    /// 门内部路由(仅"选完情绪进入对应详情"一种), 用专用枚举而非裸 String 避免误命中.
    private enum GateRoute: Hashable {
        case detail(emotionName: String)
    }

    var body: some View {
        NavigationStack(path: $path) {
            picker
                .navigationDestination(for: GateRoute.self) { route in
                    switch route {
                    case .detail(let name):
                        EmotionDetailView(emotion: name, onFinish: onFinish)
                            .toolbar(.hidden, for: .navigationBar)
                    }
                }
        }
    }

    // MARK: - 弹窗1

    private var picker: some View {
        ScrollView(showsIndicators: false) {
            EmotionPickerSheet(
                onConfirm: { name, icon, intensity in
                    record(name: name, icon: icon, intensity: intensity)
                    path.append(GateRoute.detail(emotionName: name))
                },
                onSkip: onFinish
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - 记录 + 发邮票

    /// 写入情绪打卡, 并在首次获得时发放"情绪采样者"邮票.
    private func record(name: String, icon: String, intensity: Double) {
        DiaryRepository(context: modelContext)
            .logEmotion(name: name, icon: icon, intensity: intensity)

        let postOffice = PostOfficeRepository(context: modelContext)
        if !postOffice.hasStamp(definitionId: Self.emotionStampId) {
            postOffice.grantStamp(definitionId: Self.emotionStampId, source: "mind_emotion")
        }
    }
}
