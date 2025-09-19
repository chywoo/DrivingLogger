import Foundation
import CoreLocation
import Combine

// 위치 정보 관리를 위한 싱글톤 클래스
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastLocation: CLLocation?
    @Published var route: [CLLocationCoordinate2D] = []
    @Published var totalDistance: CLLocationDistance = 0

    private override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true // 백그라운드 위치 업데이트 허용
        locationManager.pausesLocationUpdatesAutomatically = false // 자동으로 멈추지 않도록 설정
        locationManager.activityType = .automotiveNavigation
    }

    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        route.removeAll()
        totalDistance = 0
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegate 메서드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        lastLocation = newLocation
        
        let coordinate = newLocation.coordinate
        
        // 경로에 새로운 좌표 추가 및 거리 계산
        if let lastCoordinate = route.last {
            let lastLocationPoint = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)
            totalDistance += newLocation.distance(from: lastLocationPoint)
        }
        
        route.append(coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 정보를 가져오는데 실패했습니다: \(error.localizedDescription)")
    }
}
