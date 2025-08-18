import Foundation

/// Lightweight, stateless cache for values derived from ObservationStore.observations
/// Holds only derived data and pure calculations. The owning store is responsible for
/// invoking `rebuild(from:)` when the observations array changes.
struct ObservationStoreCache {
    private(set) var counts: [String:Int] = [:]

    mutating func rebuild(from observations: [ObservationRecord]) {
        // Recompute counts map: species id -> sum of non-negative counts
        counts = observations.reduce(into: [:]) { dict, record in
            dict[record.taxonId, default: 0] += max(0, record.count)
        }
    }

    func count(for id: String) -> Int { counts[id] ?? 0 }

    var totalIndividuals: Int { counts.values.reduce(0, +) }
    var totalSpeciesObserved: Int { counts.keys.count }
}
