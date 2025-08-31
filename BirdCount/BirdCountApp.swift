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
            // Top bar: centered title with trailing Settings button
            ZStack {
                Text("Bird Count")
                    .font(.title2.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
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

            // Content under top tabs: bottom TabView for Home/Summary/Log
            TabView(selection: $selection) {
                HomeView(preset: $preset, startDate: $startDate, endDate: $endDate)
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(Tab.home)

                SummaryView(preset: $preset, startDate: $startDate, endDate: $endDate)
                    .tabItem { Label("Summary", systemImage: "chart.bar") }
                    .tag(Tab.summary)

                ObservationLogView(preset: $preset, startDate: $startDate, endDate: $endDate)
                    .tabItem { Label("Log", systemImage: "list.bullet") }
                    .tag(Tab.log)
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView(show: $showSettings) }
    }
}
