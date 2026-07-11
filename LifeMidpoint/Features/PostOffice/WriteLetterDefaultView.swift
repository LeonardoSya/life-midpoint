import PhotosUI
import SwiftUI

// P4.10 写信默认页 (2:19723)
//
// 工具条功能设计:
// - "+"   灵感开头: 写不下去时, 从一组开头短句里选一句插入正文, 帮忙打开话头。
// - photo 参考图: 从相册选一张照片钉在写作区上方, 作为回忆场景的视觉参考
//         (信件数据模型是纯文本, 这张图只在本次编辑时可见, 不会随信寄出)。
// - mic   语音写信: 点一下开始录音, 用系统语音识别把说的话转成文字追加进正文,
//         再点一下停止。
// - AI    续写 / 润色: 复用已有的 `LetterAgentClient`, 让 AI 顺着写下去或帮忙
//         把已写的内容润色得更顺, 润色前会先给一个预览, 用户确认后才替换正文。
// - A     字号: 在小 / 中 / 大三档之间切换正文字号, 方便不同阅读习惯。
struct WriteLetterDefaultView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var letterText: String
    @FocusState private var isFocused: Bool

    @StateObject private var voice = VoiceDictationService()
    @State private var voiceBaseText = ""

    @State private var fontSize: CGFloat = 18

    @State private var referenceItem: PhotosPickerItem?
    @State private var referenceImage: UIImage?

    @State private var isAILoading = false
    @State private var aiErrorMessage: String?
    @State private var polishSuggestion: String?

    private let openingPrompts = [
        "最近让我印象最深的一件小事是……",
        "今天窗外的天气，让我想到了……",
        "如果你也在这里，我想告诉你……",
        "这段时间，我最想说的一句话是……",
        "有一种说不清的感觉，一直留在心里……",
        "写这封信之前，我想了很久要怎么开头……",
    ]

    init(letterText: Binding<String> = .constant("")) {
        self._letterText = letterText
    }

    var body: some View {
        ZStack {
            paperBackground

            VStack(spacing: 0) {
                header

                if let referenceImage {
                    referenceImageCard(referenceImage)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                }

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $letterText)
                        .font(AppFont.body(fontSize))
                        .foregroundStyle(Color.inkBrownDark)
                        .lineSpacing(8)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($isFocused)
                        .scrollDismissesKeyboard(.interactively)
                        .padding(.horizontal, 32)
                        .padding(.top, referenceImage == nil ? 70 : 16)

                    if letterText.isEmpty {
                        topHint
                            .padding(.horizontal, 32)
                            .padding(.top, referenceImage == nil ? 86 : 32)
                            .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let aiErrorMessage {
                    Text(aiErrorMessage)
                        .font(AppFont.body(12))
                        .foregroundStyle(Color(hex: 0xB4432D))
                        .padding(.horizontal, 32)
                        .padding(.bottom, 6)
                }

                if let message = voice.errorMessage {
                    Text(message)
                        .font(AppFont.body(12))
                        .foregroundStyle(Color(hex: 0xB4432D))
                        .padding(.horizontal, 32)
                        .padding(.bottom, 6)
                }

                bottomToolbar
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
            }
            .responsiveFill()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") { isFocused = false }
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.inkBrownDark)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isFocused = true
            }
            voice.onTranscript = { transcript in
                letterText = voiceBaseText + transcript
            }
        }
        .onDisappear { voice.stop() }
        .onChange(of: referenceItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    referenceImage = image
                }
            }
        }
        .sheet(isPresented: Binding(get: { polishSuggestion != nil }, set: { if !$0 { polishSuggestion = nil } })) {
            polishPreviewSheet
        }
    }

    private var paperBackground: some View {
        ZStack {
            Color.paperWarm

            // Subtle paper texture via blur
            Canvas { ctx, size in
                for _ in 0..<200 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let r = CGFloat.random(in: 0.5...1.5)
                    let path = Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r))
                    ctx.fill(path, with: .color(Color.brandMutedGold.opacity(0.15)))
                }
            }
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            AppBackButton(tint: .black) { dismiss() }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var topHint: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("｜见字如面...分享一件开心或不开心的事情吧😄")
                .font(AppFont.body(18))
                .foregroundStyle(Color(hex: 0xAC7F5E, alpha: 0.61))
                .lineSpacing(4)
            Spacer()
        }
    }

    private var bottomToolbar: some View {
        HStack {
            HStack(spacing: 20) {
                promptMenu
                photoPickerButton
                micButton
                aiMenu
                fontSizeMenu
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(hex: 0xAC7F5E, alpha: 0.5), in: Capsule())

            Spacer()

            Button {
                Haptic.medium()
                voice.stop()
                isFocused = false
                dismiss()
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(hex: 0xAC7F5E, alpha: 0.5), in: Circle())
            }
        }
    }

    // MARK: - "+" 灵感开头

    private var promptMenu: some View {
        Menu {
            ForEach(openingPrompts, id: \.self) { prompt in
                Button(prompt) {
                    Haptic.light()
                    insertAsNewLine(prompt)
                }
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 14))
                .foregroundStyle(.white)
        }
    }

    // MARK: - 参考图

    private var photoPickerButton: some View {
        PhotosPicker(selection: $referenceItem, matching: .images) {
            Image(systemName: "photo")
                .font(.system(size: 14))
                .foregroundStyle(.white)
        }
    }

    private func referenceImageCard(_ image: UIImage) -> some View {
        HStack(spacing: 10) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text("仅作写作参考, 不会随信寄出")
                .font(AppFont.body(11))
                .foregroundStyle(Color.inkBrownDark.opacity(0.6))

            Spacer()

            Button {
                Haptic.light()
                referenceItem = nil
                referenceImage = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.inkBrownDark.opacity(0.4))
            }
        }
        .padding(8)
        .background(Color(hex: 0xAC7F5E, alpha: 0.12), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - 语音写信

    private var micButton: some View {
        Button {
            Haptic.medium()
            if voice.isRecording {
                voice.stop()
            } else {
                voiceBaseText = letterText
                voice.start()
            }
        } label: {
            Image(systemName: voice.isRecording ? "mic.fill" : "mic")
                .font(.system(size: 14))
                .foregroundStyle(voice.isRecording ? Color(hex: 0xE0503C) : .white)
                .scaleEffect(voice.isRecording ? 1.15 : 1.0)
                .animation(
                    voice.isRecording
                        ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                        : .default,
                    value: voice.isRecording
                )
        }
    }

    // MARK: - AI 续写 / 润色

    private var aiMenu: some View {
        Menu {
            Button {
                Haptic.light()
                requestAIAssist(.continueWriting)
            } label: {
                Label("帮我续写", systemImage: "text.append")
            }
            Button {
                Haptic.light()
                requestAIAssist(.polish)
            } label: {
                Label("帮我润色", systemImage: "sparkles")
            }
        } label: {
            if isAILoading {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(0.7)
            } else {
                Text("AI")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .disabled(isAILoading)
    }

    private func requestAIAssist(_ action: LetterAgentClient.Action) {
        aiErrorMessage = nil
        isAILoading = true
        Task {
            do {
                let suggestion = try await LetterAgentClient.shared.assist(action: action, draft: letterText)
                isAILoading = false
                switch action {
                case .continueWriting:
                    appendContinuation(suggestion)
                case .polish:
                    polishSuggestion = suggestion
                }
            } catch {
                isAILoading = false
                aiErrorMessage = "AI 助手暂时没有回应, 请稍后再试"
            }
        }
    }

    private var polishPreviewSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("润色后的内容")
                .font(AppFont.title(16))
                .foregroundStyle(Color.textPrimary)

            ScrollView {
                Text(polishSuggestion ?? "")
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.inkBrownDark)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                SecondaryButton(title: "取消") { polishSuggestion = nil }
                PrimaryButton(title: "替换正文", color: Color(hex: 0x926247)) {
                    if let polishSuggestion {
                        letterText = polishSuggestion
                    }
                    self.polishSuggestion = nil
                }
            }
        }
        .padding(24)
        .presentationDetents([.medium])
    }

    // MARK: - 字号

    private var fontSizeMenu: some View {
        Menu {
            fontSizeOption("小", 16)
            fontSizeOption("中", 18)
            fontSizeOption("大", 22)
        } label: {
            Text("A")
                .font(AppFont.title(16))
                .foregroundStyle(.white)
        }
    }

    private func fontSizeOption(_ label: String, _ size: CGFloat) -> some View {
        Button {
            Haptic.light()
            fontSize = size
        } label: {
            if fontSize == size {
                Label(label, systemImage: "checkmark")
            } else {
                Text(label)
            }
        }
    }

    // MARK: - 文本插入辅助

    private func insertAsNewLine(_ text: String) {
        if letterText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            letterText = text
        } else {
            letterText += letterText.hasSuffix("\n") ? text : "\n" + text
        }
    }

    private func appendContinuation(_ suggestion: String) {
        let trimmed = suggestion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        letterText += trimmed
    }
}
