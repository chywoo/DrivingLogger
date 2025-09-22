import Foundation
import Combine
import MapKit

/// This ViewModel is dedicated solely to the TrackingMapView.
/// It subscribes to the LocationManager and formats the raw data into display-ready strings.
class TrackingViewModel: ObservableObject {
    @Published var currentTimeString: String
    @Published var distanceString: String = "0.00 mi"
    @Published var currentAddressString: String = "Fetching address..."
    @Published var routeForMap: [CLLocationCoordinate2D] = []

    private var locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?

    init() {
        self.currentTimeString = Date().formatted(date: .omitted, time: .standard)
        setupSubscribers()
        startTimer()
    }

    private func setupSubscribers() {
        // Subscribe to distance changes and format it
        locationManager.$totalDistance
            .map { distanceInMeters in
                let distanceInMiles = distanceInMeters / 1609.34
                return String(format: "%.2f mi", distanceInMiles)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.distanceString, on: self)
            .store(in: &cancellables)

        // Pass through address and route data
        locationManager.$currentAddress
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentAddressString, on: self)
            .store(in: &cancellables)

        locationManager.$route
            .receive(on: DispatchQueue.main)
            .assign(to: \.routeForMap, on: self)
            .store(in: &cancellables)
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .map { date in
                date.formatted(date: .omitted, time: .standard)
            }
            .assign(to: \.currentTimeString, on: self)
    }
}
