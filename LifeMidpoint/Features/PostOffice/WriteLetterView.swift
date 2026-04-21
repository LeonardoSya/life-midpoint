import SwiftUI
import SwiftData

struct WriteLetterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var bodyFocused: Bool
    @State private var letterContent = ""
    @State private var alias: String = ""
    @State private var selectedMood: String?
    @State private var selectedFeeling: String?
    @State private var selectedWeather: String?
    @State private var selectedLetterType: String?
    @State private var recipientMode: String = "stranger"   // "stranger" / "self"

    private var repo: PostOfficeRepository { PostOfficeRepository(context: modelContext) }

    private let moods = ["忙里偷闲", "旅行途中", "\u{201C}虚\u{201D}"]
    private let feelings = ["心情平静", "有些疲惫", "知足"]
    private let weathers = ["阳光灿烂", "阴雨绵绵", "晚风"]
    private let letterTypes = ["碎碎念", "心事清单", "今天的"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    envelopePreview
                        .padding(.top, 24)

                    aliasField
                        .padding(.top, 32)

                    chipSection(title: "此刻你正在...", items: moods, selection: $selectedMood)
                        .padding(.top, 20)

                    chipSection(title: "此刻你感觉...", items: feelings, selection: $selectedFeeling)
                        .padding(.top, 20)

                    chipSection(title: "今天的天气是...", items: weathers, selection: $selectedWeather)
                        .padding(.top, 20)

                    chipSection(title: "这封信是一份...", items: letterTypes, selection: $selectedLetterType)
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

    // MARK: - Envelope Preview (含正文输入)

    private var envelopePreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                Haptic.selection()
                recipientMode = recipientMode == "stranger" ? "self" : "stranger"
            } label: {
                Text(recipientMode == "stranger" ? "切换为\u{201C}写给自己\u{201D}" : "切换为\u{201C}寄给陌生人\u{201D}")
                    .font(AppFont.body(11))
                    .foregroundStyle(Color.textSecondary)
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.paperWarm)
                    .frame(minHeight: 180)

                VStack(alignment: .leading, spacing: 8) {
                    Text(recipientMode == "stranger" ? "寄给 陌生的人..." : "写给 自己...")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary)

                    TextEditor(text: $letterContent)
                        .font(AppFont.body(13))
                        .foregroundStyle(Color.textPrimary)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 110)
                        .focused($bodyFocused)
                        .overlay(alignment: .topLeading) {
                            if letterContent.isEmpty {
                                Text("写下今天想说的话...")
                                    .font(AppFont.body(13))
                                    .foregroundStyle(Color.textSecondary.opacity(0.55))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }
                .padding(20)
            }
        }
    }

    // MARK: - Alias

    private var aliasField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("你的化名是...")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)

            TextField("自由填写", text: $alias)
                .font(AppFont.body(13))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .overlay(
                    Capsule().stroke(Color.borderLight, lineWidth: 1)
                )
        }
    }

    // MARK: - Chip Section

    private func chipSection(title: String, items: [String], selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        chipButton(item, isSelected: selection.wrappedValue == item) {
                            // 第二次点击同一项 = 取消选择
                            selection.wrappedValue = (selection.wrappedValue == item) ? nil : item
                        }
                    }
                }
            }
        }
    }

    private func chipButton(_ text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptic.light()
            action()
        } label: {
            Text(text)
                .font(AppFont.body(13))
                .foregroundStyle(isSelected ? .white : Color.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(isSelected ? Color.inkBrownDeep : Color.clear)
                )
                .overlay(
                    Capsule().stroke(Color.borderLight, lineWidth: isSelected ? 0 : 1)
                )
        }
    }

    // MARK: - Complete Button

    private var canSend: Bool {
        !letterContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var completeButton: some View {
        Button {
            guard canSend else { return }
            // 持久化信件 (status=sent), 同时奖励一枚邮票.
            // 邮票 id 简化用首条 gold 邮票, 真实业务可基于事件解锁不同邮票.
            repo.send(
                body: letterContent,
                recipientMode: recipientMode,
                moodTag: selectedMood,
                feelingTag: selectedFeeling,
                weatherTag: selectedWeather,
                letterTypeTag: selectedLetterType,
                alias: alias.isEmpty ? nil : alias,
                awardStampDefinitionId: "gold_1"
            )
            Haptic.medium()
            dismiss()
        } label: {
            Text("完成撰写")
                .font(AppFont.title(16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    canSend ? Color.inkBrownDeep : Color.inkBrownDeep.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 25)
                )
        }
        .disabled(!canSend)
    }
}
