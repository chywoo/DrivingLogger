import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let instance = LocationManager()

    @Published var isDriving: Bool = false
    @Published var lastLocation: CLLocation?
    @Published var route: [CLLocationCoordinate2D] = []
    @Published var totalDistance: CLLocationDistance = 0.0
    @Published var currentAddress: String = "Fetching address..."
    
    // ⭐️ 1. ADD THIS LINE: This new property will publish the permission status.
    @Published var authorizationStatus: CLAuthorizationStatus

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private override init() {
        // ⭐️ 2. INITIALIZE THE NEW PROPERTY
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        setupLocationManager()
    }
    
    static func getInstance() -> LocationManager {
        return LocationManager.instance
    }
    
    // ... (startDriving and stopDriving methods are unchanged) ...
    func startDriving() {
        guard !isDriving else { return }
        route.removeAll()
        totalDistance = 0.0
        isDriving = true
        locationManager.startUpdatingLocation()
        print("Starting trip tracking.")
    }

    func stopDriving() {
        guard isDriving else { return }
        isDriving = false
        locationManager.stopUpdatingLocation()
        print("Stopped trip tracking. Total distance: \(totalDistance) meters")
    }


    // MARK: - CLLocationManagerDelegate Methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // ⭐️ 3. UPDATE THE PUBLISHED PROPERTY whenever the status changes.
        self.authorizationStatus = manager.authorizationStatus
        
        // The rest of the logic remains the same
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            print("Location authorization: When In Use. Requesting Always authorization.")
            manager.requestAlwaysAuthorization()
        case .authorizedAlways:
            print("Location authorization: Always.")
        case .notDetermined:
            print("Location authorization: Not Determined. Requesting When In Use authorization.")
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location authorization: Denied or Restricted.")
        @unknown default:
            break
        }
    }
    
    // ... (The rest of the file is unchanged) ...
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isDriving, let newLocation = locations.last else { return }

        if let lastCoordinate = route.last {
            let previousLocation = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)
            totalDistance += newLocation.distance(from: previousLocation)
        }
        route.append(newLocation.coordinate)
        self.lastLocation = newLocation
        updateAddress(for: newLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
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
            guard let self = self else { return }
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                self.currentAddress = "Address not found"
                return
            }
            guard let placemark = placemarks?.first else {
                self.currentAddress = "No address information"
                return
            }
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

