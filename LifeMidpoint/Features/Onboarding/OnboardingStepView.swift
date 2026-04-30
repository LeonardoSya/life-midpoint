import SwiftUI

struct OnboardingStepView: View {
    let step: OnboardingStep
    let onNext: () -> Void
    let onComplete: () -> Void

    @EnvironmentObject private var appState: AppStateManager

    @State private var userInput = ""
    @State private var nameInput: String = {
        #if DEBUG
        return ProcessInfo.processInfo.environment["DEBUG_PROFILE_NAME"] ?? ""
        #else
        return ""
        #endif
    }()
    @State private var birthdayInput: Date = Calendar.current.date(byAdding: .year, value: -28, to: .now) ?? .now
    @State private var birthdayPicked: Bool = {
        #if DEBUG
        return ProcessInfo.processInfo.environment["DEBUG_PROFILE_NAME"] != nil
        #else
        return false
        #endif
    }()
    @State private var showBirthdaySheet = false
    @State private var visibleDialogues: [String] = []
    @FocusState private var isInputFocused: Bool
    @FocusState private var isNameFocused: Bool

    private static let birthdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy 年 M 月 d 日"
        return f
    }()

    /// Figma 画布为 440pt 宽, 对话气泡宽 373pt, 左右约 33pt 留白。
    /// 这里用当前屏幕宽度减 74pt 做硬约束, 避免全屏背景图/ignoresSafeArea
    /// 让 `.infinity` 气泡在某些设备上横向溢出。
    private var dialogueGroupWidth: CGFloat {
        max(260, UIScreen.main.bounds.width - 74)
    }

    var body: some View {
        ZStack {
            backgroundImage

            // 单一 VStack 完成顶/底气泡布局, 避免嵌套 ZStack child 抢手势.
            // - 顶部气泡 (.mixed layout 时显示) 紧贴 status bar 下方
            // - Spacer 把上下分隔
            // - 底部气泡 + 输入卡 / CTA 整体距底 110pt
            VStack(spacing: 0) {
                if !topBubbles.isEmpty {
                    dialogueGroup(texts: topBubbles)
                        .padding(.horizontal, 30)
                        .padding(.top, 110)
                        .transition(.opacity)
                }

                Spacer(minLength: 0)

                if !bottomBubbles.isEmpty {
                    dialogueGroup(texts: bottomBubbles)
                        .padding(.horizontal, 30)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                if let kind = step.inputKind {
                    inputField(for: kind)
                        .padding(.horizontal, 30)
                        .padding(.top, AppSpacing.lg)
                }

                if let ctaText = step.ctaText {
                    ctaButton(ctaText)
                        .padding(.top, 28)
                }
            }
            .padding(.bottom, 110)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // 关键: VStack 内只有 Spacer / Text / Image, 默认不响应 tap.
            // 不加 contentShape, 避免吞掉外层 tap.
        }
        .ignoresSafeArea()
        .ignoresSafeArea(.keyboard)
        // 仅在"无 CTA + 无输入"step 启用整页 tap 推进.
        // step 14 (CTA) / step 10 (profile 输入) 不挂 tap gesture,
        // 避免抢走 SlideToConfirmButton 的 DragGesture 与 TextField focus.
        .applyTapToAdvance(enabled: step.ctaText == nil && !step.hasUserInput, action: onNext)
        .onAppear {
            animateDialogues()
        }
    }

    private var backgroundImage: some View {
        Image(step.imageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .ignoresSafeArea()
    }

    // MARK: - 气泡分组 (顶/底)

    /// 当前要展示在屏幕顶部的气泡 (仅 .mixed layout 时有值).
    private var topBubbles: [String] {
        switch step.bubbleLayout {
        case .bottom: return []
        case .mixed(let topCount):
            return Array(visibleDialogues.prefix(topCount))
        }
    }

    /// 当前要展示在屏幕底部的气泡.
    private var bottomBubbles: [String] {
        switch step.bubbleLayout {
        case .bottom: return visibleDialogues
        case .mixed(let topCount):
            guard visibleDialogues.count > topCount else { return [] }
            return Array(visibleDialogues.dropFirst(topCount))
        }
    }

    private func dialogueGroup(texts: [String]) -> some View {
        VStack(spacing: 13) {           // figma: 两气泡间距 ~13pt
            ForEach(Array(texts.enumerated()), id: \.offset) { _, text in
                dialogueBubble(rendered(text))
            }
        }
        .frame(width: dialogueGroupWidth)
    }

    /// 将对话文案中的 "xx" 占位符替换成 step10 用户填写的姓名.
    /// 未填写时 displayName fallback 为 "你", 保持语义流畅.
    private func rendered(_ text: String) -> String {
        text.replacingOccurrences(of: "xx", with: appState.displayName)
    }

    /// 单个气泡: 严格对应 Figma 设计稿
    /// - 背景: bubbleBackground (#FFFEFB 奶白) 不透明
    /// - 圆角: 11pt
    /// - 文字: 18pt body, 左对齐
    /// - 普通文字: bubbleText (#5C605F 深灰绿)
    /// - 旁白文字 (* 开头): bubbleAccent (#FE8785 粉红)
    /// - 内 padding: 上下 13pt, 左右 22pt
    private func dialogueBubble(_ text: String) -> some View {
        let isAside = text.trimmingCharacters(in: .whitespaces).hasPrefix("*")
        return Text(text)
            .font(AppFont.body(18))
            .foregroundStyle(isAside ? Color.bubbleAccent : Color.bubbleText)
            .lineSpacing(2)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 22)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 11)
                    .fill(Color.bubbleBackground)
            )
    }

    @ViewBuilder
    private func inputField(for kind: OnboardingInputKind) -> some View {
        switch kind {
        case .text:    textInputField
        case .profile: profileInputField
        }
    }

    private var textInputField: some View {
        HStack {
            TextField("写下你想说的话...", text: $userInput, axis: .vertical)
                .font(AppFont.body(16))
                .lineLimit(3...6)
                .focused($isInputFocused)

            if !userInput.isEmpty {
                Button {
                    isInputFocused = false
                    onNext()
                } label: {
                    Text("确认")
                        .font(AppFont.body(14))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray60, in: Capsule())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isInputFocused = true
            }
        }
    }

    /// Step 10 老照片场景: 姓名 + 出生日期 + 确认.
    /// 用户提交后写入 AppStateManager + SwiftData UserProfile, 后续 step 用 displayName 替换 "xx".
    /// 重启 app 后此处会自动用持久化的姓名/生日预填, 用户不必再次输入.
    private var profileInputField: some View {
        VStack(spacing: 12) {
            profileRow(label: "姓名") {
                TextField("", text: $nameInput, prompt: Text("请输入").foregroundColor(.grayPlaceholder))
                    .font(AppFont.body(16))
                    .foregroundStyle(Color.dialogueGray)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            profileRow(label: "出生日期") {
                Button {
                    isNameFocused = false
                    showBirthdaySheet = true
                } label: {
                    HStack {
                        Text(birthdayPicked
                             ? Self.birthdayFormatter.string(from: birthdayInput)
                             : "请选择")
                            .font(AppFont.body(16))
                            .foregroundStyle(birthdayPicked ? Color.dialogueGray : Color.grayPlaceholder)
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            confirmButton
                .padding(.top, 4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.85))
        )
        .onAppear {
            // 用持久化的档案预填 (重启 app 后自动恢复, 无需用户再次输入)
            if nameInput.isEmpty, !appState.userName.isEmpty {
                nameInput = appState.userName
            }
            if !birthdayPicked, let saved = appState.userBirthday {
                birthdayInput = saved
                birthdayPicked = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
        .sheet(isPresented: $showBirthdaySheet) {
            birthdaySheet
                .presentationDetents([.height(360)])
                .presentationDragIndicator(.visible)
        }
    }

    private var birthdaySheet: some View {
        VStack(spacing: 16) {
            Text("出生日期")
                .font(AppFont.title(20))
                .foregroundStyle(Color.dialogueGray)
                .padding(.top, 24)

            DatePicker(
                "",
                selection: $birthdayInput,
                in: ...Date(),
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.wheel)
            .environment(\.locale, Locale(identifier: "zh_CN"))

            Button {
                birthdayPicked = true
                showBirthdaySheet = false
                Haptic.selection()
            } label: {
                Text("完成")
                    .font(AppFont.body(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.gray60))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private func profileRow<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(AppFont.body(15))
                .foregroundStyle(Color.dialogueGray)
                .frame(width: 64, alignment: .leading)

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.55))
        )
    }

    private var canSubmitProfile: Bool {
        !nameInput.trimmingCharacters(in: .whitespaces).isEmpty && birthdayPicked
    }

    private var confirmButton: some View {
        Button {
            guard canSubmitProfile else { return }
            isNameFocused = false
            // 同时写入内存 + SwiftData (UserProfile 持久化, 跨启动保留)
            appState.saveProfile(name: nameInput, birthday: birthdayInput)
            Haptic.medium()
            onNext()
        } label: {
            Text("确认")
                .font(AppFont.body(15))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(canSubmitProfile ? Color.gray60 : Color.gray60.opacity(0.45))
                )
        }
        .disabled(!canSubmitProfile)
        .animation(.easeInOut(duration: 0.2), value: canSubmitProfile)
    }

    private func ctaButton(_ text: String) -> some View {
        SlideToConfirmButton(text: text, onComplete: onComplete)
    }

    private func animateDialogues() {
        visibleDialogues = []
        for (index, dialogue) in step.dialogues.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.2) {
                withAnimation(.easeOut(duration: 0.4)) {
                    visibleDialogues.append(dialogue)
                }
            }
        }
    }
}

// MARK: - Tap-to-advance helper

private extension View {
    /// 仅在 `enabled` 为 true 时附加 onTapGesture; 否则原样返回, 不挂任何 gesture.
    /// 使用 `@ViewBuilder` 让 SwiftUI 把两个分支视为独立 view 类型,
    /// 避免在 enabled 切换时混入空 gesture 影响 child 手势识别.
    @ViewBuilder
    func applyTapToAdvance(enabled: Bool, action: @escaping () -> Void) -> some View {
        if enabled {
            self
                .contentShape(Rectangle())
                .onTapGesture(perform: action)
        } else {
            self
        }
    }
}
