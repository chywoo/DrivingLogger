import SwiftUI
import CoreLocation // Import needed for CLAuthorizationStatus check

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        // If the user is currently driving, show the map view
        if viewModel.isDriving {
            TrackingMapView(viewModel: viewModel)
        } else {
            // Otherwise, show the start screen
            VStack(spacing: 20) {
                Spacer()
                
                Text("Ready to Drive?")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // ⭐️ Show a warning if location permissions are denied
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
                
                Spacer()

                Button(action: {
                    viewModel.toggleDrivingState()
                }) {
                    Image(systemName: "play.fill")
                        .font(.title3)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .padding(.horizontal)
                // ⭐️ Disable the button if permissions are not granted
                .disabled(viewModel.authorizationStatus != .authorizedAlways && viewModel.authorizationStatus != .authorizedWhenInUse)
            }
        }
    }
}

#Preview {
    DashboardView()
}

