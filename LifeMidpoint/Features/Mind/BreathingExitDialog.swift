import SwiftUI

// P6.16 退出跟练确认 (2:20235) — 全屏深色中断确认
struct BreathingExitDialog: View {
    let onContinue: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                breathFlower
                    .padding(.top, 140)

                Text("疗愈跟练尚未结束！")
                    .font(AppFont.title(32))
                    .foregroundStyle(Color(hex: 0xD3D3D3))
                    .tracking(-0.64)
                    .padding(.top, 52)

                Text("你要中断练习吗？")
                    .font(AppFont.body(24))
                    .foregroundStyle(Color(hex: 0xD3D3D3))
                    .tracking(-0.48)
                    .padding(.top, 12)

                VStack(spacing: 12) {
                    exitButton(title: "继续跟练", action: onContinue)
                    exitButton(title: "确认退出", action: onExit)
                }
                .padding(.top, 44)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
        }
    }

    private func exitButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.body(16))
                .foregroundStyle(.white)
                .tracking(-0.32)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: 0x4BBFED), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // 蓝色呼吸花朵 (与跟练页一致的视觉语言, 缩小静态版)
    private var breathFlower: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color.breathBlue.opacity(0.45))
                    .frame(width: 46, height: 46)
                    .offset(y: -15)
                    .rotationEffect(.degrees(Double(i) * 60))
                    .blendMode(.plusLighter)
            }
            ForEach(0..<6, id: \.self) { i in
                Capsule()
                    .fill(Color.breathCenter.opacity(0.75))
                    .frame(width: 16, height: 30)
                    .offset(y: -8)
                    .rotationEffect(.degrees(Double(i) * 60 + 30))
                    .blendMode(.plusLighter)
            }
        }
        .frame(width: 100, height: 96)
    }
}
