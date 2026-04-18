import SwiftUI

struct DrawerView: View {
    @Binding var isOpen: Bool
    @Binding var selectedModule: AppModule

    private let drawerWidth: CGFloat = 180

    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [
                        Color.drawerLavender.opacity(0.95),
                        Color.drawerPeach.opacity(0.9)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .blur(radius: 8)

                VStack(alignment: .leading, spacing: 40) {
                    Color.clear.frame(height: 60)

                    ForEach(drawerModules, id: \.self) { module in
                        Button {
                            selectedModule = module
                            withAnimation(.easeOut(duration: 0.25)) { isOpen = false }
                        } label: {
                            Text(module.rawValue)
                                .font(AppFont.title(28))
                                .foregroundStyle(
                                    selectedModule == module ? Color.textPrimary : Color.textSecondary.opacity(0.7)
                                )
                                .tracking(2)
                        }
                    }

                    Spacer()
                }
                .padding(.leading, 32)
            }
            .frame(width: drawerWidth)
            .frame(maxHeight: .infinity)

            Spacer()
        }
        .offset(x: isOpen ? 0 : -drawerWidth)
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: isOpen)
    }

    private var drawerModules: [AppModule] {
        [.health, .mind, .postOffice, .profile]
    }
}
