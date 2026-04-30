import SwiftUI

// MARK: - 症状跟踪 (2:21512)

struct SymptomTrackingView: View {
    @Environment(\.dismiss) private var dismiss

    private let sections: [SymptomSection] = [
        .init(
            note: "*血管舒缩症状：激素波动引发体温调节失衡，常表现为阵发性潮热与心悸。",
            symptoms: [
                .init(name: "潮热", desc: "面部、颈部及胸部突然发热，伴有皮肤潮红及随后的大汗。"),
                .init(name: "夜间盗汗", desc: "夜间睡眠中出现阵发性出汗，常伴有觉醒及失眠。"),
                .init(name: "心悸", desc: "自觉心脏跳动频率加快、节律不齐或有撞击胸壁感。"),
                .init(name: "血压波动", desc: "近期出现无诱因的血压升高或不稳定。")
            ]
        ),
        .init(
            note: "*神经与心理症状：自主神经功能紊乱，易导致睡眠障碍、焦虑及情绪波动。",
            symptoms: [
                .init(name: "入睡困难", desc: "入睡困难或夜间觉醒次数 ≥2 次，或醒后难以再次入睡。"),
                .init(name: "焦虑/易怒", desc: "持续的紧张感、对日常过度担忧；或易因微小刺激产生愤怒。")
            ]
        ),
        .init(
            note: "*肌肉与骨骼系统：雌激素下降引起骨质与关节液流失，表现为关节酸痛与僵硬。",
            symptoms: [
                .init(name: "月经紊乱", desc: "周期延长/缩短、经期改变或经量异常变化。"),
                .init(name: "皮肤干燥与瘙痒", desc: "皮肤弹性下降，伴有干燥、脱屑或阵发性瘙痒。"),
                .init(name: "尿频尿急", desc: "排尿次数明显增多，或出现难以控制的尿意。"),
                .init(name: "感觉异常", desc: "肢体末端或皮肤表面出现麻木、针刺感。")
            ]
        ),
        .init(
            note: "*皮肤与泌尿生殖系统：组织与粘膜变薄干燥，引发经期紊乱、皮肤瘙痒及尿频。",
            symptoms: [
                .init(name: "关节疼痛", desc: "关节、膝关节或腰骶部酸痛，晨起时伴有僵硬感。"),
                .init(name: "血压波动", desc: "全身或局部肌肉沉重、乏力及酸胀。")
            ]
        )
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                titleBlock

                ForEach(sections) { section in
                    symptomSection(section)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 92)
            .padding(.bottom, 36)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) { topBar }
    }

    private var topBar: some View {
        ZStack {
            Color.pageBackground
                .ignoresSafeArea(edges: .top)
                .frame(height: 108)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.mindPrimary)
                }
                Spacer()
                Text("症状跟踪")
                    .font(AppFont.title(24))
                    .tracking(1.44)
                Spacer()
                Color.clear.frame(width: 18, height: 18)
            }
            .padding(.horizontal, 34)
            .padding(.top, 42)
        }
    }

    private var titleBlock: some View {
        Text("请选择过去一周，\n你曾出现过的症状。")
            .font(AppFont.title(20))
            .foregroundStyle(Color.gray80)
            .lineSpacing(3)
            .tracking(0.9)
            .padding(.horizontal, 18)
    }

    private func symptomSection(_ section: SymptomSection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible())], spacing: 10) {
                ForEach(section.symptoms) { symptom in
                    NavigationLink {
                        SymptomDetailView(symptomName: symptom.name)
                    } label: {
                        symptomTile(symptom)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(section.note)
                .font(AppFont.body(10))
                .foregroundStyle(Color.black.opacity(0.5))
                .lineLimit(2)
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 8))
    }

    private func symptomTile(_ symptom: SymptomInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(symptom.name)
                .font(AppFont.body(16))
                .foregroundStyle(Color.deepCharcoal)
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 0.5)
            Text(symptom.desc)
                .font(AppFont.body(12))
                .foregroundStyle(Color.black)
                .lineSpacing(3)
                .lineLimit(3)
        }
        .padding(12)
        .frame(height: 86, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xF5EBF8), in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct SymptomSection: Identifiable {
    let id = UUID()
    let note: String
    let symptoms: [SymptomInfo]
}

private struct SymptomInfo: Identifiable {
    let id = UUID()
    let name: String
    let desc: String
}

// MARK: - 症状详情 (2:21723)

struct SymptomDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let symptomName: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                title
                trendCard
                insightCard
            }
            .padding(.horizontal, 24)
            .padding(.top, 92)
            .padding(.bottom, 40)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) { topBar }
    }

    private var topBar: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea(edges: .top).frame(height: 108)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.mindPrimary)
                }
                Spacer()
                Text(symptomName)
                    .font(AppFont.title(24))
                    .tracking(1.44)
                Spacer()
                Color.clear.frame(width: 18, height: 18)
            }
            .padding(.horizontal, 34)
            .padding(.top, 42)
        }
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("过去 30 天")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary)
            Text("\(symptomName)趋势")
                .font(AppFont.title(22))
                .foregroundStyle(Color.textPrimary)
        }
    }

    private var trendCard: some View {
        Canvas { ctx, size in
            let points: [CGFloat] = [0.2, 0.4, 0.72, 0.38, 0.58, 0.8, 0.52, 0.68, 0.48]
            var path = Path()
            for (i, p) in points.enumerated() {
                let x = size.width * CGFloat(i) / CGFloat(points.count - 1)
                let y = size.height * (1 - p)
                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
            ctx.stroke(path, with: .color(Color.healthPink), lineWidth: 2)
        }
        .frame(height: 130)
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: 0xFFB0A4))
                    .frame(width: 42, height: 42)
                    .overlay(Image(systemName: "lightbulb").foregroundStyle(.white))
                Text("提示")
                    .font(AppFont.title(18))
            }
            Text("最近 2 周，\(symptomName)出现频率有所上升。建议关注作息、饮食与压力水平，如症状持续影响生活，请及时咨询医生。")
                .font(AppFont.body(15))
                .foregroundStyle(Color.deepCharcoal)
                .lineSpacing(4)
                .padding(16)
                .background(Color(hex: 0xF8ECEA), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
    }
}
