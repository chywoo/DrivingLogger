import Foundation
import CoreLocation
import Combine

/// A pure, stateless service that provides location data from the device's hardware.
/// It has no knowledge of application concepts like "driving".
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    @Published var lastLocation: CLLocation?
    @Published var route: [CLLocationCoordinate2D] = []
    @Published var totalDistance: CLLocationDistance = 0.0
    @Published var currentAddress: String = "Fetching address..."
    @Published var authorizationStatus: CLAuthorizationStatus

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        setupLocationManager()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        print("📍 LocationManager: Started updating location.")
    }



    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        print("📍 LocationManager: Stopped updating location.")
    }
    
    func reset() {
        route.removeAll()
        totalDistance = 0.0
        lastLocation = nil
        currentAddress = "Fetching address..."
        print("📍 LocationManager: Data reset.")
    }

    // MARK: - CLLocationManagerDelegate Methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        if let lastCoordinate = route.last {
            let previousLocation = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)
            totalDistance += newLocation.distance(from: previousLocation)
        }
        route.append(newLocation.coordinate)
        self.lastLocation = newLocation
        updateAddress(for: newLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("🚨 LocationManager: Failed to get location: \(error.localizedDescription)")
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    private func updateAddress(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first else { return }
            let address = [
                placemark.subThoroughfare,
                placemark.thoroughfare,
                placemark.locality
            ].compactMap { $0 }.joined(separator: ", ")
            DispatchQueue.main.async {
                self.currentAddress = address.isEmpty ? "Resolving address..." : address
            }
        }
    }
}

