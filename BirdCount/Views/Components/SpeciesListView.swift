import SwiftUI

struct SpeciesListView: View {
    let taxa: [Taxon]
    let counts: [String:Int]
    let onSelect: (Taxon) -> Void

    init(taxa: [Taxon], counts: [String:Int], onSelect: @escaping (Taxon) -> Void) {
        self.taxa = taxa
        self.counts = counts
        self.onSelect = onSelect
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(taxa) { taxon in
                        VStack(spacing: 0) {
                            HStack(alignment: .center, spacing: 12) {
                                SpeciesRowBasic(taxon: taxon)
                                if let c = taxon.commonness {
                                    Text(commonnessLabel(c))
                                        .font(.footnote)
                                        .padding(4)
                                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.15)))
                                }
                                Spacer()
                                let count = counts[taxon.id] ?? 0
                                if count > 0 {
                                    Text("\(count)")
                                        .font(.headline.monospacedDigit())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                                        .overlay(Capsule().stroke(Color.accentColor, lineWidth: 1))
                                        .accessibilityLabel("\(taxon.commonName) count \(count)")
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { onSelect(taxon) }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            Divider()
                        }
                    }
                }
                .frame(minHeight: proxy.size.height, alignment: .bottom)
            }
        }
        .padding(.bottom, 24)
    }
}

private struct SpeciesRowBasic: View {
    let taxon: Taxon
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(taxon.commonName)
                    .font(.title3.weight(.semibold))
                Text(taxon.scientificName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private func commonnessLabel(_ c: Int) -> String {
    switch c { case 0: return "R"; case 1: return "S"; case 2: return "U"; case 3: return "C"; default: return "" }
}
