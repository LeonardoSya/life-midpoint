import SwiftUI
import SwiftData

struct DiaryView: View {
    var onMenuTap: (() -> Void)? = nil
    var useOwnNavigationStack = true
    var onNavigate: ((DiaryRoute) -> Void)? = nil

    @Environment(\.modelContext) private var modelContext
    @State private var inputText = ""
    @State private var session: DiarySession?
    @State private var agentSessionId: String?
    @State private var isSending = false
    @State private var loadingDotCount = 1
    @State private var loadingTask: Task<Void, Never>?
    @State private var agentReplyTask: Task<Void, Never>?
    @State private var isGeneratingSummary = false
    @State private var continuedAfterRoundCount = 0
    @State private var showStampObtained = false
    @State private var path = NavigationPath()
    @State private var diaryState: DiaryState = .idle

    private var repo: DiaryRepository { DiaryRepository(context: modelContext) }

    /// 当前 session 的消息按时间排序. SwiftData 的 @Model 关系变化会触发 view 重绘.
    private var messages: [DiaryMessage] {
        (session?.messages ?? []).sorted { $0.sentAt < $1.sentAt }
    }

    private var bubbleItems: [DiaryBubbleItem] {
        var assistantIndex = 0
        var items: [DiaryBubbleItem] = messages.map { message in
            let parsed = parseMessage(message, assistantIndex: assistantIndex)
            if !message.isFromUser { assistantIndex += 1 }
            return parsed
        }

        if isSending {
            let dots = String(repeating: ".", count: loadingDotCount)
            items.append(.loading(speaker: .grandma, text: dots))
            items.append(.loading(speaker: .girl, text: dots))
        }

        return items
    }

    private var scrollTarget: String {
        guard let last = bubbleItems.last else { return "" }
        return "\(last.id)-\(last.text.count)"
    }

    private var userRoundCount: Int {
        messages.filter(\.isFromUser).count
    }

    private var shouldShowRecordActions: Bool {
        userRoundCount > 0
            && userRoundCount.isMultiple(of: 3)
            && continuedAfterRoundCount != userRoundCount
            && !isSending
            && !isGeneratingSummary
    }

    var body: some View {
        if useOwnNavigationStack {
            NavigationStack(path: $path) {
                diaryContent
                    .navigationDestination(for: DiaryRoute.self) { route in
                        diaryDestination(route)
                    }
            }
        } else {
            diaryContent
        }
    }

    private var diaryContent: some View {
        ZStack {
            diaryBackground

            VStack(spacing: 0) {
                Spacer()

                chatBubbles
                    .padding(.horizontal, 14)

                Spacer()

                if shouldShowRecordActions {
                    recordActionBar
                        .padding(.horizontal, 47)
                } else {
                    floatingInputBar
                        .padding(.horizontal, 24)
                }

                diaryReviewLink
                    .padding(.top, 12)
                    .padding(.bottom, 22)
            }
            .responsiveFill()

            if isGeneratingSummary {
                DiaryLoadingView()
                    .transition(.opacity)
                    .zIndex(10)
            }

            if let onMenuTap {
                diaryMenuButton(action: onMenuTap)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isGeneratingSummary)
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showStampObtained) {
            StampObtainedView(stampImageName: "GoldStamp2")
        }
        .onAppear {
            loadInitialDialogue()
        }
        .onDisappear {
            agentReplyTask?.cancel()
            stopLoadingAnimation()
        }
    }

    @ViewBuilder
    func diaryDestination(_ route: DiaryRoute) -> some View {
        switch route {
        case .review(let hasRecords): DiaryReviewView(hasRecords: hasRecords)
        case .summary(let text):
            DiarySummaryView(summaryText: text) {
                showStampObtained = true
            }
        case .emotion(let name): EmotionDetailView(emotion: name)
        }
    }

    enum DiaryRoute: Hashable {
        case review(hasRecords: Bool)
        case summary(text: String)
        case emotion(name: String)
    }

    private func diaryMenuButton(action: @escaping () -> Void) -> some View {
        VStack {
            HStack {
                Button {
                    Haptic.selection()
                    action()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.textPrimary.opacity(0.82))
                        .frame(width: 46, height: 46)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.45), lineWidth: 1))
                        .shadow(color: Color.textPrimary.opacity(0.12), radius: 12, y: 8)
                }
                .buttonStyle(.plain)
                .padding(.leading, 18)
                .padding(.top, 58)

                Spacer()
            }
            Spacer()
        }
    }

    // MARK: - Background (Figma: gradient overlay + image at 50% opacity)

    private var diaryBackground: some View {
        ZStack {
            Color.pageBackground

            LinearGradient(
                colors: [
                    Color.warmGradientTop.opacity(0.5),
                    Color.pageBackground.opacity(0.5),
                    Color.warmGradientBottom.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image("DiaryBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.5)
        }
        .ignoresSafeArea()
    }

    // MARK: - Chat Bubbles

    private var chatBubbles: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(bubbleItems.enumerated()), id: \.element.id) { index, item in
                        chatBubble(item)
                            .padding(.top, overlapTopPadding(for: item, at: index))
                            .transition(
                                .opacity
                                    .combined(with: .move(edge: .bottom))
                                    .combined(with: .scale(scale: 0.98, anchor: .bottom))
                            )
                    }
                }
                .padding(.vertical, 8)
                .animation(.easeOut(duration: 0.38), value: bubbleItems.map(\.id))
            }
            .onChange(of: scrollTarget) { _, _ in
                if let last = bubbleItems.last?.id {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if let last = bubbleItems.last?.id {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func overlapTopPadding(for item: DiaryBubbleItem, at index: Int) -> CGFloat {
        guard index > 0 else { return 0 }
        let previous = bubbleItems[index - 1]
        if previous.speaker.isAgent && item.speaker.isAgent && previous.speaker != item.speaker {
            return -28
        }
        if item.speaker == .user && previous.speaker.isAgent {
            return 22
        }
        return 0
    }

    @ViewBuilder
    private func chatBubble(_ item: DiaryBubbleItem) -> some View {
        switch item.speaker {
        case .user:
            userBubble(item)
        case .grandma:
            agentBubble(item, alignment: .trailing, tail: .right)
        case .girl, .assistant:
            agentBubble(item, alignment: .leading, tail: .left)
        }
    }

    private func userBubble(_ item: DiaryBubbleItem) -> some View {
        HStack {
            Spacer(minLength: 0)
            VStack(spacing: 0) {
                bubbleText(item.text, loading: item.isLoading, centered: true)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 17)
                    .frame(maxWidth: 315, minHeight: 54, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.58))
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(0.18)
                    )

                TriangleShape(direction: .down)
                    .fill(Color.white.opacity(0.58))
                    .frame(width: 30, height: 18)
                    .offset(y: -1)
            }
            .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
        }
        .id(item.id)
    }

    private func agentBubble(
        _ item: DiaryBubbleItem,
        alignment: HorizontalAlignment,
        tail: DiaryBubbleTail
    ) -> some View {
        HStack {
            if alignment == .trailing { Spacer(minLength: 108) }

            HStack(spacing: 0) {
                if tail == .left {
                    TriangleShape(direction: .left)
                        .fill(Color.white.opacity(agentBubbleOpacity(for: item.speaker)))
                        .frame(width: 26, height: 17)
                        .offset(x: 2)
                }

                bubbleText(item.text, loading: item.isLoading)
                    .padding(.leading, 20)
                    .padding(.trailing, 24)
                    .padding(.vertical, 15)
                    .frame(maxWidth: 248, minHeight: 56, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(agentBubbleOpacity(for: item.speaker)))
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(0.14)
                    )

                if tail == .right {
                    TriangleShape(direction: .right)
                        .fill(Color.white.opacity(agentBubbleOpacity(for: item.speaker)))
                        .frame(width: 26, height: 17)
                        .offset(x: -2)
                }
            }
            .offset(x: tail == .right ? -14 : 14)

            if alignment == .leading { Spacer(minLength: 108) }
        }
        .id(item.id)
    }

    private func agentBubbleOpacity(for speaker: DiaryBubbleSpeaker) -> Double {
        switch speaker {
        case .grandma: return 0.39
        case .girl, .assistant: return 0.45
        case .user: return 0.58
        }
    }

    private func bubbleText(_ text: String, loading: Bool, centered: Bool = false) -> some View {
        Text(text)
            .font(AppFont.body(18))
            .foregroundStyle(Color.textSecondary)
            .lineSpacing(5)
            .multilineTextAlignment(centered ? .center : .leading)
            .opacity(loading ? 0.68 : 1)
    }

    // MARK: - Input Bar (Figma: capsule glass + shadow)

    private var recordActionBar: some View {
        HStack(spacing: 16) {
            Button {
                Haptic.selection()
                continuedAfterRoundCount = userRoundCount
            } label: {
                Text("继续记录")
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.dustyPurple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.72))
                            .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
                    )
            }

            Button {
                generateDiarySummary()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13))
                    Text(isGeneratingSummary ? "生成中" : "生成日记")
                        .font(AppFont.body(14))
                }
                .foregroundStyle(Color.dustyPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.drawerLavender.opacity(0.72))
                        .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
                )
            }
            .disabled(isGeneratingSummary)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var floatingInputBar: some View {
        HStack(spacing: 0) {
            TextField("说些什么呢...", text: $inputText)
                .font(AppFont.body(16))
                .foregroundStyle(Color.dustyPurple)
                .padding(.leading, 25)
                .padding(.vertical, 12)

            Spacer()

            if !inputText.isEmpty || isSending {
                Button {
                    sendMessage()
                } label: {
                    Text(isSending ? "倾听中" : "说完了")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.dustyPurple)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .disabled(isSending)
            }
        }
        .padding(.trailing, 9)
        .frame(height: 56)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 24, y: 12)
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Review Link

    private var diaryReviewLink: some View {
        NavigationLink(value: DiaryRoute.review(hasRecords: !messages.isEmpty)) {
            Text("回顾我的日记")
                .font(AppFont.body(16))
                .foregroundStyle(Color.mauve)
                .underline()
                .tracking(-0.369)
        }
    }

    // MARK: - Logic

    /// 取持久化的最近 session, 没有则新建.
    /// 不再自动播种默认气泡; 旧版本已经写入的默认气泡会在无用户消息时清理掉.
    private func loadInitialDialogue() {
        let s = repo.currentOrNewSession()
        session = s
        removeLegacyDefaultBubblesIfNeeded(from: s)
    }

    private func removeLegacyDefaultBubblesIfNeeded(from session: DiarySession) {
        let legacyTexts: Set<String> = [
            "奶奶：你这几天看着有点累。\n晚上是不是没怎么睡踏实？",
            "小女孩：我感觉你一安静下来，\n就会有好多想法会冒出来，这是什么样的感觉呢！",
        ]
        let messages = session.messages
        guard !messages.contains(where: \.isFromUser),
              messages.allSatisfy({ legacyTexts.contains($0.text) }) else { return }
        for message in messages {
            repo.delete(message)
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let session, !isSending else { return }

        withAnimation(.easeOut(duration: 0.38)) {
            repo.append(text: text, isFromUser: true, to: session)
        }
        inputText = ""
        withAnimation(.easeOut(duration: 0.28)) {
            isSending = true
        }
        startLoadingAnimation()

        let currentAgentSessionId = agentSessionId

        agentReplyTask?.cancel()
        agentReplyTask = Task { @MainActor in
            do {
                let response = try await DiaryAgentClient.shared.send(
                    message: text,
                    sessionId: currentAgentSessionId
                )
                guard !Task.isCancelled else { return }
                agentSessionId = response.sessionId
                isSending = false
                stopLoadingAnimation()
                for reply in response.replies {
                    await streamReply(reply, into: session)
                }
            } catch {
                isSending = false
                stopLoadingAnimation()
                repo.append(
                    text: "奶奶：我这会儿有点听不清，但我还在这里陪你。",
                    isFromUser: false,
                    to: session
                )
            }
            agentReplyTask = nil
        }
    }

    private func generateDiarySummary() {
        guard let session, !isGeneratingSummary else { return }
        isGeneratingSummary = true
        Haptic.medium()

        let history = messages.map { message in
            DiaryAgentClient.HistoryMessage(
                role: message.isFromUser ? "user" : "assistant",
                content: message.text
            )
        }
        let currentAgentSessionId = agentSessionId

        Task { @MainActor in
            do {
                let summary = try await DiaryAgentClient.shared.summarize(
                    sessionId: currentAgentSessionId,
                    history: history
                )
                agentSessionId = summary.sessionId
                repo.updateSummary(summary.summaryText, for: session)
                repo.createEntry(title: summary.title, body: summary.body, summaryText: summary.summaryText)
                continuedAfterRoundCount = userRoundCount
                isGeneratingSummary = false
                navigate(to: .summary(text: summary.summaryText))
            } catch {
                isGeneratingSummary = false
                repo.append(
                    text: "奶奶：今天的日记暂时没有整理好，我们可以再慢慢来一次。",
                    isFromUser: false,
                    to: session
                )
            }
        }
    }

    private func navigate(to route: DiaryRoute) {
        if useOwnNavigationStack {
            path.append(route)
        } else {
            onNavigate?(route)
        }
    }

    private func streamReply(_ reply: DiaryAgentClient.Reply, into session: DiarySession) async {
        let prefix = "\(reply.displayName)："
        let message = repo.append(text: prefix, isFromUser: false, to: session)
        var current = ""

        for char in reply.content {
            guard !Task.isCancelled else { return }
            current.append(char)
            repo.updateMessageText(message, text: prefix + current)
            try? await Task.sleep(nanoseconds: 18_000_000)
        }

        repo.updateMessageText(message, text: prefix + reply.content, persist: true)
    }

    private func startLoadingAnimation() {
        stopLoadingAnimation()
        loadingDotCount = 1
        loadingTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 380_000_000)
                guard !Task.isCancelled else { return }
                loadingDotCount = loadingDotCount % 4 + 1
            }
        }
    }

    private func stopLoadingAnimation() {
        loadingTask?.cancel()
        loadingTask = nil
    }

    private func parseMessage(_ message: DiaryMessage, assistantIndex: Int) -> DiaryBubbleItem {
        if message.isFromUser {
            return DiaryBubbleItem(id: String(describing: message.id), speaker: .user, text: message.text)
        }

        if let content = message.text.removingPrefix("奶奶：") {
            return DiaryBubbleItem(id: String(describing: message.id), speaker: .grandma, text: content)
        }
        if let content = message.text.removingPrefix("小女孩：") {
            return DiaryBubbleItem(id: String(describing: message.id), speaker: .girl, text: content)
        }

        // 兼容旧数据: 没有角色前缀的历史 assistant 消息按顺序交替左右气泡.
        let fallbackSpeaker: DiaryBubbleSpeaker = assistantIndex.isMultiple(of: 2) ? .grandma : .girl
        return DiaryBubbleItem(id: String(describing: message.id), speaker: fallbackSpeaker, text: message.text)
    }
}

// MARK: - Models

enum DiaryState {
    case idle, guided, recording, loading, summary
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}

private enum DiaryBubbleSpeaker: Equatable {
    case user
    case grandma
    case girl
    case assistant

    var isAgent: Bool {
        self == .grandma || self == .girl || self == .assistant
    }
}

private struct DiaryBubbleItem: Identifiable {
    let id: String
    let speaker: DiaryBubbleSpeaker
    let text: String
    var isLoading = false

    static func loading(speaker: DiaryBubbleSpeaker, text: String) -> DiaryBubbleItem {
        DiaryBubbleItem(id: "loading-\(speaker)", speaker: speaker, text: text, isLoading: true)
    }
}

private enum DiaryBubbleTail {
    case left
    case right
    case down
}

private struct TriangleShape: Shape {
    let direction: DiaryBubbleTail

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch direction {
        case .left:
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        case .right:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        case .down:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
        path.closeSubpath()
        return path
    }
}

private extension String {
    func removingPrefix(_ prefix: String) -> String? {
        guard hasPrefix(prefix) else { return nil }
        return String(dropFirst(prefix.count))
    }
}
