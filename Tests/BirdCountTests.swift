import Foundation
import Testing
@testable import BirdCount

struct BirdCountTests {
	@Test
	func decodeTaxonomy() throws {
	let json = "[{\"id\":\"amecro\",\"commonName\":\"American Crow\",\"scientificName\":\"Corvus brachyrhynchos\",\"order\":1,\"rank\":\"species\"}]"
		let data = json.data(using: .utf8)!
		let decoded = try JSONDecoder().decode([Taxon].self, from: data)
		#expect(decoded.count == 1)
		#expect(decoded.first?.id == "amecro")
		#expect(decoded.first?.commonName == "American Crow")
	}

	@Test
	func observationStoreCounts() throws {
		let store = ObservationStore()
		store.clearAll() // ensure a clean slate within the simulator defaults domain
		store.addObservation("amecro", count: 1)
		store.addObservation("amecro", count: 2)

		#expect(store.count(for: "amecro") == 3)
		#expect(store.totalIndividuals == 3)
		#expect(store.totalSpeciesObserved == 1)
	}
}
