import SwiftUI

struct GameLoadingView: View {
    @EnvironmentObject var appState: AppState
    @State private var progress = 0.0
    @State private var statusText = "Loading satellite data..."

    let steps = [
        "Loading satellite data...",
        "Scanning orbital zones...",
        "Detecting debris fields...",
        "Preparing cleanup craft..."
    ]

    var body: some View {
        ZStack {
            SpaceBackground()

            VStack(spacing: 28) {
                Text("🛰️")
                    .font(.system(size: 64))

                Text(statusText)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.cyan)
                    .animation(.easeInOut, value: statusText)

                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
                    .frame(width: 300)
                    .scaleEffect(x: 1, y: 2)
            }
        }
        .onAppear { simulateLoading() }
    }

    func simulateLoading() {
        for (i, step) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6) {
                withAnimation {
                    statusText = step
                    progress = Double(i + 1) / Double(steps.count)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps.count) * 0.6) {
            appState.screen = .game
        }
    }
}
