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

	@Test
	func taxonomySearchOrdersByCommonnessAscending() throws {
		let taxa = [
			Taxon(id: "c0", commonName: "Rare", scientificName: "Rarus", order: 2, rank: "species", commonness: 0),
			Taxon(id: "c3", commonName: "Common", scientificName: "Communis", order: 3, rank: "species", commonness: 3),
			Taxon(id: "c1", commonName: "Scarce", scientificName: "Scarsus", order: 1, rank: "species", commonness: 1),
			Taxon(id: "unk", commonName: "Unknown", scientificName: "Incertus", order: 0, rank: "species", commonness: nil)
		]
		let taxStore = TaxonomyStore(); taxStore.loadPreview(species: taxa)
		// Add observations to set recency for equal commonness tie-breaker
		let obsStore = ObservationStore()
		let now = Date()
		obsStore.clearAll()
		obsStore.addObservation("c1", begin: now.addingTimeInterval(-120), end: now.addingTimeInterval(-120), count: 1) // older
		obsStore.addObservation("c0", begin: now.addingTimeInterval(-60), end: now.addingTimeInterval(-60), count: 1)  // newer but different commonness
		// Register proxy so TaxonomyStore can see last dates
		ObservationStoreProxy.shared.register(obsStore)
		let results = taxStore.search("")
		let ids = results.map { $0.id }
		#expect(ids == ["c0", "c1", "c3", "unk"]) // rare → scarce (older first) → common → unknown
	}

	@Test
	func taxonomySearchPutsRecentSpeciesAtBottom() throws {
		let now = Date()
		let taxa = [
			Taxon(id: "rareOld", commonName: "Rare Old", scientificName: "Rarus antiquus", order: 1, rank: "species", commonness: 0),
			Taxon(id: "scarceOld", commonName: "Scarce Old", scientificName: "Scarsus antiquus", order: 2, rank: "species", commonness: 1),
			Taxon(id: "commonRecentOlder", commonName: "Common Recent Older", scientificName: "Communis recenta", order: 3, rank: "species", commonness: 3),
			Taxon(id: "commonRecentNewest", commonName: "Common Recent Newest", scientificName: "Communis recentissimus", order: 4, rank: "species", commonness: 3)
		]
		let taxStore = TaxonomyStore(); taxStore.loadPreview(species: taxa)
		let obsStore = ObservationStore(); obsStore.clearAll()
		// Two recent within 24h, ensure older recent comes before newer recent (so newest at the very bottom)
		obsStore.addObservation("commonRecentOlder", begin: now.addingTimeInterval(-60*60), end: now.addingTimeInterval(-60*60), count: 1)
		obsStore.addObservation("commonRecentNewest", begin: now.addingTimeInterval(-10*60), end: now.addingTimeInterval(-10*60), count: 1)
		// Older observations outside 24h for others
		obsStore.addObservation("rareOld", begin: now.addingTimeInterval(-3*24*60*60), end: now.addingTimeInterval(-3*24*60*60), count: 1)
		obsStore.addObservation("scarceOld", begin: now.addingTimeInterval(-2*24*60*60), end: now.addingTimeInterval(-2*24*60*60), count: 1)
		ObservationStoreProxy.shared.register(obsStore)
		let ids = taxStore.search("").map { $0.id }
		// Non-recent bucket first (sorted by commonness ascending): rareOld (0), scarceOld (1)
		// Recent bucket last, older recent before newer recent: commonRecentOlder, commonRecentNewest
		#expect(ids == ["rareOld", "scarceOld", "commonRecentOlder", "commonRecentNewest"])
	}
}
