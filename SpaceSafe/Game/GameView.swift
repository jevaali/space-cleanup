import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var appState: AppState
    @State private var scene: GameScene?
    @State private var gameOverSummary: GameSummary?
    @State private var gameOverResult: GameResult?
    @State private var showSplash = false
    @State private var splashDone = false
    @State private var showRules = true
    

    var body: some View {
        ZStack {
            if let scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .id(scene.objectIdentifier)
            }
            
            if showRules {
                            Color.black.opacity(0.65)
                                .ignoresSafeArea()
                                .transition(.opacity)

                            RulesPopupView(
                                satelliteName: appState.selectedSatelliteName ?? "Unknown",
                                difficultyTier: appState.selectedDifficultyTier
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showRules = false
                                }
                                scene?.hasStarted = true
                                scene?.isPaused = false
                            }
                            .transition(.scale(scale: 0.92).combined(with: .opacity))
                            .zIndex(20)
                        }

            // ── Cinematic splash ──────────────────────────────────────
            if showSplash {
                GameOverSplashView()
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(10)
            }

            // ── Results card (centered) ───────────────────────────────
            if !showSplash, let summary = gameOverSummary, let result = gameOverResult, splashDone {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)

                // Center the card instead of pushing it to the bottom
                GameOverView(
                    summary: summary,
                    sessionResult: result,
                    onPlayAgain: {
                        withAnimation { gameOverSummary = nil; splashDone = false }
                        startNewGame()
                    },
                    onMainMenu: {
                        withAnimation { gameOverSummary = nil; splashDone = false }
                        appState.screen = .main
                    }
                )
                .padding(.horizontal, 16)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .onAppear { startNewGame() }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: gameOverSummary != nil)
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: splashDone)
    }

    func startNewGame() {
        showSplash = false
        splashDone = false
        showRules = true
        let newScene = GameScene()
        newScene.scaleMode = .resizeFill
        newScene.isPaused = false
        newScene.satelliteId = appState.selectedSatelliteId ?? UUID()
        newScene.difficultyTier = appState.selectedDifficultyTier
        newScene.satelliteName = appState.selectedSatelliteName ?? "Unknown"
        newScene.onGameOver = { result in
            Task { @MainActor in
                await finishGame(result)
            }
        }
        scene = newScene
    }

    @MainActor
    func finishGame(_ result: GameResult) async {
        gameOverResult = result
        withAnimation { showSplash = true }

        // Save progress on the device
        let summary = LocalStore.shared.recordGame(
            result,
            satelliteName: appState.selectedSatelliteName ?? "Unknown",
            difficultyTier: appState.selectedDifficultyTier
        )
        DebrisImageStore.shared.assignAndSave(debrisIds: summary.rewardedDebris.map(\.debrisObjectId))

        // Let the splash play
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        gameOverSummary = summary
        withAnimation { showSplash = false }
        try? await Task.sleep(nanoseconds: 400_000_000)
        withAnimation { splashDone = true }
    }
}

// MARK: - Cinematic Splash

struct GameOverSplashView: View {
    @State private var bgScale: CGFloat = 1.05
    @State private var textOffset: CGFloat = 30
    @State private var textOpacity: Double = 0
    @State private var alienOffset: CGFloat = -60
    @State private var alienOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background — nearly full screen
            Image("gameoverback")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.95,
                       maxHeight: UIScreen.main.bounds.height * 0.95)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .scaleEffect(bgScale)
                .animation(.easeOut(duration: 0.6), value: bgScale)

            // Title text — centered, bigger
            Image("gameovertext")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.72)
                .offset(y: textOffset - 40)   // slightly above center
                .opacity(textOpacity)
                .animation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.15), value: textOffset)
                .animation(.easeOut(duration: 0.4).delay(0.15), value: textOpacity)

            // Alien — bottom left
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    Image("alien")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.45)
                        .offset(x: alienOffset, y: 20)
                        .opacity(alienOpacity)
                        .animation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.3), value: alienOffset)
                        .animation(.easeOut(duration: 0.4).delay(0.3), value: alienOpacity)
                    Spacer()
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            bgScale     = 1.0
            textOffset  = 0
            textOpacity = 1
            alienOffset = 0
            alienOpacity = 1
        }
    }
}

extension SKScene {
    var objectIdentifier: ObjectIdentifier { ObjectIdentifier(self) }
}
