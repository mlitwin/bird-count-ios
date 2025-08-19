import SwiftUI

struct ObservationLogView: View {
    @Environment(ObservationStore.self) private var observationsStore
    @Environment(TaxonomyStore.self) private var taxonomy
    // Optional binding: if provided, shows a Close button (when used as a sheet); in Tab usage, omit it
    var show: Binding<Bool>? = nil
    // Shared date range
    @Binding var preset: RangePreset
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var exportSheet: Bool = false

    // Flattened list of records within range, preserving children so ObservationRecordView can compute recursive totals
    private var display: [ObservationRecord] { buildDisplay() }

    private func buildDisplay() -> [ObservationRecord] {
        let (effStart, effEnd) = effectiveRange
        let filtered = observationsStore.observations.filter { $0.end >= effStart && $0.begin <= effEnd }
        // Keep original records (with children) and just sort by begin
        return filtered.sorted { $0.begin < $1.begin }
    }

    private var effectiveRange: (Date, Date) {
        let now = Date()
        switch preset {
        case .today:
            return (Calendar.current.startOfDay(for: now), now)
        case .lastHour:
            let start = Calendar.current.date(byAdding: .hour, value: -1, to: now) ?? now
            return (start, now)
        case .last7Days:
            let start = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
            return (start, now)
        case .all:
            return (.distantPast, now)
        case .custom:
            return (startDate, endDate)
        }
    }

    var body: some View {
        NavigationStack {
            List(display) { rec in
                ObservationRecordView(record: rec)
            }
        
        .toolbar {
                if let show = show {
                    ToolbarItem(placement: .cancellationAction) { Button("Close") { show.wrappedValue = false } }
                }
                ToolbarItem(placement: .primaryAction) { Button("Export") { exportSheet = true }.disabled(display.isEmpty) }
            }
        .sheet(isPresented: $exportSheet) { ShareActivityView(items: [exportText()]) }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private func exportText() -> String {
        var lines: [String] = ["Bird Count Observations"]
        let formatter = ISO8601DateFormatter()
        // Build a quick lookup for species by id once
        let speciesById: [String: Taxon] = Dictionary(uniqueKeysWithValues: taxonomy.species.map { ($0.id, $0) })
        for r in display {
            let taxonName = speciesById[r.taxonId]?.commonName ?? "Unknown"
            if r.begin == r.end {
                lines.append("\(formatter.string(from: r.begin))\t\(taxonName)\t×\(recursiveCount(r))")
            } else {
                lines.append("\(formatter.string(from: r.begin)) – \(formatter.string(from: r.end))\t\(taxonName)\t×\(recursiveCount(r))")
            }
        }
        return lines.joined(separator: "\n")
    }

    // Recursive total helper mirrored from ObservationRecordView for export
    private func recursiveCount(_ r: ObservationRecord) -> Int {
        r.count + r.children.map { recursiveCount($0) }.reduce(0, +)
    }
}

#if DEBUG
#Preview("Sheet style") {
    ObservationLogView(show: .constant(true), preset: .constant(.custom), startDate: .constant(Date().addingTimeInterval(-3600)), endDate: .constant(Date()))
        .environment(ObservationStore())
        .environment(TaxonomyStore())
}
#Preview("Tab style") {
    ObservationLogView(preset: .constant(.custom), startDate: .constant(Date().addingTimeInterval(-3600)), endDate: .constant(Date()))
        .environment(ObservationStore())
        .environment(TaxonomyStore())
}
#endif
