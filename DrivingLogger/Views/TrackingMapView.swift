import SwiftUI
import MapKit

struct TrackingMapView: View {
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @StateObject var trackingViewModel: TrackingViewModel // This view owns its specific ViewModel
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isTrackingUserLocation: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Map(position: $position) {
                    if !trackingViewModel.routeForMap.isEmpty {
                        MapPolyline(coordinates: trackingViewModel.routeForMap)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    guard isTrackingUserLocation,
                          let userCoordinate = LocationManager.shared.lastLocation?.coordinate else { return }
                    
                    let mapCenterCoordinate = context.camera.centerCoordinate
                    let distance = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
                        .distance(from: CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude))
                    
                    if distance > 10.0 {
                        isTrackingUserLocation = false
                    }
                }
                
                if !isTrackingUserLocation {
                    RecenterButton(position: $position, isTracking: $isTrackingUserLocation)
                        .offset(y: -(geometry.size.height / 4))
                }
                
                VStack {
                    InformationPanel(viewModel: trackingViewModel)
                    Spacer()
                    StopButton(action: dashboardViewModel.toggleDrivingState)
                }
            }
        }
    }
}

// Extracted subviews for clarity and reusability
struct InformationPanel: View {
    @ObservedObject var viewModel: TrackingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.currentTimeString)
                .font(.system(size: 40, weight: .bold))
            Divider()
            HStack(spacing: 15) {
                InfoLabel(title: "DISTANCE", value: viewModel.distanceString)
                InfoLabel(title: "CURRENT ADDRESS", value: viewModel.currentAddressString)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}

struct InfoLabel: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

struct RecenterButton: View {
    @Binding var position: MapCameraPosition
    @Binding var isTracking: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    position = .userLocation(fallback: .automatic)
                    isTracking = true
                }) {
                    Image(systemName: "location.fill")
                        .font(.title)
                        .padding()
                        .background(.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding()
            }
        }
    }
}

struct StopButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Stop Driving")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(15)
                .padding([.horizontal, .bottom])
        }
    }
}

