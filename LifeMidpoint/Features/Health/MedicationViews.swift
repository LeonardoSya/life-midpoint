import SwiftUI

// P7.19 服药记录 (2:21827)
struct MedicationRecordView: View {
    @State private var medications: [MedicationItem] = MedicationMock.list

    var body: some View {
        ScreenScaffold(title: "服药记录") {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach($medications) { $med in
                        MedicationRow(med: $med)
                    }
                }
                .padding(24)
            }
        }
    }
}

private struct MedicationRow: View {
    @Binding var med: MedicationItem

    var body: some View {
        HStack(spacing: 12) {
            Button {
                Haptic.selection()
                med.checked.toggle()
            } label: {
                Image(systemName: med.checked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundStyle(med.checked ? Color.sleepSecondary : Color.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(med.name).bodyStyle(14)
                Text(med.time).captionStyle(10)
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
    var body: some View {
        ScreenScaffold(title: "我的药品", trailingIcon: "plus") {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(MedicationMock.allDrugs, id: \.self) { med in
                        HStack {
                            Image("MedicationIllustration")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .padding(2)
                                .background(Color.healthPinkLight, in: Circle())
                            Text(med).bodyStyle(14)
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
