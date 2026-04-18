import SwiftUI

struct Emotion: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

private let emotions: [Emotion] = [
    Emotion(name: "平静", icon: "leaf.fill"),
    Emotion(name: "愉悦", icon: "face.smiling"),
    Emotion(name: "低落", icon: "cloud.fill"),
    Emotion(name: "烦躁", icon: "bolt.fill"),
    Emotion(name: "焦虑", icon: "exclamationmark.circle.fill"),
    Emotion(name: "疲惫", icon: "battery.25percent"),
    Emotion(name: "悲伤", icon: "drop.fill"),
    Emotion(name: "易怒", icon: "flame.fill"),
    Emotion(name: "麻木", icon: "snowflake"),
]

struct EmotionPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEmotion: Emotion?
    @State private var intensity: Double = 0.3

    private let intensityLabels = ["有一点", "比较明显", "中等程度", "相当明显", "很强烈"]

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            Text("现在的你，\n更接近哪种状态？")
                .font(AppFont.title(22))
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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
            ForEach(emotions) { emotion in
                emotionCell(emotion)
            }
        }
    }

    private func emotionCell(_ emotion: Emotion) -> some View {
        Button {
            selectedEmotion = emotion
        } label: {
            VStack(spacing: 6) {
                Image(systemName: emotion.icon)
                    .font(.system(size: 22))
                Text(emotion.name)
                    .font(AppFont.body(13))
            }
            .foregroundStyle(selectedEmotion?.name == emotion.name ? Color.mindPrimary : Color.textSecondary)
            .frame(width: 90, height: 72)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedEmotion?.name == emotion.name ? Color.mindLight : Color.chipBackgroundAlt)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedEmotion?.name == emotion.name ? Color.mindPrimary.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
    }

    // MARK: - Custom Emotion

    private var customButton: some View {
        Button {
            // TODO: custom emotion
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                Text("自定义")
            }
            .font(AppFont.body(14))
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.pastelLightBlue, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Intensity Slider

    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("强烈程度")
                .font(AppFont.body(15))
                .foregroundStyle(Color.textPrimary)

            Slider(value: $intensity, in: 0...1, step: 0.25)
                .tint(Color.mindPrimary)

            HStack {
                ForEach(intensityLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Actions

    private var confirmButton: some View {
        Button {
            dismiss()
        } label: {
            Text("确认记录")
                .font(AppFont.title(16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.mindPrimary, in: RoundedRectangle(cornerRadius: 25))
        }
    }

    private var skipButton: some View {
        Button {
            dismiss()
        } label: {
            Text("跳过")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary)
                .underline()
        }
    }
}
