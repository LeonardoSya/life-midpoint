import SwiftUI

/// 心境模块今日推荐 Hero 卡片
struct MindHeroCard: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 40)
                .fill(
                    LinearGradient(
                        colors: [Color.mintGreenLight.opacity(0.6), Color.white.opacity(0.6)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.textPrimary.opacity(0.06), radius: 16, y: 12)

            HStack {
                Spacer()
                Image("MindStoneImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .rotationEffect(.degrees(12))
                    .opacity(0.8)
                    .padding(.trailing, 16)
            }

            VStack(alignment: .leading, spacing: 0) {
                CategoryLabel(text: "今日推荐", color: .mindPrimary)
                    .opacity(0.7)
                    .padding(.bottom, 12)

                Text("潮热与情绪波动")
                    .font(AppFont.title(24))
                    .foregroundStyle(Color.textPrimary)
                    .tracking(-0.6)
                    .padding(.bottom, 12)

                Text("潮热引发的体温骤升会激活交感神经系统，进而触发应激反应，\n导致人警觉、急躁。")
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.textSecondary)
                    .lineSpacing(8.75)
                    .frame(width: 201)
                    .padding(.bottom, 12)

                NavigationLink(value: MindHomeView.MindRoute.emotionDetail(name: "潮热")) {
                    Text("查看详情")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.mindAccent)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.mindPrimary, in: Capsule())
                        .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
                }
                .simultaneousGesture(TapGesture().onEnded { Haptic.medium() })
            }
            .padding(32)
        }
    }
}
