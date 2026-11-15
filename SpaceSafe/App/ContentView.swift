import Foundation
import SwiftUI
import Combine

enum AppScreen {
    case launch, intro, main, gameLoading, game, leaderboard
}

class AppState: ObservableObject {
    @Published var screen: AppScreen = .launch
    @Published var selectedSatelliteId: UUID? = nil
    @Published var selectedDifficultyTier: Int = 1
    @Published var selectedSatelliteName: String? = nil
}

struct ContentView: View {
    @StateObject var appState = AppState()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            switch appState.screen {
            case .launch:      LaunchView()
            case .intro:       IntroView()
            case .main:        MainMenuView()
            case .gameLoading: GameLoadingView()
            case .game:        GameView()
            case .leaderboard: LeaderboardView()
            }
        }
        .environmentObject(appState)
        .preferredColorScheme(.dark)
    }
}
