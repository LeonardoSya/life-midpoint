import SwiftUI

// P7.18 健康数据总结 (2:22372)
struct HealthSummaryView: View {
    private let recommendations: [(title: String, icon: String)] = [
        ("睡前 1 小时调暗光线", "moon.fill"),
        ("晚餐后避免咖啡因", "cup.and.saucer"),
        ("每日 10 分钟正念呼吸", "leaf")
    ]

    var body: some View {
        ScreenScaffold(title: "健康数据报告") {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    titleSection
                    summaryCard
                    recommendationsCard
                }
                .padding(24)
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            CategoryLabel(text: "本周回顾")
            Text("综合健康评估").titleStyle(24)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle().fill(Color.sleepSecondary).frame(width: 10, height: 10)
                Text("概览").bodyStyle(13)
            }

            Text("深度睡眠不足，且呈现入睡困难与中途惊醒并存的不稳定波动；\u{201C}潮热\u{201D}及\u{201C}心悸\u{201D}症状与\u{201C}压力过载\u{201D}导致的心率加快相关；建议通过优化环境与生理调节相结合的方式进行干预。")
                .bodyStyle(13)
                .lineSpacing(6)
        }
        .asCard()
    }

    private var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("建议").bodyStyle(13)

            ForEach(recommendations, id: \.title) { rec in
                HStack(spacing: 12) {
                    Image(systemName: rec.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.mindPrimary)
                        .frame(width: 32, height: 32)
                        .background(Color.mindLight, in: Circle())
                    Text(rec.title).bodyStyle(13)
                    Spacer()
                }
            }
        }
        .asCard()
    }
}
