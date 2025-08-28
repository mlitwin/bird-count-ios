import Foundation

/// Lightweight, stateless cache for values derived from ObservationStore.observations
/// Holds only derived data and pure calculations. The owning store is responsible for
/// invoking `rebuild(from:)` when the observations array changes.
struct ObservationStoreCache {
    private(set) var counts: [String:Int] = [:]
    private(set) var lastObservedAt: [String:Date] = [:]

    mutating func rebuild(from observations: [ObservationRecord]) {
        // Recompute counts map: species id -> sum of non-negative counts
        // and lastObservedAt: most recent end date per species.
        counts = [:]
        lastObservedAt = [:]
        func accumulate(_ record: ObservationRecord) {
            counts[record.taxonId, default: 0] += max(0, record.count)
            let ts = record.end
            if let existing = lastObservedAt[record.taxonId] {
                if ts > existing { lastObservedAt[record.taxonId] = ts }
            } else {
                lastObservedAt[record.taxonId] = ts
            }
            if !record.children.isEmpty {
                for child in record.children { accumulate(child) }
            }
        }
        for record in observations { accumulate(record) }
    }

    func count(for id: String) -> Int { counts[id] ?? 0 }
    func lastObservedDate(for id: String) -> Date? { lastObservedAt[id] }

    var totalIndividuals: Int { counts.values.reduce(0, +) }
    var totalSpeciesObserved: Int { counts.keys.count }
}
