import SwiftUI

// P6.16 退出跟练确认弹窗 (2:20235)
struct BreathingExitDialog: View {
    let onContinue: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("要退出跟练了吗？")
                        .font(AppFont.title(18))
                        .foregroundStyle(Color.textPrimary)

                    Text("已完成 2 分 30 秒，留下一份宁静。")
                        .font(AppFont.body(13))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.top, 24)

                HStack(spacing: 12) {
                    Button(action: onExit) {
                        Text("确认退出")
                            .font(AppFont.body(14))
                            .foregroundStyle(Color.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Capsule().stroke(Color.borderLight, lineWidth: 1)
                            )
                    }

                    Button(action: onContinue) {
                        Text("继续跟练")
                            .font(AppFont.body(14))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.mindPrimary, in: Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(width: 300)
            .background(.white, in: RoundedRectangle(cornerRadius: 20))
        }
    }
}
