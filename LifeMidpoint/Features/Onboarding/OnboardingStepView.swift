import SwiftUI

struct OnboardingStepView: View {
    let step: OnboardingStep
    let onNext: () -> Void
    let onComplete: () -> Void

    @State private var userInput = ""
    @State private var visibleDialogues: [String] = []
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            backgroundImage

            VStack(spacing: 0) {
                Spacer()

                if !visibleDialogues.isEmpty {
                    dialogueBubbles
                        .padding(.horizontal, 34)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                if step.hasUserInput {
                    userInputField
                        .padding(.horizontal, 34)
                        .padding(.top, AppSpacing.lg)
                }

                Spacer()

                if let ctaText = step.ctaText {
                    ctaButton(ctaText)
                        .padding(.bottom, 87)
                }
            }
            .responsiveFill()
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            if step.ctaText == nil && !step.hasUserInput {
                onNext()
            }
        }
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

    private var dialogueBubbles: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(Array(visibleDialogues.enumerated()), id: \.offset) { _, text in
                dialogueBubble(text)
            }
        }
    }

    private func dialogueBubble(_ text: String) -> some View {
        Text(text)
            .font(AppFont.body(18))
            .foregroundStyle(Color.dialogueGray)
            .lineSpacing(4)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.75))
            )
    }

    private var userInputField: some View {
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

    private func ctaButton(_ text: String) -> some View {
        Button(action: onComplete) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.8), in: Circle())

                Text(text)
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.textPrimary)
                    .tracking(5.2)
            }
            .padding(7)
            .frame(width: 280)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
        }
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
