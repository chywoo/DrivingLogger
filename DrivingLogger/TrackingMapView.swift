import SwiftUI
import MapKit

// InformationPanel View (변경 없음)
struct InformationPanel: View {
    @ObservedObject var locationManager: LocationManager
    
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var distanceInMiles: Double {
        return locationManager.totalDistance / 1609.34
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(currentTime, style: .time)
                .font(.system(size: 40, weight: .bold))
                .onReceive(timer) { inputTime in
                    currentTime = inputTime
                }
            
            Divider()
            
            HStack(spacing: 15) {
                VStack(alignment: .leading) {
                    Text("DISTANCE")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.2f mi", distanceInMiles))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading) {
                    Text("CURRENT ADDRESS")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(locationManager.currentAddress)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
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

// TrackingMapView View (변경 없음)
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
                    // 위치를 최종 조정합니다.
                    // 오른쪽 하단 모서리에 기본 패딩을 적용합니다.
                    .padding()
                    // y축으로 화면 높이의 1/4만큼 위로(- offset) 올립니다.
                    .offset(y: -(geometry.size.height / 4))
                }
                
                VStack {
                    InformationPanel(locationManager: locationManager)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleDrivingState()
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}


// MARK: - Xcode Preview

#Preview {
    // ⭐️ 1. 새로운 인스턴스 생성 대신, .shared 싱글톤 인스턴스를 가져옵니다.
    let mockLocationManager = LocationManager.shared
    
    // ⭐️ 2. 가져온 싱글톤 인스턴스에 Preview를 위한 가짜 데이터를 설정합니다.
    mockLocationManager.totalDistance = 12874.8 // Approx 8 miles
    mockLocationManager.currentAddress = "1 Infinite Loop, Cupertino"
    mockLocationManager.route = [
        CLLocationCoordinate2D(latitude: 37.3348, longitude: -122.0090),
        CLLocationCoordinate2D(latitude: 37.3323, longitude: -122.0113)
    ]
    
    // ⭐️ 3. 이제 View에 이 mockLocationManager를 주입합니다.
    return TrackingMapView(viewModel: DashboardViewModel(), locationManager: mockLocationManager)
}

