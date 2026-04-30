import SwiftUI

// MARK: - 服药记录 (2:21827)

struct MedicationRecordView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        MedicationShell(
            title: "服药提醒",
            trailing: "plus",
            trailingRoute: .myMedications,
            onBack: { dismiss() }
        ) {
            VStack(spacing: 22) {
                weekCard
                recordTimeline
            }
            .padding(.horizontal, 26)
            .padding(.top, 92)
            .padding(.bottom, 40)
        }
    }

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("本周").font(AppFont.title(22))
                Text("（2.1 - 2.7）").font(AppFont.body(13))
                Spacer()
                Image(systemName: "chevron.left")
                Image(systemName: "chevron.right").foregroundStyle(Color(hex: 0x7BC5E2))
            }
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 8) {
                        Text(["日", "一", "二", "三", "四", "五", "六"][index]).font(AppFont.body(15))
                        Text(String(format: "%02d", index + 1))
                            .font(AppFont.body(15))
                            .frame(width: 38, height: 38)
                            .background(Color(hex: 0x7BC5E2, alpha: index == 2 ? 0.28 : 0.18), in: Circle())
                    }
                    .frame(maxWidth: .infinity)
                    .background(index == 2 ? Color(hex: 0x7BC5E2, alpha: 0.12) : .clear, in: RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 4)
    }

    private var recordTimeline: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 41) {
                Text("时间").font(AppFont.title(17))
                ForEach(["08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"], id: \.self) {
                    Text($0).font(AppFont.title(15)).foregroundStyle(Color.deepCharcoal.opacity(0.34))
                }
            }

            Rectangle()
                .fill(Color.black.opacity(0.14))
                .frame(width: 1, height: 536)
                .padding(.top, 55)

            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Text("服药记录").font(AppFont.title(17))
                    Spacer()
                    NavigationLink(value: HealthDashboardView.HealthRoute.myMedications) {
                        Text("我的药品")
                            .font(AppFont.body(13))
                            .foregroundStyle(Color(hex: 0x1D637E))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: 0x7BC5E2, alpha: 0.3), in: RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)
                }
                medicationLink("大豆异黄酮", desc: "口服胶囊，每日 1–2 次，1次一粒，随餐或饭后服用。", image: "MedicationIllustration", done: true)
                medicationLink("雌激素制剂片", desc: "片剂，每日 1 次，1次一粒，随餐或餐后服用。", image: "MedicationIllustration", done: true)
                medicationLink("鱼油", desc: "随餐服用，每日 1 次，1次一粒。", image: "MedicationIllustration", done: false)
                medicationLink("褪黑素", desc: "1次一粒，睡前 30–60 分钟服用。", image: "MedicationIllustration", done: false)
            }
        }
    }

    private func medicationLink(_ name: String, desc: String, image: String, done: Bool) -> some View {
        NavigationLink(value: HealthDashboardView.HealthRoute.reminder) {
            medicationCard(name, desc: desc, image: image, done: done)
        }
        .buttonStyle(.plain)
    }

    private func medicationCard(_ name: String, desc: String, image: String, done: Bool) -> some View {
        HStack(spacing: 12) {
            Image(image).resizable().scaledToFit().frame(width: 64, height: 64).padding(8).background(Color(hex: 0x7BC5E2, alpha: 0.15), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 8) {
                Text(name).font(AppFont.title(15))
                Text(desc).font(AppFont.body(13)).foregroundStyle(Color.black.opacity(0.7)).lineLimit(2)
            }
            Spacer()
            Image(systemName: done ? "checkmark" : "square")
                .foregroundStyle(done ? Color(hex: 0x1D637E) : Color.black.opacity(0.35))
                .frame(width: 33, height: 33)
                .background(done ? Color(hex: 0x7BC5E2, alpha: 0.46) : Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(done ? 0 : 0.35), style: StrokeStyle(lineWidth: 1, dash: done ? [] : [3, 3])))
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 114)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - 服药提醒详情 (2:22082)

struct MedicationReminderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        MedicationShell(title: "服药提醒", trailing: "ellipsis", onBack: { dismiss() }) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top, spacing: 28) {
                    Image("MedicationIllustration")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 147, height: 184)
                        .background(Color(hex: 0x7BC5E2, alpha: 0.15), in: RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 18) {
                        detailBlock("药品名称", "雌激素制剂片")
                        detailBlock("含量", "0.5 mg / 片")
                        detailBlock("类型", "更年期相关药物")
                    }
                }
                Group {
                    detailBlock("剂量", "1次一粒(1–2 mg)")
                    detailBlock("提醒时间", "每日 1 次 | 11:00 a.m.")
                    detailBlock("服用方式", "温水送服用，随餐或餐后服用")
                    detailBlock("周期", "28 天一周期，「服药 21 天，停药 7 天」")
                    detailBlock("注意", "饮食与相互作用：避免西柚 / 西柚汁，西柚会抑制代谢雌激素的酶，使药物在体内水平升高，增加不良反应风险。")
                }
                NavigationLink(value: HealthDashboardView.HealthRoute.editReminder) {
                    Text("修改提醒设置")
                        .font(AppFont.body(20))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(hex: 0xD7EEF6), in: RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color(hex: 0xCAE1E8), radius: 4, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .padding(.top, 40)
            }
            .padding(34)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 26)
            .padding(.top, 90)
        }
    }

    private func detailBlock(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label).font(AppFont.body(14)).foregroundStyle(Color.black.opacity(0.6))
            Text(value).font(AppFont.title(17)).foregroundStyle(Color.black)
        }
    }
}

// MARK: - 修改提醒设置 (2:21985)

struct EditReminderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        MedicationShell(title: "服药提醒", trailing: "ellipsis", onBack: { dismiss() }) {
            VStack(alignment: .leading, spacing: 18) {
                Text("添加药品").font(AppFont.title(24))
                formField("药物 / 补剂名称", value: "口服雌激素制剂片（28片）", trailing: "camera")
                optionGroup("药品类型", options: ["更年期相关药物", "营养补充剂", "其他"])
                HStack { stepperField("剂量", value: "1", unit: "片"); stepperField("频次", value: "1", unit: "日") }
                formField("服用方式", value: "温水送服用，随餐或餐后服用")
                HStack { stepperField("开始时间", value: "1  2月  2026", unit: ""); stepperField("持续时间", value: "3", unit: "周") }
                Text("添加提醒").font(AppFont.body(16))
                HStack {
                    Image("MedicationIllustration").resizable().scaledToFit().frame(width: 45, height: 45)
                    Text("11 : 00").font(AppFont.title(30))
                    Spacer()
                    HStack { Text("+"); Text("-") }.font(AppFont.title(18))
                }
                .padding(.horizontal, 18).frame(height: 61).background(Color(hex: 0x7BC5E2, alpha: 0.3), in: Capsule())
                Button("完成设置") { dismiss() }.font(AppFont.body(20)).foregroundStyle(.black).frame(maxWidth: .infinity).padding(.vertical, 18).background(Color(hex: 0xD7EEF6), in: RoundedRectangle(cornerRadius: 20)).padding(.horizontal, 50)
            }
            .padding(18)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 28)
            .padding(.top, 90)
        }
    }

    private func formField(_ label: String, value: String, trailing: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(AppFont.body(16))
            HStack {
                Text(value).font(AppFont.body(17))
                Spacer()
                if let trailing { Image(systemName: trailing).frame(width: 60, height: 41).background(Color(hex: 0x7BC5E2)) }
            }
            .padding(.horizontal, 14).frame(height: 41).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.black.opacity(0.09)))
        }
    }

    private func optionGroup(_ label: String, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(AppFont.body(16))
            VStack(spacing: 4) {
                ForEach(options, id: \.self) { option in
                    HStack { Circle().fill(Color(hex: 0x7BC5E2, alpha: 0.6)).frame(width: 32, height: 32); Text(option); Spacer(); Circle().stroke(Color(hex: 0x7BC5E2, alpha: 0.35), lineWidth: 2).frame(width: 16, height: 16) }
                        .padding(.horizontal, 8).frame(height: 36).background(Color.cultured, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.leading, 88)
        }
    }

    private func stepperField(_ label: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(AppFont.body(16))
            HStack { Text(value).font(AppFont.title(15)); Spacer(); Text(unit).font(AppFont.title(15)) }
                .padding(.horizontal, 16).frame(height: 41).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.black.opacity(0.09)))
        }
    }
}

// MARK: - 我的药品

struct MyMedicationsView: View {
    @Environment(\.dismiss) private var dismiss
    private let meds = ["大豆异黄酮", "雌激素制剂片", "鱼油", "褪黑素"]

    var body: some View {
        MedicationShell(title: "我的药品", trailing: "plus", trailingRoute: .editReminder, onBack: { dismiss() }) {
            VStack(spacing: 14) {
                ForEach(meds, id: \.self) { med in
                    HStack {
                        Image("MedicationIllustration").resizable().scaledToFit().frame(width: 58, height: 58).padding(8).background(Color(hex: 0x7BC5E2, alpha: 0.15), in: RoundedRectangle(cornerRadius: 10))
                        Text(med).font(AppFont.title(16))
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 13)).foregroundStyle(Color.textSecondary)
                    }
                    .padding(16)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 92)
        }
    }
}

private struct MedicationShell<Content: View>: View {
    let title: String
    let trailing: String
    var trailingRoute: HealthDashboardView.HealthRoute? = nil
    let onBack: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView(showsIndicators: false) { content().padding(.bottom, 36) }
            .background(Color.pageBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .top) {
                ZStack {
                    Color.pageBackground.ignoresSafeArea(edges: .top).frame(height: 108)
                    HStack {
                        Button(action: onBack) { Image(systemName: "arrow.left").font(.system(size: 18)).foregroundStyle(.black) }
                        Spacer()
                        Text(title).font(AppFont.title(24)).tracking(1.44)
                        Spacer()
                        if let trailingRoute {
                            NavigationLink(value: trailingRoute) {
                                Image(systemName: trailing)
                                    .frame(width: 39, height: 39)
                                    .background(Color.white, in: Circle())
                            }
                            .buttonStyle(.plain)
                        } else {
                            Image(systemName: trailing)
                                .frame(width: 39, height: 39)
                                .background(Color.white, in: Circle())
                        }
                    }
                    .padding(.horizontal, 34).padding(.top, 42)
                }
            }
    }
}
