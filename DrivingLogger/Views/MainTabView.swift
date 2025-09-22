import SwiftUI

struct MainTabView: View {
    @ObservedObject var dashboardViewModel: DashboardViewModel
    let tripRepository: TripRepository
    
    var body: some View {
        TabView {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "car.fill")
                }

            TripHistoryView(viewModel: TripHistoryViewModel(tripRepository: tripRepository))
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

