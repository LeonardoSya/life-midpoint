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
            .padding(.top, 104)
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

// MARK: - 症状详情 / 症状记录 (2:21723)

struct SymptomDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let symptomName: String

    @State private var severity: SymptomSeverity?
    @State private var showOptions = false
    @State private var selectedFactors: Set<String> = ["压力", "情绪"]

    private let factorItems: [SymptomFactorItem] = [
        .init(name: "工作", icon: "briefcase"),
        .init(name: "人际关系", icon: "person.2"),
        .init(name: "压力", icon: "person"),
        .init(name: "饮食", icon: "fork.knife"),
        .init(name: "情绪", icon: "point.3.connected.trianglepath.dotted"),
        .init(name: "作息失调", icon: "barcode.viewfinder"),
        .init(name: "运动习惯", icon: "heart"),
        .init(name: "其它", icon: "gearshape")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            formCard
                .padding(.horizontal, 24)
                .padding(.top, 104)
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
                .buttonStyle(.plain)
                Spacer()
            }
            .overlay {
                Text("症状详情")
                    .font(AppFont.title(24))
                    .tracking(1.44)
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.horizontal, 28)
            .padding(.top, 42)
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("症状记录")
                .font(AppFont.title(20))
                .foregroundStyle(Color.deepCharcoal)

            severityBlock
            factorBlock
            actionButtons
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 26))
    }

    // MARK: 症状程度

    private var severityBlock: some View {
        VStack(spacing: 12) {
            severityCard
            if showOptions {
                severityOptions
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var severityCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("症状程度")
                    .font(AppFont.title(18))
                    .foregroundStyle(Color.deepCharcoal)
                Spacer()
                Button { toggleOptions() } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.deepCharcoal)
                        .rotationEffect(.degrees(90))
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: 0xE7DFFD), lineWidth: 0.8)
                        )
                }
                .buttonStyle(.plain)
            }

            Button { toggleOptions() } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill((severity?.color ?? Color.textPlaceholder).opacity(severity == nil ? 0.15 : 0.16))
                            .frame(width: 40, height: 40)
                        severityLevelBars(for: severity, barHeight: 16)
                    }
                    Text(severity?.label ?? "程度")
                        .font(AppFont.body(16))
                        .foregroundStyle(severity?.color ?? Color.black)
                    Spacer()
                }
                .opacity(severity == nil ? 0.4 : 1)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(Color(hex: 0xF5EBF8, alpha: 0.5), in: RoundedRectangle(cornerRadius: 30))
    }

    private var severityOptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("症状")
                .font(AppFont.body(16))
                .foregroundStyle(Color.deepCharcoal)
            VStack(spacing: 4) {
                ForEach(SymptomSeverity.allCases) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            severity = option
                            showOptions = false
                        }
                        Haptic.light()
                    } label: {
                        severityRow(option)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(hex: 0x101828, alpha: 0.08), radius: 18, x: 6, y: 10)
    }

    private func severityRow(_ option: SymptomSeverity) -> some View {
        let isSelected = severity == option
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(option.color.opacity(isSelected ? 0.18 : 0.08))
                    .frame(width: 32, height: 32)
                severityLevelBars(for: option, barHeight: 12)
            }
            Text(option.label)
                .font(AppFont.body(15))
                .foregroundStyle(isSelected ? option.color : Color.deepCharcoal)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(isSelected ? option.color : Color.cultured)
                    .frame(width: 16, height: 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(isSelected ? option.color : Color(hex: 0xF6F0F6), lineWidth: 2)
                    )
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.leading, 4)
        .padding(.trailing, 8)
        .frame(height: 36)
        .background(isSelected ? option.color.opacity(0.08) : Color.cultured, in: RoundedRectangle(cornerRadius: 12))
    }

    /// 用四格由矮到高的强度条替代单一色块, 让"几乎没有→重度"的递进关系一目了然,
    /// 而不再仅靠同一种紫色的深浅来区分.
    private func severityLevelBars(for option: SymptomSeverity?, barHeight: CGFloat) -> some View {
        let level = option?.level ?? 0
        let color = option?.color ?? Color.textPlaceholder
        return HStack(alignment: .bottom, spacing: 2.5) {
            ForEach(1...4, id: \.self) { i in
                Capsule()
                    .fill(i <= level ? color : color.opacity(0.2))
                    .frame(width: 3, height: barHeight * (0.45 + 0.18 * CGFloat(i)))
            }
        }
    }

    // MARK: 症状因素

    private var factorBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("症状因素")
                    .font(AppFont.title(18))
                    .foregroundStyle(Color.deepCharcoal)
                Spacer()
                Button { } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(hex: 0x8B63FF))
                }
                .buttonStyle(.plain)
            }

            FlowLayout(spacing: 8, lineSpacing: 10, alignment: .center) {
                ForEach(factorItems) { item in
                    factorChip(item)
                }
            }
        }
    }

    private func factorChip(_ item: SymptomFactorItem) -> some View {
        let isSelected = selectedFactors.contains(item.name)
        return Button {
            Haptic.light()
            if isSelected {
                selectedFactors.remove(item.name)
            } else {
                selectedFactors.insert(item.name)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
                Text(item.name)
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule().fill(Color(hex: 0xEDB3FF, alpha: 0.2))
                } else {
                    Capsule().stroke(Color(hex: 0xD6D3D1), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: 取消 / 保存

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button { dismiss() } label: {
                Text("取消")
                    .font(AppFont.body(18))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color(hex: 0xD9D9D9, alpha: 0.2), in: RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)

            Button {
                // TODO: 持久化症状记录 (severity + selectedFactors); 暂仅关闭页面
                dismiss()
            } label: {
                Text("保存")
                    .font(AppFont.body(18))
                    .foregroundStyle(Color(hex: 0x0D0D0D))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color(hex: 0xEDB3FF, alpha: 0.3), in: RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private func toggleOptions() {
        withAnimation(.easeInOut(duration: 0.2)) { showOptions.toggle() }
        Haptic.light()
    }
}

// MARK: - 症状记录数据类型

enum SymptomSeverity: String, CaseIterable, Identifiable {
    case minimal = "几乎没有"
    case mild = "轻度"
    case moderate = "中度"
    case severe = "重度"

    var id: String { rawValue }
    var label: String { rawValue }

    /// 1(最轻) ~ 4(最重), 用于强度条填充格数.
    var level: Int {
        switch self {
        case .minimal: return 1
        case .mild: return 2
        case .moderate: return 3
        case .severe: return 4
        }
    }

    /// 由柔和到浓烈的语义色阶(绿→黄→橙→红), 让程度差异靠色相与强度双重传达,
    /// 而不是像之前那样四档共用同一种紫色, 难以区分。
    var color: Color {
        switch self {
        case .minimal: return Color(hex: 0x8FBF8A)
        case .mild: return Color(hex: 0xE8C25A)
        case .moderate: return Color(hex: 0xEF9B57)
        case .severe: return Color(hex: 0xE0616B)
        }
    }
}

private struct SymptomFactorItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

// MARK: - 流式换行布局 (chips 自动折行并整行居中)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 10
    var alignment: HorizontalAlignment = .center

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = computeRows(maxWidth: maxWidth, subviews: subviews)
        let contentWidth = rows.map(\.width).max() ?? 0
        let height = rows.reduce(0) { $0 + $1.height } + lineSpacing * CGFloat(max(0, rows.count - 1))
        return CGSize(width: maxWidth.isFinite ? maxWidth : contentWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x: CGFloat
            switch alignment {
            case .center: x = bounds.minX + (bounds.width - row.width) / 2
            case .trailing: x = bounds.maxX - row.width
            default: x = bounds.minX
            }
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y + (row.height - item.size.height) / 2),
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + spacing
            }
            y += row.height + lineSpacing
        }
    }

    private struct RowItem { let index: Int; let size: CGSize }
    private struct Row { var items: [RowItem] = []; var width: CGFloat = 0; var height: CGFloat = 0 }

    private func computeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let projected = current.items.isEmpty ? size.width : current.width + spacing + size.width
            if !current.items.isEmpty && projected > maxWidth {
                rows.append(current)
                current = Row()
            }
            if current.items.isEmpty {
                current.width = size.width
            } else {
                current.width += spacing + size.width
            }
            current.items.append(RowItem(index: index, size: size))
            current.height = max(current.height, size.height)
        }
        if !current.items.isEmpty { rows.append(current) }
        return rows
    }
}
