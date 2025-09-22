import SwiftUI
import SwiftData

@main
struct DrivingLoggerApp: App {
    // 1. 최종적으로 저장될 인스턴스 프로퍼티들을 선언합니다.
    let container: ModelContainer
    let tripRepository: TripRepository
    
    @StateObject var dashboardViewModel: DashboardViewModel

    init() {
        do {
            // 2. 모든 의존성을 인스턴스 프로퍼티가 아닌 '로컬 변수'로 먼저 생성합니다.
            let localContainer = try ModelContainer(for: Trip.self)
            let modelContext = localContainer.mainContext
            let localTripRepository = TripRepository(modelContext: modelContext)
            
            // 3. '로컬 변수'를 사용하여 @StateObject를 초기화합니다.
            //    이 시점에서는 self를 참조하지 않으므로 안전합니다.
            _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel(tripRepository: localTripRepository))
            
            // 4. 마지막으로, 생성된 로컬 변수들을 인스턴스 프로퍼티에 할당합니다.
            self.container = localContainer
            self.tripRepository = localTripRepository
            
        } catch {
            fatalError("Failed to create ModelContainer for Trip.")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(dashboardViewModel: dashboardViewModel, tripRepository: tripRepository)
        }
        // 이 부분은 container를 사용해야 합니다.
        .modelContainer(container)
    }
}

