import SwiftUI

struct DiarySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let summaryText: String
    var onComplete: ((String) -> Void)?

    @State private var editedText: String
    @FocusState private var isEditing: Bool

    init(summaryText: String, onComplete: ((String) -> Void)? = nil) {
        self.summaryText = summaryText
        self.onComplete = onComplete
        _editedText = State(initialValue: summaryText)
    }

    var body: some View {
        ZStack {
            background
                .contentShape(Rectangle())
                .onTapGesture { isEditing = false }

            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                ScrollView(showsIndicators: false) {
                    summaryCard
                        .padding(.horizontal, 47)
                        .padding(.top, 65)
                }
                .scrollDismissesKeyboard(.interactively)

                completeButton
                    .padding(.bottom, 44)
            }
            .responsiveFill()
        }
        .ignoresSafeArea()
        .overlay(alignment: .topLeading) { backButton }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") { isEditing = false }
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.emotionPink)
            }
        }
    }

    private var backButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "arrow.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .frame(width: 38, height: 38)
        }
        .buttonStyle(.plain)
        .padding(.leading, 18)
        .padding(.top, 16)
    }

    private var background: some View {
        ZStack {
            Color.pageBackground
            Image("DiaryBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.5)
        }
        .ignoresSafeArea()
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("", text: $editedText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(AppFont.body(15))
                .foregroundStyle(.black)
                .lineSpacing(5)
                .tint(Color.emotionPink)
                .focused($isEditing)

            Text("*内容由Ai自动整合生成，点击可自由修改。")
                .font(AppFont.body(10))
                .foregroundStyle(Color.emotionPink)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 16)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.7))
        )
    }

    private var completeButton: some View {
        Button {
            isEditing = false
            PostOfficeRepository(context: modelContext).grantStamp(definitionId: "gold_2", source: "diary_summary")
            if let onComplete {
                onComplete(editedText)
            } else {
                dismiss()
            }
        } label: {
            Text("完成记录")
                .font(AppFont.body(14))
                .foregroundStyle(Color.dustyPurple)
                .padding(.horizontal, 49)
                .padding(.vertical, 13)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.7))
                        .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                )
        }
    }
}
