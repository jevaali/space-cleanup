import Foundation
import Combine

// MARK: - Local models (replace the old network DTOs)

struct GameResult {
    let sessionId: UUID
    let satelliteId: UUID
    let score: Int
    let coinsEarned: Int
    let durationSeconds: Int
    let debrisCollectedCount: Int
}

struct SatelliteCard: Identifiable, Hashable {
    let satelliteId: UUID
    let name: String
    let difficultyTier: Int
    let unlockCost: Int
    let summary: String
    // Info shown in the "Discover" sheet
    let operatorName: String
    let noradId: Int
    let launchDate: Date
    let altitude: String
    let educationalInfo: String
    let funFact: String
    // Filled in from saved progress
    var isUnlocked: Bool = false
    var isPlayable: Bool = true
    var highScore: Int = 0

    var id: UUID { satelliteId }

    var difficultyLabel: String {
        switch difficultyTier {
        case 1: return "Easy"
        case 2: return "Medium"
        case 3: return "Hard"
        default: return "Expert"
        }
    }
}

struct CollectedDebris: Identifiable, Codable, Hashable {
    let debrisObjectId: UUID
    let name: String
    let orbitZone: String
    let riskCategory: String          // Common / Uncommon / Rare / Epic / Legendary
    let sizeEstimate: Double          // metres
    let educationalInfo: String
    let cleanupImportance: String
    let collectedAt: Date

    var id: UUID { debrisObjectId }

    var sizeText: String {
        sizeEstimate < 1
            ? "\(Int((sizeEstimate * 100).rounded()))cm"
            : String(format: "%.0fm", sizeEstimate)
    }
}

struct GameSummary {
    let score: Int
    let coinsEarned: Int
    let totalCoins: Int
    let newHighScore: Bool
    let firstCompletionBonus: Int
    let rewardedDebris: [CollectedDebris]
}

struct LocalRun: Identifiable, Codable, Hashable {
    let id: UUID
    let satelliteName: String
    let score: Int
    let debrisCollected: Int
    let date: Date
}

enum UnlockError: LocalizedError {
    case notEnoughCoins(missing: Int)

    var errorDescription: String? {
        switch self {
        case .notEnoughCoins(let missing): return "You need \(missing) more coins"
        }
    }
}

// MARK: - Store

/// All player progress, saved on the device in UserDefaults.
final class LocalStore: ObservableObject {
    static let shared = LocalStore()

    private struct SaveData: Codable {
        var coins = 0
        var totalScore = 0
        var unlocked: Set<UUID> = []
        var highScores: [UUID: Int] = [:]
        var completed: Set<UUID> = []
        var collection: [CollectedDebris] = []
        var runs: [LocalRun] = []
    }

    private static let saveKey = "local_save_v1"
    private static let maxRuns = 50

    @Published private var data: SaveData {
        didSet { save() }
    }

    private init() {
        if let raw = UserDefaults.standard.data(forKey: Self.saveKey),
           let decoded = try? JSONDecoder().decode(SaveData.self, from: raw) {
            data = decoded
        } else {
            data = SaveData()
        }
    }

    // MARK: Read

    var coins: Int { data.coins }
    var totalScore: Int { data.totalScore }
    var runs: [LocalRun] { data.runs }
    var collection: [CollectedDebris] { data.collection.sorted { $0.collectedAt > $1.collectedAt } }

    var satellites: [SatelliteCard] {
        SatelliteCatalog.all.map { sat in
            var copy = sat
            copy.isUnlocked = sat.unlockCost == 0 || data.unlocked.contains(sat.satelliteId)
            copy.highScore = data.highScores[sat.satelliteId] ?? 0
            return copy
        }
    }

    func highScore(for satelliteId: UUID) -> Int { data.highScores[satelliteId] ?? 0 }

    // MARK: Write

    func unlock(satelliteId: UUID) throws {
        guard let sat = SatelliteCatalog.all.first(where: { $0.satelliteId == satelliteId }),
              !data.unlocked.contains(satelliteId) else { return }
        guard data.coins >= sat.unlockCost else {
            throw UnlockError.notEnoughCoins(missing: sat.unlockCost - data.coins)
        }
        var d = data
        d.coins -= sat.unlockCost
        d.unlocked.insert(satelliteId)
        data = d
    }

    @discardableResult
    func recordGame(_ result: GameResult, satelliteName: String, difficultyTier: Int) -> GameSummary {
        var d = data

        let isNewHigh = result.score > (d.highScores[result.satelliteId] ?? 0)
        if isNewHigh { d.highScores[result.satelliteId] = result.score }

        var bonus = 0
        if !d.completed.contains(result.satelliteId) {
            d.completed.insert(result.satelliteId)
            bonus = 50 * max(1, difficultyTier)
        }

        let rewards = DebrisCatalog.rewards(forCollected: result.debrisCollectedCount, tier: difficultyTier)

        d.coins += result.coinsEarned + bonus
        d.totalScore += result.score
        d.collection.append(contentsOf: rewards)
        d.runs.append(LocalRun(id: result.sessionId,
                               satelliteName: satelliteName,
                               score: result.score,
                               debrisCollected: result.debrisCollectedCount,
                               date: Date()))
        d.runs.sort { $0.score > $1.score }
        if d.runs.count > Self.maxRuns { d.runs = Array(d.runs.prefix(Self.maxRuns)) }

        data = d

        return GameSummary(score: result.score,
                           coinsEarned: result.coinsEarned,
                           totalCoins: d.coins,
                           newHighScore: isNewHigh,
                           firstCompletionBonus: bonus,
                           rewardedDebris: rewards)
    }

    func resetProgress() { data = SaveData() }

    private func save() {
        if let raw = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(raw, forKey: Self.saveKey)
        }
    }
}

// MARK: - Satellite catalog

enum SatelliteCatalog {
    private static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: y, month: m, day: d)) ?? Date()
    }

    // Fixed IDs so saved progress keeps matching after app updates.
    static let all: [SatelliteCard] = [
        SatelliteCard(
            satelliteId: UUID(uuidString: "6A1F0C2E-0001-4C00-9000-000000000001")!,
            name: "Hubble Space Telescope", difficultyTier: 1, unlockCost: 0,
            summary: "A space telescope in low Earth orbit since 1990.",
            operatorName: "NASA & ESA", noradId: 20580, launchDate: date(1990, 4, 24),
            altitude: "~515 km",
            educationalInfo: "Hubble orbits above the blurring effect of Earth's atmosphere, giving it extremely sharp views of distant galaxies, nebulae and planets. Its observations helped measure how fast the universe is expanding.",
            funFact: "Astronauts visited Hubble five times between 1993 and 2009 to repair and upgrade it – the first visit fixed a flaw in its main mirror."),
        SatelliteCard(
            satelliteId: UUID(uuidString: "6A1F0C2E-0002-4C00-9000-000000000002")!,
            name: "Sentinel-2A", difficultyTier: 1, unlockCost: 150,
            summary: "A European Earth-observation satellite that photographs land and coastlines.",
            operatorName: "ESA (Copernicus)", noradId: 40697, launchDate: date(2015, 6, 23),
            altitude: "~786 km",
            educationalInfo: "Sentinel-2A takes detailed colour and infrared images of Earth's land. Scientists use them to track crops, forests, floods, wildfires and melting glaciers.",
            funFact: "Working with its twin Sentinel-2B, it can photograph the same spot on the equator every 5 days."),
        SatelliteCard(
            satelliteId: UUID(uuidString: "6A1F0C2E-0003-4C00-9000-000000000003")!,
            name: "Landsat 9", difficultyTier: 2, unlockCost: 300,
            summary: "Continues a NASA/USGS record of Earth's surface that began in 1972.",
            operatorName: "NASA & USGS", noradId: 49260, launchDate: date(2021, 9, 27),
            altitude: "~705 km",
            educationalInfo: "Landsat 9 measures visible and infrared light reflected from Earth's surface, helping monitor water use, city growth, deforestation and changes in land over decades.",
            funFact: "The Landsat program holds the longest continuous record of Earth's land surface taken from space."),
        SatelliteCard(
            satelliteId: UUID(uuidString: "6A1F0C2E-0004-4C00-9000-000000000004")!,
            name: "International Space Station", difficultyTier: 2, unlockCost: 450,
            summary: "A crewed laboratory that regularly moves to dodge tracked debris.",
            operatorName: "NASA, Roscosmos, ESA, JAXA & CSA", noradId: 25544, launchDate: date(1998, 11, 20),
            altitude: "~400–420 km",
            educationalInfo: "The ISS is the largest human-made structure in orbit and a laboratory where astronauts study biology, physics and how the human body copes with weightlessness.",
            funFact: "The ISS has had people on board continuously since November 2000, and it has fired its engines dozens of times to dodge space debris."),
        SatelliteCard(
            satelliteId: UUID(uuidString: "6A1F0C2E-0005-4C00-9000-000000000005")!,
            name: "GPS III", difficultyTier: 3, unlockCost: 700,
            summary: "A navigation satellite in medium Earth orbit, about 20,000 km up.",
            operatorName: "U.S. Space Force", noradId: 43873, launchDate: date(2018, 12, 23),
            altitude: "~20,200 km",
            educationalInfo: "GPS satellites broadcast precise time signals. Your phone compares signals from several satellites to work out where you are.",
            funFact: "GPS clocks have to be corrected for Einstein's relativity – without it, positions would drift by kilometres every day."),
        SatelliteCard(
            satelliteId: UUID(uuidString: "6A1F0C2E-0006-4C00-9000-000000000006")!,
            name: "GOES-16", difficultyTier: 3, unlockCost: 1000,
            summary: "A weather satellite in geostationary orbit, about 36,000 km up.",
            operatorName: "NOAA & NASA", noradId: 41866, launchDate: date(2016, 11, 19),
            altitude: "~35,786 km",
            educationalInfo: "In geostationary orbit, GOES-16 circles Earth exactly once a day, so it stays above the same spot and can watch storms and hurricanes develop over the Americas.",
            funFact: "It carried the first lightning mapper in geostationary orbit, which spots lightning flashes day and night."),
    ]
}

// MARK: - Debris catalog & reward rolls

enum DebrisCatalog {
    struct Template {
        let name: String
        let orbitZone: String
        let rarity: String
        let size: Double
        let info: String
        let cleanup: String

        func makeInstance() -> CollectedDebris {
            CollectedDebris(debrisObjectId: UUID(), name: name, orbitZone: orbitZone,
                            riskCategory: rarity, sizeEstimate: size,
                            educationalInfo: info, cleanupImportance: cleanup,
                            collectedAt: Date())
        }
    }

    static let templates: [Template] = [
        Template(name: "Fengyun-1C Fragment", orbitZone: "LEO", rarity: "Common", size: 0.1,
                 info: "In 2007 China destroyed its own Fengyun-1C weather satellite in an anti-satellite test, creating more than 3,000 tracked fragments.",
                 cleanup: "Many of these pieces sit high enough to stay in orbit for decades."),
        Template(name: "Cosmos 2251 Fragment", orbitZone: "LEO", rarity: "Common", size: 0.1,
                 info: "In 2009 the dead Russian satellite Cosmos 2251 collided with the working Iridium 33 – the first accidental crash between two intact satellites.",
                 cleanup: "Each fragment can trigger new collisions, multiplying the debris."),
        Template(name: "Iridium 33 Fragment", orbitZone: "LEO", rarity: "Common", size: 0.1,
                 info: "A piece of the Iridium 33 communications satellite, shattered in the 2009 collision with Cosmos 2251.",
                 cleanup: "Fragments cross the paths of busy satellite constellations."),
        Template(name: "Spent Upper Stage", orbitZone: "GTO", rarity: "Uncommon", size: 6,
                 info: "Rocket stages left behind after dropping satellites toward geostationary orbit swing between low and very high altitudes.",
                 cleanup: "Leftover fuel can cause these stages to explode years later."),
        Template(name: "Retired GEO Satellite", orbitZone: "GEO", rarity: "Uncommon", size: 5,
                 info: "At the end of their lives, geostationary satellites are pushed into a 'graveyard orbit' a few hundred kilometres higher.",
                 cleanup: "Satellites that fail before moving can drift through the valuable GEO belt."),
        Template(name: "SL-16 Rocket Body", orbitZone: "LEO", rarity: "Rare", size: 11,
                 info: "Large Zenit upper stages, each weighing around 9 tonnes, cluster in orbits roughly 800 km up.",
                 cleanup: "A collision involving one of these could create thousands of new fragments."),
        Template(name: "Astronaut's Tool Bag", orbitZone: "LEO", rarity: "Rare", size: 0.5,
                 info: "During a 2008 spacewalk outside the ISS an astronaut lost a tool bag. It orbited for months before burning up.",
                 cleanup: "Even small lost items move at around 28,000 km/h."),
        Template(name: "Envisat", orbitZone: "LEO", rarity: "Epic", size: 26,
                 info: "ESA's 8-tonne Envisat stopped responding in 2012 and is one of the largest dead objects in low Earth orbit.",
                 cleanup: "It is expected to stay up for well over a century unless it is removed."),
        Template(name: "Vanguard 1", orbitZone: "LEO", rarity: "Legendary", size: 0.16,
                 info: "Launched in 1958, Vanguard 1 is the oldest human-made object still in orbit.",
                 cleanup: "A reminder that what we leave in orbit can stay there for generations."),
    ]

    /// One reward per 5 debris cleared, up to 3 per game. Higher tiers roll rarer debris.
    static func rewards(forCollected count: Int, tier: Int) -> [CollectedDebris] {
        let pieces = min(3, count / 5)
        guard pieces > 0 else { return [] }
        return (0..<pieces).map { _ in roll(tier: tier).makeInstance() }
    }

    private static func roll(tier: Int) -> Template {
        let t = Double(max(1, tier))
        let table: [(String, Double)] = [
            ("Common", 50), ("Uncommon", 25), ("Rare", 12 + t * 2),
            ("Epic", 5 + t * 2), ("Legendary", 1 + t)
        ]
        var r = Double.random(in: 0..<table.reduce(0) { $0 + $1.1 })
        var rarity = "Common"
        for (name, weight) in table {
            if r < weight { rarity = name; break }
            r -= weight
        }
        return templates.filter { $0.rarity == rarity }.randomElement() ?? templates[0]
    }
}
