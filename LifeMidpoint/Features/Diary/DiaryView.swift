import SwiftUI

struct DiaryView: View {
    var onMenuTap: () -> Void

    @State private var inputText = ""
    @State private var messages: [ChatMessage] = []
    @State private var diaryState: DiaryState = .idle

    var body: some View {
        NavigationStack {
            ZStack {
                diaryBackground

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)

                    menuButton

                    Spacer()

                    chatBubbles
                        .padding(.horizontal, 14)

                    Spacer()

                    floatingInputBar
                        .padding(.horizontal, 24)

                    diaryReviewLink
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                }
                .responsiveFill()
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .navigationDestination(for: DiaryRoute.self) { route in
                switch route {
                case .review(let hasRecords): DiaryReviewView(hasRecords: hasRecords)
                case .summary(let text): DiarySummaryView(summaryText: text)
                case .emotion(let name): EmotionDetailView(emotion: name)
                }
            }
            .onAppear {
                loadInitialDialogue()
            }
        }
    }

    enum DiaryRoute: Hashable {
        case review(hasRecords: Bool)
        case summary(text: String)
        case emotion(name: String)
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

    // MARK: - Menu Button (Figma: left-edge pink-purple tab)

    private var menuButton: some View {
        HStack {
            Button(action: onMenuTap) {
                Image("DiaryMenuIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 27)
                    .frame(width: 63, height: 77)
                    .background(Color.drawerLavender, in: UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 19,
                        topTrailingRadius: 19
                    ))
            }
            Spacer()
        }
    }

    // MARK: - Chat Bubbles

    private var chatBubbles: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(messages) { message in
                chatBubble(message)
            }
        }
    }

    private func chatBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 60) }

            Text(message.text)
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(8.75)
                .padding(.horizontal, 20)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .opacity(0.9)
                )
                .frame(maxWidth: 240, alignment: message.isFromUser ? .trailing : .leading)

            if !message.isFromUser { Spacer(minLength: 60) }
        }
    }

    // MARK: - Input Bar (Figma: capsule glass + shadow)

    private var floatingInputBar: some View {
        HStack(spacing: 0) {
            TextField("说些什么呢...", text: $inputText)
                .font(AppFont.body(16))
                .foregroundStyle(Color.dustyPurple)
                .padding(.leading, 25)
                .padding(.vertical, 12)

            Spacer()

            if !inputText.isEmpty {
                Button {
                    sendMessage()
                } label: {
                    Text("说完了")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.dustyPurple)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
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

    private func loadInitialDialogue() {
        messages = [
            ChatMessage(text: "你这几天看着有点累。\n晚上是不是没怎么睡踏实？", isFromUser: false),
            ChatMessage(text: "我感觉你一安静下来，\n就会有好多想法会冒出来，这是什么样的感觉呢！", isFromUser: false)
        ]
    }

    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        messages.append(ChatMessage(text: inputText, isFromUser: true))
        inputText = ""
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
