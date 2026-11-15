import SpriteKit

class GameScene: SKScene {

    // MARK: - External config (set from GameView before presenting)
    var satelliteId: UUID = UUID()
    var satelliteName: String = "Unknown"
    var difficultyTier: Int = 1

    // MARK: - Callback
    var onGameOver: ((GameResult) -> Void)?
    
    var hasStarted = false

    // MARK: - Nodes
    var earthNode: SKSpriteNode!
    var satelliteNode: SKSpriteNode!
    var draggedNode: SKSpriteNode?

    // MARK: - State
    var satelliteLives = 3
    var coins = 0
    var score = 0
    var debrisCollected = 0
    var gameOver = false
    var gameStartTime: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0

    // MARK: - Spawning
    var lastSpawnTime: TimeInterval = 0
    var spawnInterval: TimeInterval = 2.0

    // MARK: - HUD labels
    var livesLabel: SKLabelNode!
    var coinsLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var satNameLabel: SKLabelNode!
    var tierLabel: SKLabelNode!

    // MARK: - Difficulty Config

    private struct DifficultyConfig {
        let startingLives: Int
        let initialSpawnInterval: TimeInterval
        let minSpawnInterval: TimeInterval
        let spawnIntervalDecrement: Double
        // Debris: travel duration range (lower = faster debris)
        let debrisSpeedRange: ClosedRange<Double>
        // Debris size: base width (height matches). Higher tier = smaller debris
        let debrisSizeRange: ClosedRange<CGFloat>
        // Comet: multiplier on base duration (lower = faster comet)
        let cometSpeedMultiplier: Double
        // Comet size range (random per spawn)
        let cometSizeRange: ClosedRange<CGFloat>
        // 1-in-N chance of spawning a comet vs debris
        let cometChance: Int
        // How quickly things ramp up over time (extra decrement per 30 seconds elapsed)
        let progressiveRampPerInterval: Double
    }

    private var config: DifficultyConfig {
        switch difficultyTier {
        case 1:
            return DifficultyConfig(
                startingLives: 3,
                initialSpawnInterval: 2.4,
                minSpawnInterval: 0.85,
                spawnIntervalDecrement: 0.025,
                debrisSpeedRange: 4.5...6.5,
                debrisSizeRange: 60...90,
                cometSpeedMultiplier: 1.3,
                cometSizeRange: 120...200,
                cometChance: 6,
                progressiveRampPerInterval: 0.004
            )
        case 2:
            return DifficultyConfig(
                startingLives: 3,
                initialSpawnInterval: 2.0,
                minSpawnInterval: 0.7,
                spawnIntervalDecrement: 0.04,
                debrisSpeedRange: 3.5...5.5,
                debrisSizeRange: 50...80,
                cometSpeedMultiplier: 1.0,
                cometSizeRange: 130...210,
                cometChance: 5,
                progressiveRampPerInterval: 0.006
            )
        case 3:
            return DifficultyConfig(
                startingLives: 2,
                initialSpawnInterval: 1.6,
                minSpawnInterval: 0.55,
                spawnIntervalDecrement: 0.055,
                debrisSpeedRange: 2.5...4.0,
                debrisSizeRange: 40...65,
                cometSpeedMultiplier: 0.85,
                cometSizeRange: 140...220,
                cometChance: 4,
                progressiveRampPerInterval: 0.008
            )
        default: // tier 4+
            return DifficultyConfig(
                startingLives: 1,
                initialSpawnInterval: 1.3,
                minSpawnInterval: 0.4,
                spawnIntervalDecrement: 0.07,
                debrisSpeedRange: 1.8...3.0,
                debrisSizeRange: 32...55,
                cometSpeedMultiplier: 0.65,
                cometSizeRange: 150...230,
                cometChance: 3,
                progressiveRampPerInterval: 0.012
            )
        }
    }

    private func tierLabel(for tier: Int) -> String {
        switch tier {
        case 1: return "★☆☆☆ EASY"
        case 2: return "★★☆☆ MEDIUM"
        case 3: return "★★★☆ HARD"
        default: return "★★★★ BRUTAL"
        }
    }

    private func tierColor(for tier: Int) -> SKColor {
        switch tier {
        case 1: return SKColor(red: 0.2, green: 0.9, blue: 0.4, alpha: 1)
        case 2: return SKColor(red: 1.0, green: 0.8, blue: 0.1, alpha: 1)
        case 3: return SKColor(red: 1.0, green: 0.45, blue: 0.1, alpha: 1)
        default: return SKColor(red: 1.0, green: 0.15, blue: 0.2, alpha: 1)
        }
    }

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.03, green: 0.03, blue: 0.12, alpha: 1)
        setupStars()
        setupEarth()
        setupSatellite()
        setupHUD()

        // Apply starting difficulty
        satelliteLives = config.startingLives
        spawnInterval = config.initialSpawnInterval
        updateLivesLabel()
    }

    // MARK: - Setup

    func setupEarth() {
        earthNode = SKSpriteNode(imageNamed: "Earth")
        if let texture = earthNode.texture {
            let ratio = texture.size().width / texture.size().height
            let width = size.height * ratio
            earthNode.size = CGSize(width: width, height: size.height)
            earthNode.position = CGPoint(x: width / 2, y: size.height / 2)
        }
        addChild(earthNode)
    }

    func setupSatellite() {
        satelliteNode = SKSpriteNode(imageNamed: "Sat1")
        satelliteNode.size = CGSize(width: 240, height: 240)
        satelliteNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 8))
        satelliteNode.run(rotate)
        addChild(satelliteNode)
    }

    // MARK: - Stars

    func setupStars() {
        for _ in 0..<60 { spawnStar(randomY: true) }
    }

    func spawnStar(randomY: Bool = false) {
        let starNames = ["Star1", "Star2", "Star3"]
        let name = starNames.randomElement()!
        let star = SKSpriteNode(imageNamed: name)
        let scale = CGFloat.random(in: 0.3...1.0)
        star.size = CGSize(width: 40 * scale, height: 40 * scale)
        star.alpha = CGFloat.random(in: 0.3...0.9)
        star.name = "star"
        let x = CGFloat.random(in: 0...size.width)
        let y = randomY ? CGFloat.random(in: 0...size.height) : size.height + 40
        star.position = CGPoint(x: x, y: y)
        star.zPosition = -1
        addChild(star)
        let duration = Double.random(in: 8...20)
        let moveDown = SKAction.moveTo(y: -40, duration: duration)
        let remove = SKAction.removeFromParent()
        let spawn = SKAction.run { [weak self] in self?.spawnStar() }
        star.run(SKAction.sequence([moveDown, remove, spawn]))
    }

    // MARK: - HUD

    func setupHUD() {
        let topY = size.height - 50

        // Lives — top right
        livesLabel = SKLabelNode(text: "❤️ \(satelliteLives)")
        livesLabel.position = CGPoint(x: size.width - 120, y: topY)
        livesLabel.fontSize = 26
        livesLabel.fontName = "AvenirNext-Bold"
        livesLabel.fontColor = .white
        addChild(livesLabel)

        // Coins — top center
        coinsLabel = SKLabelNode(text: "🪙 0")
        coinsLabel.position = CGPoint(x: size.width / 2, y: topY)
        coinsLabel.fontSize = 26
        coinsLabel.fontName = "AvenirNext-Bold"
        coinsLabel.fontColor = .yellow
        addChild(coinsLabel)

        // Score — top left area
        scoreLabel = SKLabelNode(text: "⭐️ 0")
        scoreLabel.position = CGPoint(x: 220, y: topY)
        scoreLabel.fontSize = 26
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontColor = .white
        addChild(scoreLabel)

        // Satellite name — below lives, top right
        satNameLabel = SKLabelNode(text: satelliteName.uppercased())
        satNameLabel.position = CGPoint(x: size.width - 120, y: topY - 34)
        satNameLabel.fontSize = 13
        satNameLabel.fontName = "AvenirNext-Bold"
        satNameLabel.fontColor = SKColor(white: 1, alpha: 0.55)
        satNameLabel.horizontalAlignmentMode = .center
        addChild(satNameLabel)

        // Difficulty tier — below satellite name
        let tierNode = SKLabelNode(text: tierLabel(for: difficultyTier))
        tierNode.position = CGPoint(x: size.width - 120, y: topY - 56)
        tierNode.fontSize = 11
        tierNode.fontName = "AvenirNext-Bold"
        tierNode.fontColor = tierColor(for: difficultyTier)
        tierNode.horizontalAlignmentMode = .center
        addChild(tierNode)
        
        // Background pill
        let finishBg = SKShapeNode(rectOf: CGSize(width: 90, height: 34), cornerRadius: 10)
        finishBg.fillColor = SKColor(red: 1, green: 0.25, blue: 0.25, alpha: 0.18)
        finishBg.strokeColor = SKColor(red: 1, green: 0.25, blue: 0.25, alpha: 0.6)
        finishBg.lineWidth = 1.5
        finishBg.position = CGPoint(x: 80, y: size.height - 50)
        finishBg.zPosition = 10
        finishBg.name = "finishButton"
        addChild(finishBg)

        // Label inside
        let finishLabel = SKLabelNode(text: "✕  FINISH")
        finishLabel.name = "finishButton"
        finishLabel.fontSize = 13
        finishLabel.fontName = "AvenirNext-Bold"
        finishLabel.fontColor = SKColor(red: 1, green: 0.35, blue: 0.35, alpha: 1)
        finishLabel.verticalAlignmentMode = .center
        finishLabel.horizontalAlignmentMode = .center
        finishLabel.position = .zero
        finishLabel.zPosition = 11
        finishBg.addChild(finishLabel)
    }

    func updateLivesLabel() {
        livesLabel.text = "❤️ \(satelliteLives)"
    }

    // MARK: - Spawning

    func spawnDebris() {
        let debrisNames = ["Debris1", "Debris2"]
        let debris = SKSpriteNode(imageNamed: debrisNames.randomElement()!)

        let side = CGFloat.random(in: config.debrisSizeRange)
        debris.size = CGSize(width: side, height: side)
        debris.position = randomEdgePosition()
        debris.name = "debris"

        let angle: CGFloat = Bool.random() ? .pi : -.pi
        let rotateDuration = Double.random(in: 2.5...5.0)
        debris.run(SKAction.repeatForever(
            SKAction.rotate(byAngle: angle, duration: rotateDuration)
        ))

        addChild(debris)

        let duration = Double.random(in: config.debrisSpeedRange)
        let move = SKAction.move(to: satelliteNode.position, duration: duration)
        let hit = SKAction.run { [weak self] in self?.debrisHitSatellite(debris) }
        debris.run(SKAction.sequence([move, hit]))
    }

    func spawnComet() {
        let speedTier = Int.random(in: 1...3)
        let cometName = "Comet\(speedTier)"
        let baseDuration: Double
        switch speedTier {
        case 1: baseDuration = 4.5
        case 2: baseDuration = 3.0
        default: baseDuration = 1.8
        }

        let comet = SKSpriteNode(imageNamed: cometName)
        let cometSide = CGFloat.random(in: config.cometSizeRange)
        comet.size = CGSize(width: cometSide, height: cometSide)
        comet.position = randomEdgePosition()
        comet.name = "comet"
        addChild(comet)

        let target = Bool.random() ? earthNode.position : satelliteNode.position
        let offset = CGPoint(x: CGFloat.random(in: -80...80), y: CGFloat.random(in: -80...80))
        let destination = CGPoint(x: target.x + offset.x, y: target.y + offset.y)

        let dx = destination.x - comet.position.x
        let dy = destination.y - comet.position.y

        // No rotation action — single zRotation so tail streams behind
        // If tail is still wrong, cycle the offset: atan2(dy,dx) / -.pi/2 / +.pi / +.pi/2
        comet.zRotation = atan2(dy, dx) + .pi * 3/4

        let duration = baseDuration * config.cometSpeedMultiplier
        let move = SKAction.move(to: destination, duration: duration)
        let check = SKAction.run { [weak self] in self?.cometReachedTarget(comet, destination: destination) }
        comet.run(SKAction.sequence([move, check, SKAction.removeFromParent()]))
    }

    

    func randomEdgePosition() -> CGPoint {
        let edge = Int.random(in: 0...2)
        switch edge {
        case 0: return CGPoint(x: CGFloat.random(in: 200...size.width), y: size.height + 20)
        case 1: return CGPoint(x: CGFloat.random(in: 200...size.width), y: -20)
        default: return CGPoint(x: size.width + 20, y: CGFloat.random(in: 0...size.height))
        }
    }

    // MARK: - Collision outcomes

    func debrisHitSatellite(_ node: SKSpriteNode) {
        guard !gameOver, node.parent != nil else { return }
        node.removeFromParent()
        satelliteLives -= 1
        updateLivesLabel()
        flashSatellite()
        if satelliteLives <= 0 { triggerGameOver(reason: "Satellite destroyed") }
    }

    func cometReachedTarget(_ node: SKSpriteNode, destination: CGPoint) {
        guard !gameOver, node.parent != nil else { return }
        node.removeFromParent()

        let distToEarth = hypot(destination.x - earthNode.position.x,
                                destination.y - earthNode.position.y)
        let distToSat   = hypot(destination.x - satelliteNode.position.x,
                                destination.y - satelliteNode.position.y)

        if distToEarth < distToSat {
            triggerGameOver(reason: "Comet hit Earth! 🌍")
        } else {
            satelliteLives -= 1
            updateLivesLabel()
            flashSatellite()
            if satelliteLives <= 0 { triggerGameOver(reason: "Satellite destroyed") }
        }
    }
    func flashSatellite() {
        satelliteNode.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        ]))
    }

    func triggerGameOver(reason: String) {
        guard !gameOver else { return }
        gameOver = true
        isPaused = true

        let duration = gameStartTime > 0 ? Int(lastUpdateTime - gameStartTime) : 0
        let result = GameResult(
            sessionId: UUID(),
            satelliteId: satelliteId,
            score: score,
            coinsEarned: coins,
            durationSeconds: duration,
            debrisCollectedCount: debrisCollected
        )
        onGameOver?(result)
    }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        
        if tappedNode.name == "finishButton" {
                triggerGameOver(reason: "Finished")
                return
            }

        if tappedNode.name == "comet" {
            let pop = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.removeFromParent()
            ])
            tappedNode.run(pop)
        } else if tappedNode.name == "debris" {
            draggedNode = tappedNode as? SKSpriteNode
            draggedNode?.removeAllActions()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let node = draggedNode else { return }
        node.position = touch.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = draggedNode else { return }
        if node.position.x < 160 {
            // Dragged into Earth atmosphere — burn it up, collect coins
            let burnUp = SKAction.sequence([
                SKAction.scale(to: 1.4, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ])
            node.run(burnUp)
            coins += 10
            debrisCollected += 1
            coinsLabel.text = "🪙 \(coins)"
        } else {
            // Missed — send it back toward the satellite
            let move = SKAction.move(to: satelliteNode.position, duration: 2.5)
            let hit = SKAction.run { [weak self] in self?.debrisHitSatellite(node) }
            let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1.5))
            node.run(rotate)
            node.run(SKAction.sequence([move, hit]))
        }
        draggedNode = nil
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        guard !gameOver, hasStarted else { return }
        if gameStartTime == 0 { gameStartTime = currentTime }
        lastUpdateTime = currentTime

        let elapsed = currentTime - gameStartTime
        score = Int(elapsed + (elapsed * elapsed) / 60.0)
        scoreLabel.text = "⭐️ \(score)"

        if currentTime - lastSpawnTime > spawnInterval {
            lastSpawnTime = currentTime
            Int.random(in: 0..<config.cometChance) == 0 ? spawnComet() : spawnDebris()

            // Progressive ramp: base decrement + extra ramp that grows over time
            // Every second of elapsed time adds a tiny extra push, regardless of tier
            let timeBonus = config.progressiveRampPerInterval * (elapsed / 30.0)
            let totalDecrement = config.spawnIntervalDecrement + timeBonus
            spawnInterval = max(config.minSpawnInterval, spawnInterval - totalDecrement)
        }
    }
}
