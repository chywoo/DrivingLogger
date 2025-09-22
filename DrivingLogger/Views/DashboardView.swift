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

