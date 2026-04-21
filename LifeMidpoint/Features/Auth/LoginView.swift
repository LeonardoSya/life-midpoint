import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppStateManager
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var agreedToTerms = false

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                titleSection

                Spacer()
                    .frame(height: 64)

                inputSection

                Spacer()
                    .frame(height: 32)

                loginButton

                termsSection
                    .padding(.top, AppSpacing.lg)

                Spacer()
                    .frame(height: 56)

                alternativeLoginSection

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
            .responsiveFill()
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            Color.brandWarmBg
            Image("LoginBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.38)
        }
        .ignoresSafeArea()
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("欢迎登入")
            .font(AppFont.title(40))
            .foregroundStyle(Color.textPrimary)
    }

    // MARK: - Input Fields

    private var inputSection: some View {
        VStack(spacing: AppSpacing.md) {
            TextField("请输入手机号码", text: $phoneNumber)
                .keyboardType(.phonePad)
                .padding(.horizontal, AppSpacing.lg)
                .frame(height: AppSpacing.buttonHeight)
                .background(Color.white, in: RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))

            HStack(spacing: 0) {
                TextField("请输入验证码", text: $verificationCode)
                    .keyboardType(.numberPad)

                Button("获取验证码") {
                    // TODO: send verification code
                }
                .font(AppFont.body(11))
                .foregroundStyle(Color.textPrimary)
                .fixedSize()
            }
            .padding(.horizontal, AppSpacing.lg)
            .frame(height: AppSpacing.buttonHeight)
            .background(Color.white, in: RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
        }
    }

    // MARK: - Login Button

    private var loginButton: some View {
        Button {
            appState.completeLogin()
        } label: {
            Text("登入")
                .font(AppFont.title(18))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(Color.brandSoftPink, in: RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius))
        }
    }

    // MARK: - Terms

    private var termsSection: some View {
        HStack(spacing: 4) {
            Button {
                agreedToTerms.toggle()
            } label: {
                Circle()
                    .stroke(Color.textSecondary, lineWidth: 0.8)
                    .frame(width: 12, height: 12)
                    .overlay {
                        if agreedToTerms {
                            Circle()
                                .fill(Color.textSecondary)
                                .frame(width: 6, height: 6)
                        }
                    }
            }

            Text("登入即表示你同意《隐私权政策》与《使用者建议》")
                .font(AppFont.body(10))
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Alternative Login

    private var alternativeLoginSection: some View {
        VStack(spacing: AppSpacing.md) {
            Text("其他方式登入")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)
                .padding(.bottom, AppSpacing.sm)

            alternativeButton(icon: "EmailIcon", title: "电子邮件登入")
            alternativeButton(icon: "WeChatIcon", title: "微信登入")
        }
    }

    private func alternativeButton(icon: String, title: String) -> some View {
        Button {
            // TODO: alternative login
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius)
                    .stroke(Color.textPrimary, lineWidth: 0.6)
            )
        }
    }
}
