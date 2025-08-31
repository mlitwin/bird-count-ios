import SwiftUI
import UIKit

@main
struct BirdCountApp: App {
    init() {
        // Enlarge segmented control text globally
        let seg = UISegmentedControl.appearance()
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        seg.setTitleTextAttributes(attrs, for: .normal)
        seg.setTitleTextAttributes(attrs, for: .selected)
    }
    @State private var taxonomyStore = TaxonomyStore()
    @State private var observationStore = ObservationStore()
    @State private var settingsStore = SettingsStore() // Added settings store

    var body: some Scene {
        WindowGroup {
            TopTabsRoot()
            .environment(taxonomyStore)
            .environment(observationStore)
            .environment(settingsStore) // inject settings
        }
    }
}

private struct TopTabsRoot: View {
    private enum Tab: String, CaseIterable, Identifiable { case home = "Home", summary = "Summary", log = "Log"; var id: String { rawValue } }
    @State private var selection: Tab = .home
    @State private var showSettings: Bool = false
    // Shared date range across screens
    @State private var preset: DateRangePreset = .today
    @State private var startDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date()

    var body: some View {
        VStack(spacing: 0) {
            // Top tab selector with a separated Settings button on the right
            HStack(alignment: .center, spacing: 12) {
                Picker("", selection: $selection) {
                    ForEach(Tab.allCases) { tab in Text(tab.rawValue).font(.headline).tag(tab) }
                }
                .pickerStyle(.segmented)
                .controlSize(.large)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Gap is provided by Spacer; adjust minLength to tweak visual separation
                Spacer(minLength: 24)

                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.headline)
                        .padding(8)
                        .background(Circle().fill(Color(.secondarySystemBackground)))
                }
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Divider()

            // Content
            Group {
                switch selection {
                case .home: HomeView(preset: $preset, startDate: $startDate, endDate: $endDate)
                case .summary: SummaryView(preset: $preset, startDate: $startDate, endDate: $endDate)
                case .log: ObservationLogView(preset: $preset, startDate: $startDate, endDate: $endDate)
                }
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView(show: $showSettings) }
    }
}
