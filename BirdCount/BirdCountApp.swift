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

    // Make navigation bars opaque by default
    let navAppearance = UINavigationBarAppearance()
    navAppearance.configureWithOpaqueBackground()
    UINavigationBar.appearance().standardAppearance = navAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    UINavigationBar.appearance().compactAppearance = navAppearance
    UINavigationBar.appearance().isTranslucent = false

    // Make tab bars opaque so content is inset above them
    let tabAppearance = UITabBarAppearance()
    tabAppearance.configureWithOpaqueBackground()
    UITabBar.appearance().standardAppearance = tabAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    UITabBar.appearance().isTranslucent = false
    }
    @State private var taxonomyStore = TaxonomyStore()
    @State private var observationStore = ObservationStore()
    @State private var settingsStore = SettingsStore() // Added settings store

    var body: some Scene {
        WindowGroup {
            TabsRoot()
            .environment(taxonomyStore)
            .environment(observationStore)
            .environment(settingsStore) // inject settings
        }
    }
}

private struct TabsRoot: View {
    private enum Tab: String, CaseIterable, Identifiable, Hashable { case home = "Home", summary = "Summary", log = "Log"; var id: String { rawValue } }
    @State private var selection: Tab = .home
    @State private var showSettings: Bool = false
    // Shared date range across screens
    @State private var preset: DateRangePreset = .today
    @State private var startDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date()

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                HomeView(preset: $preset, startDate: $startDate, endDate: $endDate)
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .tabItem { Label("Home", systemImage: "house") }
            .tag(Tab.home)

            NavigationStack {
                SummaryView(preset: $preset, startDate: $startDate, endDate: $endDate)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .tabItem { Label("Summary", systemImage: "chart.bar") }
            .tag(Tab.summary)

            NavigationStack {
                ObservationLogView(preset: $preset, startDate: $startDate, endDate: $endDate)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .tabItem { Label("Log", systemImage: "list.bullet") }
            .tag(Tab.log)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .sheet(isPresented: $showSettings) { SettingsView(show: $showSettings) }

    }
}

