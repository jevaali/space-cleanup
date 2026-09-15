import Foundation
import SwiftUI
import Combine

enum AppScreen {
    case launch, intro, login, register, main, gameLoading, game, leaderboard
}

class AppState: ObservableObject {
    @Published var screen: AppScreen = .launch
    @Published var isLoggedIn: Bool = UserDefaults.standard.string(forKey: "jwt_token") != nil
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
            case .login:       LoginView()
            case .register:    RegisterView()
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
