import SwiftUI
import SwiftData

struct WriteLetterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    /// 若从某个笔友的详情页/日历跳转而来, 这里会固定收信人, 寄出时自动关联该笔友.
    let presetPenPal: PenPal?
    @State private var letterContent = ""
    @State private var alias: String = ""
    @State private var selectedMood: String?
    @State private var selectedFeeling: String?
    @State private var selectedWeather: String?
    @State private var selectedLetterType: String?
    @State private var recipientMode: String   // "stranger" / "self" / "penPal"
    @State private var showFullWriter = false
    @State private var showSentConfirmation = false
    @State private var path = NavigationPath()
    @State private var selectedStamp: StampInfo = StampLibrary.goldStamps[1]

    init(presetPenPal: PenPal? = nil) {
        self.presetPenPal = presetPenPal
        _recipientMode = State(initialValue: presetPenPal != nil ? "penPal" : "stranger")
    }

    private var repo: PostOfficeRepository { PostOfficeRepository(context: modelContext) }

    private let moods = ["自由填写 →", "忙里偷闲", "旅行途中", "“虚度”光阴", "等待某人", "深夜独处"]
    private let feelings = ["自由填写 →", "心情平静", "有些疲惫", "知足常乐", "莫名惆怅", "充满期待"]
    private let weathers = ["自由填写 →", "阳光灿烂", "阴雨绵绵", "晚风微凉", "闷热难耐", "云朵很美"]
    private let letterTypes = ["自由填写 →", "碎碎念", "心事清单", "今天的见闻", "远方的问候", "小小的秘密"]

    var body: some View {
        NavigationStack(path: $path) {
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
            .fullScreenCover(isPresented: $showFullWriter) {
                WriteLetterDefaultView(letterText: $letterContent)
            }
            .fullScreenCover(isPresented: $showSentConfirmation) {
                LetterSentView(stampImageName: selectedStamp.imageName) {
                    dismiss()
                }
            }
            .navigationDestination(for: WriteLetterRoute.self) { route in
                switch route {
                case .stampSelection:
                    StampSelectionView(selectedStamp: selectedStamp) { stamp in
                        selectedStamp = stamp
                        path.append(WriteLetterRoute.preview(stamp.id))
                    }
                case .preview:
                    LetterPreviewView(
                        content: letterContent,
                        alias: alias.isEmpty ? "屋檐与猫" : alias,
                        recipientMode: recipientMode,
                        recipientName: presetPenPal?.name,
                        mood: selectedMood,
                        feeling: selectedFeeling,
                        weather: selectedWeather,
                        letterType: selectedLetterType,
                        stamp: selectedStamp
                    ) {
                        sendLetter()
                    } onEdit: {
                        path.removeLast(path.count)
                    }
                }
            }
        }
    }

    // MARK: - Envelope Preview (含正文输入)

    private var envelopePreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            toggleCallout
            envelopeBody
        }
    }

    @ViewBuilder
    private var toggleCallout: some View {
        if let presetPenPal {
            HStack(spacing: 6) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 11))
                Text("正在寄给笔友 \u{201C}\(presetPenPal.name)\u{201D}")
                    .font(AppFont.body(10))
            }
            .foregroundStyle(Color(hex: 0xAD681A, alpha: 0.7))
            .padding(.leading, 12)
        } else {
            Button {
                Haptic.selection()
                recipientMode = recipientMode == "stranger" ? "self" : "stranger"
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 11))
                    Text(recipientMode == "stranger" ? "切换为\u{201C}写给自己\u{201D}" : "切换为\u{201C}寄给陌生人\u{201D}")
                        .font(AppFont.body(10))
                }
                .foregroundStyle(Color(hex: 0xAD681A, alpha: 0.7))
            }
            .padding(.leading, 12)
        }
    }

    private var envelopeBody: some View {
        ZStack(alignment: .topLeading) {
            // 后层信封 (淡黄, 顶部探出营造叠放层次)
            RoundedRectangle(cornerRadius: 9)
                .fill(Color(hex: 0xE4D0A0).opacity(0.4))
                .frame(height: 188)
                .padding(.horizontal, 12)
                .offset(y: -12)

            // 前层信封
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 4) {
                        ForEach(0..<6, id: \.self) { _ in
                            Rectangle()
                                .stroke(Color(hex: 0xAD681A, alpha: 0.6), lineWidth: 1)
                                .frame(width: 16, height: 19)
                        }
                    }

                    Text(envelopeHeaderText)
                        .font(AppFont.body(10))
                        .foregroundStyle(Color.textPrimary)
                        .padding(.top, 18)

                    Text(letterPreviewText)
                        .font(AppFont.body(13))
                        .foregroundStyle(
                            letterContent.isEmpty
                            ? Color.textSecondary.opacity(0.55)
                            : Color.textPrimary.opacity(0.78)
                        )
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.top, 12)
                }

                Rectangle()
                    .stroke(Color(hex: 0xAD681A, alpha: 0.6), lineWidth: 1)
                    .frame(width: 55, height: 71)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
            .background(Color(hex: 0xEDE1C9), in: RoundedRectangle(cornerRadius: 6))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            Haptic.light()
            showFullWriter = true
        }
    }

    private var envelopeHeaderText: String {
        switch recipientMode {
        case "self": return "写给 自己..."
        case "penPal": return "寄给 \(presetPenPal?.name ?? "笔友")..."
        default: return "寄给 陌生的人..."
        }
    }

    private var letterPreviewText: String {
        let trimmed = letterContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "点击信封，进入全屏书写..." }
        return trimmed.count > 80 ? String(trimmed.prefix(80)) + "..." : trimmed
    }

    // MARK: - Alias

    private var aliasField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("你的化名是...")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)

            TextField("自由填写  →", text: $alias)
                .font(AppFont.body(16))
                .foregroundStyle(Color(hex: 0x57534E))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .frame(height: 48)
                .overlay(
                    Capsule().stroke(Color(hex: 0xD6D3D1), lineWidth: 1)
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
                .font(AppFont.body(16))
                .foregroundStyle(isSelected ? Color(hex: 0x9BB167) : Color(hex: 0x57534E))
                .padding(.horizontal, 20)
                .frame(height: 48)
                .background(
                    Capsule().fill(isSelected ? Color(hex: 0xF5F7EE) : Color.clear)
                )
                .overlay(
                    Capsule().stroke(isSelected ? Color(hex: 0x9BB167) : Color(hex: 0xD6D3D1), lineWidth: 1)
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
            Haptic.medium()
            path.append(WriteLetterRoute.stampSelection)
        } label: {
            Text("完成撰写")
                .font(AppFont.body(16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(canSend ? Color(hex: 0x926247) : Color(hex: 0x926247).opacity(0.4), in: Capsule())
        }
        .disabled(!canSend)
    }

    private func sendLetter() {
        repo.send(
            body: letterContent,
            recipientMode: recipientMode,
            moodTag: selectedMood,
            feelingTag: selectedFeeling,
            weatherTag: selectedWeather,
            letterTypeTag: selectedLetterType,
            alias: alias.isEmpty ? nil : alias,
            penPal: presetPenPal,
            awardStampDefinitionId: selectedStamp.id
        )
        Haptic.success()
        showSentConfirmation = true
    }
}

private enum WriteLetterRoute: Hashable {
    case stampSelection
    case preview(String)
}
