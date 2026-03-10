import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Hoje", systemImage: "sun.max.fill")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("Histórico", systemImage: "calendar")
                }
                .tag(1)

            InsightsView()
                .tabItem {
                    Label("Análise", systemImage: "chart.bar.fill")
                }
                .tag(2)

            PetsView()
                .tabItem {
                    Label("Pets", systemImage: "pawprint.fill")
                }
                .tag(3)
        }
        .tint(Color("AccentPrimary"))
        .accentColor(.init(red: 0.4, green: 0.75, blue: 0.55))
    }
}
