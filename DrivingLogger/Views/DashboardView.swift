import SwiftUI
import CoreLocation

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        if viewModel.isDriving {
            // When driving, we create a new instance of the TrackingViewModel
            TrackingMapView(dashboardViewModel: viewModel, trackingViewModel: TrackingViewModel())
        } else {
            StartDrivingView(viewModel: viewModel)
        }
    }
}

// The "Ready to Drive" screen, extracted for clarity.
struct StartDrivingView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ready to Drive?")
                .font(.largeTitle)
                .fontWeight(.bold)

            if viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted {
                VStack {
                    Text("Location Access Denied")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text("To use trip tracking, please enable location services in Settings.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            Button(action: {
                viewModel.toggleDrivingState()
            }) {
                Text("Start Driving")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            .disabled(viewModel.authorizationStatus != .authorizedAlways && viewModel.authorizationStatus != .authorizedWhenInUse)
        }
    }
}


//import SwiftData
import SwiftData // Preview에서 ModelContainer를 사용하기 위해 import


// 1. 기본 상태 (위치 권한 허용) Preview
#Preview("기본 (권한 허용됨)") {
    // 각 Preview는 자신만의 독립적인 의존성을 설정합니다.
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, configurations: config)
    let tripRepository = TripRepository(modelContext: container.mainContext)
    let viewModel = DashboardViewModel(tripRepository: tripRepository)
    
    // 이 Preview를 위한 상태를 설정합니다.
    LocationManager.shared.authorizationStatus = .authorizedAlways
    
    return DashboardView(viewModel: viewModel)
}

// 2. 위치 권한 거부 상태 Preview
#Preview("위치 권한 거부됨") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, configurations: config)
    let tripRepository = TripRepository(modelContext: container.mainContext)
    let viewModel = DashboardViewModel(tripRepository: tripRepository)

    // 이 Preview를 위한 상태를 설정합니다.
    LocationManager.shared.authorizationStatus = .denied
    
    return DashboardView(viewModel: viewModel)
}

