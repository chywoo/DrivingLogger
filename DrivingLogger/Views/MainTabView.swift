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

import SwiftData // Preview에서 ModelContainer를 사용하기 위해 import

#Preview {
    // --- Preview를 위한 의존성 설정 ---
    
    // 1. 실제 디스크가 아닌 메모리에서만 동작하는 임시 데이터베이스 컨테이너를 생성합니다.
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, configurations: config)
    let context = container.mainContext
    
    // 2. (핵심) Preview에서 "History" 탭이 비어있지 않도록 가짜 운행 기록을 추가합니다.
    let sampleTrip1 = Trip(startDate: Date().addingTimeInterval(-3600), endDate: Date().addingTimeInterval(-1800), distance: 5471.7, route: [])
    let sampleTrip2 = Trip(startDate: Date().addingTimeInterval(-86400), endDate: Date().addingTimeInterval(-85000), distance: 12874.8, route: [])
    context.insert(sampleTrip1)
    context.insert(sampleTrip2)

    // 3. 임시 데이터베이스를 사용하는 TripRepository와 DashboardViewModel을 생성합니다.
    let tripRepository = TripRepository(modelContext: context)
    let dashboardViewModel = DashboardViewModel(tripRepository: tripRepository)

    // --- View 렌더링 ---
    
    // 4. 모든 가짜 의존성이 준비되었으므로, MainTabView를 렌더링합니다.
    return MainTabView(
        dashboardViewModel: dashboardViewModel,
        tripRepository: tripRepository
    )
}

