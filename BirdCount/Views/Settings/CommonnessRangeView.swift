import SwiftUI

struct CommonnessRangeView: View {
    @Binding var minCommonness: Int
    @Binding var maxCommonness: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text("Show species with commonness between:")
            HStack {
                Stepper(value: $minCommonness, in: 0...3) { Text("Min: \(minCommonness)") }
                Stepper(value: $maxCommonness, in: 0...3) { Text("Max: \(maxCommonness)") }
            }
            CommonnessLegend()
        }
    }
}

private struct CommonnessLegend: View {
    var body: some View {
        HStack(spacing: 8) {
            legendItem(code: "R", label: "Rare")
            legendItem(code: "S", label: "Scarce")
            legendItem(code: "U", label: "Uncommon")
            legendItem(code: "C", label: "Common")
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    private func legendItem(code: String, label: String) -> some View { HStack(spacing: 2) { Text(code).bold(); Text(label) } }
}
