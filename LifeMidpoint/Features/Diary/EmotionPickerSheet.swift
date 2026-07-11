import SwiftUI

/// "情绪识别弹窗1": 选择当前心理状态 + 强烈程度.
/// 数据来自 `EmotionLibrary.all` (与"弹窗2"详情页共用同一份图标/情绪定义).
struct EmotionPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    /// 点击"确认记录"的回调, 携带所选情绪名、图标与强烈程度(0...1).
    /// 为 nil 时(独立预览)沿用 `dismiss()`.
    var onConfirm: ((_ name: String, _ icon: String, _ intensity: Double) -> Void)?
    /// 点击"跳过"的回调. 为 nil 时沿用 `dismiss()`.
    var onSkip: (() -> Void)?

    /// 默认选中首项(平静), 与设计稿一致.
    @State private var selectedName: String? = EmotionLibrary.all.first?.name
    @State private var intensity: Double = 0.3
    /// 自定义情绪文案; 非空时优先于宫格选中项.
    @State private var customText = ""
    @FocusState private var customFieldFocused: Bool

    private let intensityLabels = ["有一点", "比较明显", "中等程度", "相当明显", "很强烈"]

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            Text("现在的你，\n更接近哪种状态？")
                .font(AppFont.title(24))
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textPrimary)

            emotionGrid

            customButton

            Divider().padding(.horizontal, 24)

            intensitySection

            confirmButton

            skipButton

            Spacer().frame(height: 20)
        }
        .padding(.horizontal, 24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Emotion Grid (3x3)

    private var emotionGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(EmotionLibrary.all) { emotion in
                emotionCell(emotion)
            }
        }
    }

    private func emotionCell(_ emotion: EmotionContent) -> some View {
        let isSelected = selectedName == emotion.name && customText.isEmpty
        return Button {
            selectedName = emotion.name
            customText = ""
            customFieldFocused = false
        } label: {
            VStack(spacing: 8) {
                Image(systemName: emotion.icon)
                    .font(.system(size: 20))
                Text(emotion.name)
                    .font(AppFont.body(12))
            }
            .foregroundStyle(isSelected ? Color(hex: 0x465736) : Color.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.mintGreenLight.opacity(0.5) : Color.postCardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.mintGreenLight.opacity(0.5) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Custom Emotion

    private var isCustomActive: Bool { customFieldFocused || !customText.isEmpty }

    private var customButton: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus.circle")
            TextField("自定义", text: $customText)
                .focused($customFieldFocused)
                .submitLabel(.done)
                .onSubmit { customFieldFocused = false }
                .onChange(of: customText) { _, newValue in
                    if !newValue.isEmpty { selectedName = nil }
                }
        }
        .font(AppFont.body(14))
        .foregroundStyle(Color(hex: 0x43555A))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 17)
        .padding(.horizontal, 16)
        .background(Color.warmGradientBottom.opacity(0.3), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isCustomActive ? Color.mindPrimary.opacity(0.6) : Color.textPlaceholder.opacity(0.4),
                    style: isCustomActive ? StrokeStyle(lineWidth: 1.4) : StrokeStyle(lineWidth: 1, dash: [5])
                )
        )
        .contentShape(Rectangle())
        .onTapGesture { customFieldFocused = true }
    }

    // MARK: - Intensity Slider

    private var selectedIntensityIndex: Int {
        min(intensityLabels.count - 1, max(0, Int((intensity * 4).rounded())))
    }

    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("强烈程度")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary)

            Slider(value: $intensity, in: 0...1, step: 0.25)
                .tint(Color.mindPrimary)

            HStack {
                ForEach(Array(intensityLabels.enumerated()), id: \.element) { index, label in
                    Text(label)
                        .font(AppFont.body(10))
                        .foregroundStyle(index == selectedIntensityIndex ? Color.textPrimary : Color.textSecondary.opacity(0.8))
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Actions

    /// 自定义文案非空时优先生效, 否则回退到宫格选中项.
    private var effectiveEmotionName: String {
        let trimmedCustom = customText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedCustom.isEmpty { return trimmedCustom }
        return selectedName ?? EmotionLibrary.all.first?.name ?? ""
    }

    private var confirmButton: some View {
        Button {
            customFieldFocused = false
            let content = EmotionLibrary.content(for: effectiveEmotionName)
            if let onConfirm {
                onConfirm(content.name, content.icon, intensity)
            } else {
                dismiss()
            }
        } label: {
            Text("确认记录")
                .font(AppFont.body(16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.mindPrimary.opacity(0.6), in: Capsule())
                .shadow(color: Color.mindPrimary.opacity(0.2), radius: 12, y: 8)
        }
    }

    private var skipButton: some View {
        Button {
            customFieldFocused = false
            if let onSkip { onSkip() } else { dismiss() }
        } label: {
            Text("跳过")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary)
                .underline()
        }
    }
}
