import Foundation

/// Lightweight, stateless cache for values derived from ObservationStore.observations
/// Holds only derived data and pure calculations. The owning store is responsible for
/// invoking `rebuild(from:)` when the observations array changes.
struct ObservationStoreCache {
    private(set) var counts: [String:Int] = [:]

    mutating func rebuild(from observations: [ObservationRecord]) {
        // Recompute counts map: species id -> sum of non-negative counts
        // Includes counts from all nested children recursively.
        counts = [:]
        func accumulate(_ record: ObservationRecord) {
            counts[record.taxonId, default: 0] += max(0, record.count)
            if !record.children.isEmpty {
                for child in record.children { accumulate(child) }
            }
        }
        for record in observations { accumulate(record) }
    }

    func count(for id: String) -> Int { counts[id] ?? 0 }

    var totalIndividuals: Int { counts.values.reduce(0, +) }
    var totalSpeciesObserved: Int { counts.keys.count }
}
