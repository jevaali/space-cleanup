import Foundation

final class DebrisImageStore {
    static let shared = DebrisImageStore()
    private init() {}

    private let key = "debrisImageMap"
    private let debrisImageNames = ["Debris1", "Debris2"]

    // Call this right after session submit, before showing the reward screen
    func assignAndSave(debrisIds: [UUID]) {
        var map = loadMap()
        for id in debrisIds {
            if map[id.uuidString] == nil {
                map[id.uuidString] = debrisImageNames.randomElement()!
            }
        }
        if let encoded = try? JSONEncoder().encode(map) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func imageName(for id: UUID) -> String {
        loadMap()[id.uuidString] ?? debrisImageNames.randomElement()!
    }

    private func loadMap() -> [String: String] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let map = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return map
    }
}
