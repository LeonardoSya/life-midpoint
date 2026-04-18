import SwiftUI

struct DiarySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let summaryText: String

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                ScrollView(showsIndicators: false) {
                    summaryCard
                        .padding(.horizontal, 47)
                        .padding(.top, 65)
                }

                completeButton
                    .padding(.bottom, 44)
            }
            .responsiveFill()
        }
        .ignoresSafeArea()
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
            Text(summaryText)
                .font(AppFont.body(15))
                .foregroundStyle(.black)
                .lineSpacing(5)

            Text("*内容由Ai自动整合生成，点击可自由修改。")
                .font(.system(size: 10))
                .foregroundStyle(Color.emotionPink)
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
            dismiss()
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
