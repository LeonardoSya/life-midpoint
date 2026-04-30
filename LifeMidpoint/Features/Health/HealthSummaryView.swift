import SwiftUI

// MARK: - 健康数据报告 (2:22372)

struct HealthSummaryView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HealthReportShell(title: "健康数据报告", onBack: { dismiss() }) {
            VStack(spacing: 16) {
                reportSection(
                    title: "本周健康数据总结",
                    text: "本周您的平均睡眠时长为 6小时3分钟，睡眠数据趋势显示修复性深度睡眠不足，且呈现入睡困难与中途惊醒并存的不稳定波动。生理周期目前处于第 5天，记录显示经量中等，并伴有持续的生理性点滴出血。静息心率（RHR）平均为 72次/分，相较于上周环比平均上升了 5 bpm，心血管指标显示您的自主神经系统当前处于较为紧绷的调节状态。"
                )

                reportSection(
                    title: "症状相关性与原因深度分析",
                    text: "分析显示，您的心率上升与本周记录的“潮热”及“心悸”症状高度相关，这通常受“压力过载”因素驱动，导致皮质醇水平波动，加重了心脏负荷与夜间盗汗。此外，本周记录的“关节疼痛”与生理期第 5 天的激素变化具有医学关联性，由于该阶段雌激素水平处于低位，减弱了对滑膜组织的保护，导致背部及膝部敏感性增强。"
                )

                reportSection(
                    title: "生活与疗愈建议",
                    text: "针对上述情况，建议您通过优化环境与生理调节相结合的方式进行干预。请将卧室温度维持在 18-22℃ 并穿着轻薄的全棉睡衣，如感心悸袭来可通过呼吸疗愈法以稳定神经系统亢奋；饮食中应适度增加黑芝麻、黑木耳及豆制品等富含植物雌激素与钙质的食物，并配合每日 15 分钟的更年期瑜伽或八段锦拉伸。"
                )
            }
            .padding(14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.12), radius: 4, y: 4)
        }
    }

    private func reportSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFont.title(18))
                .foregroundStyle(Color.black)
            Text(text)
                .font(AppFont.body(15))
                .foregroundStyle(Color.black)
                .lineSpacing(4)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: 0x7BC5E2, alpha: 0.15), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: 0xE9F2F7), lineWidth: 1))
        }
    }
}

private struct HealthReportShell<Content: View>: View {
    let title: String
    let onBack: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            content()
                .padding(.horizontal, 28)
                .padding(.top, 98)
                .padding(.bottom, 44)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) {
            ZStack {
                Color.pageBackground.ignoresSafeArea(edges: .top).frame(height: 112)
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.mindPrimary)
                    }
                    Spacer()
                    Text(title).font(AppFont.title(24)).tracking(1.44)
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .frame(width: 39, height: 39)
                        .background(Color.white, in: Circle())
                }
                .padding(.horizontal, 34)
                .padding(.top, 42)
            }
        }
    }
}
