import Foundation
import Testing
@testable import BirdCountCore

struct CoreLogicTests {
    @Test
    func observationStoreBasicCounts() {
        let store = ObservationStore()
        store.clearAll()
        store.addObservation("amecro", count: 2)
        store.addObservation("norbla", count: 1)
        #expect(store.count(for: "amecro") == 2)
        #expect(store.totalIndividuals == 3)
        #expect(store.totalSpeciesObserved == 2)
    }
}
