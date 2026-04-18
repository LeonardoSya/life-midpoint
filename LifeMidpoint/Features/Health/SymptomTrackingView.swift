import SwiftUI

// P7.12 症状跟踪 (2:21512)
struct SymptomTrackingView: View {
    @Environment(\.dismiss) private var dismiss

    struct SymptomEntry: Identifiable {
        let id = UUID()
        let name: String
        let severity: Int // 1-3
        let icon: String
    }

    @State private var symptoms: [SymptomEntry] = [
        SymptomEntry(name: "潮热", severity: 3, icon: "flame"),
        SymptomEntry(name: "失眠", severity: 2, icon: "moon.zzz"),
        SymptomEntry(name: "盗汗", severity: 1, icon: "drop"),
        SymptomEntry(name: "心悸", severity: 2, icon: "heart"),
        SymptomEntry(name: "焦虑", severity: 2, icon: "waveform.path"),
        SymptomEntry(name: "头痛", severity: 0, icon: "brain"),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach($symptoms) { $entry in
                    symptomCard(entry: $entry)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left").foregroundStyle(Color.textPrimary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("症状跟踪").font(AppFont.title(17))
            }
        }
    }

    private func symptomCard(entry: Binding<SymptomEntry>) -> some View {
        HStack(spacing: 16) {
            Image(systemName: entry.wrappedValue.icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 40, height: 40)
                .background(Color.chipBackgroundAlt, in: Circle())

            Text(entry.wrappedValue.name)
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            HStack(spacing: 4) {
                ForEach(1...3, id: \.self) { level in
                    Button {
                        entry.wrappedValue = SymptomTrackingView.SymptomEntry(
                            name: entry.wrappedValue.name,
                            severity: level,
                            icon: entry.wrappedValue.icon
                        )
                    } label: {
                        Circle()
                            .fill(level <= entry.wrappedValue.severity ? Color.healthPink : Color.chipBackgroundIdle)
                            .frame(width: 12, height: 12)
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 10))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}

// P7.13 症状详情 (2:21723)
struct SymptomDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let symptomName: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(symptomName).font(AppFont.title(22))
                    Text("过去 30 天").font(AppFont.caption(12)).foregroundStyle(Color.textSecondary)
                }

                trendChart
                    .frame(height: 120)

                insightCard
            }
            .padding(24)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left").foregroundStyle(Color.textPrimary)
                }
            }
        }
    }

    private var trendChart: some View {
        Canvas { ctx, size in
            let points: [CGFloat] = [0.3, 0.5, 0.7, 0.4, 0.6, 0.8, 0.5, 0.7, 0.6, 0.5, 0.4, 0.5]
            let step = size.width / CGFloat(points.count - 1)
            var path = Path()
            for (i, p) in points.enumerated() {
                let pt = CGPoint(x: CGFloat(i) * step, y: size.height * (1 - p))
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            ctx.stroke(path, with: .color(Color.healthPink), lineWidth: 2)
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("观察").font(AppFont.caption(11)).foregroundStyle(Color.textSecondary)
            Text("最近 2 周，\(symptomName)出现频率有所上升。建议关注作息与饮食，必要时咨询医生。")
                .font(AppFont.body(13))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.healthPinkLight, in: RoundedRectangle(cornerRadius: 20))
    }
}
