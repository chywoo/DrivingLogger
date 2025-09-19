import SwiftUI
import MapKit

struct TrackingMapView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var locationManager: LocationManager
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isTrackingUserLocation: Bool = true
    
    init(viewModel: DashboardViewModel, locationManager: LocationManager = LocationManager.shared) {
        self.viewModel = viewModel
        self.locationManager = locationManager
    }

    var body: some View {
        // ⭐️ 1. GeometryReader로 전체 뷰를 감싸서 화면 크기를 얻습니다.
        GeometryReader { geometry in
            ZStack {
                Map(position: $position) {
                    if !locationManager.route.isEmpty {
                        MapPolyline(coordinates: locationManager.route)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    guard isTrackingUserLocation, let userCoordinate = locationManager.lastLocation?.coordinate else { return }
                    let mapCenterCoordinate = context.camera.centerCoordinate
                    let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
                    let mapCenterLocation = CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude)
                    let distance = userLocation.distance(from: mapCenterLocation)
                    if distance > 10.0 {
                        isTrackingUserLocation = false
                    }
                }
                
                // ⭐️ 2. '현재 위치로' 버튼을 ZStack의 오른쪽 하단에 배치하기 위한 컨테이너입니다.
                if !isTrackingUserLocation {
                    // ZStack을 사용하여 .bottomTrailing 정렬을 적용합니다.
                    ZStack(alignment: .bottomTrailing) {
                        // 이 투명한 뷰는 ZStack이 전체 공간을 차지하도록 보장합니다.
                        Color.clear

                        Button(action: {
                            position = .userLocation(fallback: .automatic)
                            isTrackingUserLocation = true
                        }) {
                            Image(systemName: "location.fill")
                                .font(.title3)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .clipShape(Ellipse())
                                .shadow(radius: 5)
                        }
                        // ⭐️ 3. 위치를 최종 조정합니다.
                        // 오른쪽 하단 모서리에 기본 패딩을 적용합니다.
                        .padding()
                        // y축으로 화면 높이의 1/4만큼 위로(- offset) 올립니다.
                        .offset(y: -(geometry.size.height / 4))
                    }
                }
                
                // --- 기존의 상단 텍스트 및 하단 'Stop' 버튼 ---
                VStack {
                    Text("Tracking in Progress")
                        .font(.largeTitle)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .padding(.top)

                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleDrivingState()
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                            .padding()
                            .foregroundColor(Color.white.opacity(0.8))
                            .background(Color.red.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}


#Preview {
        // 1. Create a dummy location manager that pretends the user is at
        //    some coordinates and has a short route.
        let mockLocationManager = LocationManager.shared
        mockLocationManager.lastLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // SF
        mockLocationManager.route = [
            CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4183),
            CLLocationCoordinate2D(latitude: 37.7765, longitude: -122.4170)
        ]

        return TrackingMapView(viewModel: DashboardViewModel())
            .environmentObject(mockLocationManager)   // If your view uses @EnvironmentObject
}
