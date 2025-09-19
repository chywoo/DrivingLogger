import SwiftUI
import SwiftData

@main
struct DrivingLoggerApp: App {
    // SwiftData를 사용하기 위한 ModelContainer를 생성합니다.
    let container: ModelContainer
    
    init() {
        do {
            // Trip 모델을 데이터베이스 스키마로 등록합니다.
            container = try ModelContainer(for: Trip.self)
        } catch {
            fatalError("Failed to create ModelContainer for Trip.")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        // 앱의 모든 View에서 데이터베이스에 접근할 수 있도록 ModelContainer를 환경에 주입합니다.
        .modelContainer(container)
    }
}

