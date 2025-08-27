import SwiftUI

struct HomeView: View {
    @Environment(TaxonomyStore.self) private var taxonomy
    @Environment(ObservationStore.self) private var observations
    @Environment(SettingsStore.self) private var settings
    // Shared range (reserved for future use in Home)
    @Binding var preset: RangePreset
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var filterText: String = ""
    @State private var selectedTaxon: Taxon? = nil
    @State private var bottomControlsHeight: CGFloat = 0
    @State private var sheetContentHeight: CGFloat = 0
    @State private var rangeCounts: [String:Int] = [:]

    private var filtered: [Taxon] { taxonomy.search(filterText, minCommonness: settings.selectedChecklistId != nil ? settings.minCommonness : nil, maxCommonness: settings.selectedChecklistId != nil ? settings.maxCommonness : nil) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let checklistErr = taxonomy.checklistError {
                    Text(checklistErr)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(6)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                }
                Group { content }
                // Bottom controls (FilterBar + Keyboard) measured dynamically for sheet positioning
                VStack(spacing: 0) {
                    Divider()
                    FilterBar(text: filterText) { filterText = "" }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    Divider()
                    OnScreenKeyboard(onKey: { filterText.append($0) }, onBackspace: { if !filterText.isEmpty { _ = filterText.removeLast() } }, onClear: { filterText = "" })
                        .padding(.bottom, 8)
                        .background(.thinMaterial)
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: BottomControlsHeightKey.self, value: geo.size.height)
                    }
                )
                .onPreferenceChange(BottomControlsHeightKey.self) { bottomControlsHeight = $0 }
            }
            
            // Hide the nav bar entirely so it doesn't reserve space at the top
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .onChange(of: settings.selectedChecklistId) { _, newId in
                if let id = newId { taxonomy.loadChecklist(id: id) }
            }
            .task {
                if let id = settings.selectedChecklistId { taxonomy.loadChecklist(id: id) }
            }
            // No range-based recompute here
            // Present CountAdjustSheet as a custom bottom overlay, shifted up by the bottom controls height
            .overlay(alignment: .bottom) {
                if let taxon = selectedTaxon {
                    GeometryReader { geo in
                        ZStack(alignment: .bottom) {
                            Color.black.opacity(0.25)
                                .ignoresSafeArea()
                                .onTapGesture { withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) { selectedTaxon = nil } }

                            VStack(spacing: 0) {
                                CountAdjustSheet(
                                    taxon: taxon,
                                    onDone: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) { selectedTaxon = nil }
                                    },
                                    onCommitted: { didAdd in
                                        if didAdd { filterText = "" }
                                    }
                                )
                                // Measure intrinsic height of the sheet's content
                                .background(
                                    GeometryReader { sheetGeo in
                                        Color.clear
                                            .preference(key: SheetContentHeightKey.self, value: sheetGeo.size.height)
                                    }
                                )
                            }
                            .onPreferenceChange(SheetContentHeightKey.self) { sheetContentHeight = $0 }
                            .frame(maxWidth: .infinity)
                            // Height equals content height
                            .frame(height: max(sheetContentHeight, 1))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(radius: 10)
                            .padding(.horizontal, 12)
                            .padding(.bottom, bottomControlsHeight)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        .ignoresSafeArea()
                    }
                }
            }
            .zIndex(selectedTaxon != nil ? 1 : 0)
        }
    }

    @ViewBuilder private var content: some View {
        if let error = taxonomy.error {
            ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
        } else if !taxonomy.loaded {
            ProgressView("Loading taxonomy…")
                .task { taxonomy.load() }
        } else if taxonomy.species.isEmpty {
            ContentUnavailableView("No Species", systemImage: "bird", description: Text("Taxonomy file empty"))
        } else {
            SpeciesListView(taxa: filtered, counts: rangeCounts) { taxon in
                selectedTaxon = taxon
            }
        }
    }

        // Removed keyboard toggle button
}

// PreferenceKey for measuring bottom controls height dynamically
private struct BottomControlsHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// PreferenceKey for the sheet content height
private struct SheetContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

    

// A simple key that updates when range inputs change
// (removed recomputeKey tuple to avoid Hashable conformance requirement)

private struct FilterBar: View {
    let text: String
    let onClear: () -> Void
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            Text(text.isEmpty ? "Filter species" : text)
                .foregroundStyle(text.isEmpty ? .secondary : .primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            if !text.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear filter text")
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}


#if DEBUG
private extension TaxonomyStore {
    static var previewInstance: TaxonomyStore {
        let store = TaxonomyStore()
        store.loadPreview(species: [
            Taxon(id: "amecro", commonName: "American Crow", scientificName: "Corvus brachyrhynchos", order: 1, rank: "species", commonness: 3),
            Taxon(id: "norbla", commonName: "Northern Blackbird", scientificName: "Inventus fictus", order: 2, rank: "species", commonness: 1),
            Taxon(id: "bkhawk", commonName: "Black Hawk", scientificName: "Buteogallus anthracinus", order: 3, rank: "species", commonness: 0)
        ])
        return store
    }
}
#endif

#if DEBUG
#Preview("Home") {
    HomeView(
        preset: .constant(.today),
        startDate: .constant(Calendar.current.startOfDay(for: Date())),
        endDate: .constant(Date())
    )
        .environment(TaxonomyStore.previewInstance)
        .environment(ObservationStore.previewInstance)
        .environment(SettingsStore())
}
#endif
