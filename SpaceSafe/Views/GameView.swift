import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var appState: AppState
    @State private var scene: GameScene?
    @State private var gameOverResponse: ProcessGameSessionResponseDTO?
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
            if !showSplash, let response = gameOverResponse, let result = gameOverResult, splashDone {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)

                // Center the card instead of pushing it to the bottom
                GameOverView(
                    response: response,
                    sessionResult: result,
                    onPlayAgain: {
                        withAnimation { gameOverResponse = nil; splashDone = false }
                        startNewGame()
                    },
                    onMainMenu: {
                        withAnimation { gameOverResponse = nil; splashDone = false }
                        appState.screen = .main
                    }
                )
                .padding(.horizontal, 16)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .onAppear { startNewGame() }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: gameOverResponse != nil)
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
                await submitSession(result)
            }
        }
        scene = newScene
    }

    @MainActor
    func submitSession(_ result: GameResult) async {
        gameOverResult = result
        withAnimation { showSplash = true }

        let request = ProcessGameSessionRequestDTO(
            sessionId: result.sessionId,
            satelliteId: result.satelliteId,
            score: result.score,
            coinsEarned: result.coinsEarned,
            durationSeconds: result.durationSeconds,
            debrisCollectedCount: result.debrisCollectedCount,
            syncedOfflineGame: false
        )

        // Run both concurrently, sleep result discarded
        async let fetchedResponse = fetchSession(request: request, fallback: result)
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        let response = await fetchedResponse

        gameOverResponse = response
        withAnimation { showSplash = false }
        try? await Task.sleep(nanoseconds: 400_000_000)
        withAnimation { splashDone = true }
    }

    // Extracted so async let can call a proper async func (not a throwing closure)
    private func fetchSession(
        request: ProcessGameSessionRequestDTO,
        fallback: GameResult
    ) async -> ProcessGameSessionResponseDTO {
        do {
            let response = try await SessionService.shared.submitSession(request)
            let ids = response.rewardedDebris.compactMap { $0.debrisObjectId }
            DebrisImageStore.shared.assignAndSave(debrisIds: ids)
            return response
        } catch {
            return ProcessGameSessionResponseDTO(
                success: false,
                error: error.localizedDescription,
                totalCoins: fallback.coinsEarned,
                totalScore: fallback.score,
                newHighScore: false,
                firstCompletionRewardGranted: false,
                rewardedDebris: []
            )
        }
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
