import SwiftUI

struct WriteLetterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var letterContent = ""
    @State private var selectedMood: String?
    @State private var selectedWeather: String?
    @State private var selectedLetterType: String?

    private let moods = ["自由填写 →", "忙里偷闲", "旅行途中", "\u{201C}虚\u{201D}"]
    private let feelings = ["自由填写 →", "心情平静", "有些疲惫", "知足"]
    private let weathers = ["自由填写 →", "阳光灿烂", "阴雨绵绵", "晚风"]
    private let letterTypes = ["自由填写 →", "碎碎念", "心事清单", "今天的"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    envelopePreview
                        .padding(.top, 24)

                    chipSection(title: "你的化名是...", items: ["自由填写 →"])
                        .padding(.top, 32)

                    chipSection(title: "此刻你正在...", items: moods)
                        .padding(.top, 20)

                    chipSection(title: "此刻你感觉...", items: feelings)
                        .padding(.top, 20)

                    chipSection(title: "今天的天气是...", items: weathers)
                        .padding(.top, 20)

                    chipSection(title: "这封信是一份...", items: letterTypes)
                        .padding(.top, 20)

                    completeButton
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
            .background(Color.pageBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(Color.textPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Envelope Preview

    private var envelopePreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("切换为\u{201C}写给自己\u{201D}")
                    .font(AppFont.body(11))
                    .foregroundStyle(Color.textSecondary)
                Spacer()
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.paperWarm)
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: 8) {
                    Text("寄给 陌生的人...")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(20)
            }
        }
    }

    // MARK: - Chip Section

    private func chipSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        chipButton(item)
                    }
                }
            }
        }
    }

    private func chipButton(_ text: String) -> some View {
        Button {
            // TODO: select chip
        } label: {
            Text(text)
                .font(AppFont.body(13))
                .foregroundStyle(Color.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .stroke(Color.borderLight, lineWidth: 1)
                )
        }
    }

    // MARK: - Complete Button

    private var completeButton: some View {
        Button {
            dismiss()
        } label: {
            Text("完成撰写")
                .font(AppFont.title(16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.inkBrownDeep, in: RoundedRectangle(cornerRadius: 25))
        }
    }
}
