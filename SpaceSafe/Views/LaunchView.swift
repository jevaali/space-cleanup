import SwiftUI

struct LaunchView: View {
    @EnvironmentObject var appState: AppState
    @State private var rotation = 0.0
    @State private var opacity = 0.0

    var body: some View {
        ZStack {
            SpaceBackground()

            VStack(spacing: 24) {
                Text("🛸")
                    .font(.system(size: 80))
                    .opacity(opacity)
                    .scaleEffect(opacity)

                Text("Space Debris Rescue")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.cyan, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .opacity(opacity)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                    .scaleEffect(1.5)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) { opacity = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { appState.screen = .intro }
            }
        }
    }
}
