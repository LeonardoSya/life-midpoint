import SwiftUI
import SwiftData

// P7.19 服药记录 (2:21827)
struct MedicationRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var todayDoses: [MedicationDoseEvent] = []

    private var repo: HealthRepository { HealthRepository(context: modelContext) }

    var body: some View {
        ScreenScaffold(title: "服药记录") {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(todayDoses) { dose in
                        MedicationRow(dose: dose, onToggle: {
                            Haptic.selection()
                            repo.toggleDose(dose)
                        })
                    }
                }
                .padding(24)
            }
        }
        .onAppear {
            // 每天首次访问时按药品默认提醒时间生成事件; 后续访问直接读取.
            todayDoses = repo.todayDoseEvents()
        }
    }
}

private struct MedicationRow: View {
    let dose: MedicationDoseEvent
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: dose.taken ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundStyle(dose.taken ? Color.sleepSecondary : Color.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(dose.medication?.name ?? "未命名").bodyStyle(14)
                Text(dose.scheduledTime).captionStyle(10)
            }

            Spacer()

            Image("MedicationIllustration")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}

// P7.20 服药提醒详情 (2:22082)
struct MedicationReminderView: View {
    var body: some View {
        ScreenScaffold(title: nil) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    HStack {
                        Text("大豆异黄酮").titleStyle(20)
                        Spacer()
                    }

                    DetailRow(label: "时间", value: "09:00")
                    DetailRow(label: "频率", value: "每日")
                    DetailRow(label: "剂量", value: "1 粒")
                    DetailRow(label: "备注", value: "空腹服用")

                    Button { Haptic.medium() } label: {
                        Text("修改提醒")
                            .font(AppFont.body(14)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.sleepSecondary, in: RoundedRectangle(cornerRadius: 24))
                    }
                }
                .padding(24)
            }
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).bodyStyle(13).foregroundStyle(Color.textSecondary)
            Spacer()
            Text(value).bodyStyle(13)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(.white, in: RoundedRectangle(cornerRadius: 12))
    }
}

// P7.21 修改提醒 (2:21985)
struct EditReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var time = Date()
    @State private var frequency = "每日"

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker("提醒时间", selection: $time, displayedComponents: .hourAndMinute)
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))

                Picker("频率", selection: $frequency) {
                    ForEach(["每日", "每周", "隔日"], id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)

                Spacer()

                PrimaryButton(title: "保存", color: .sleepSecondary) { dismiss() }
            }
            .padding(24)
            .background(Color.pageBackground.ignoresSafeArea())
            .navigationTitle("修改提醒")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// P7.22 我的药品 (2:21921)
struct MyMedicationsView: View {
    @Query(sort: \Medication.createdAt, order: .forward)
    private var medications: [Medication]

    var body: some View {
        ScreenScaffold(title: "我的药品", trailingIcon: "plus") {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(medications) { med in
                        HStack {
                            Image("MedicationIllustration")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .padding(2)
                                .background(Color.healthPinkLight, in: Circle())
                            Text(med.name).bodyStyle(14)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(24)
            }
        }
    }
}
