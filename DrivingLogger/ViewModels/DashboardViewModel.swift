import Foundation
import Combine
import CoreLocation

/// This ViewModel acts as the central state machine for the application.
/// It coordinates the LocationManager and TripRepository to manage the driving state.
class DashboardViewModel: ObservableObject {
    @Published var isDriving: Bool = false
    @Published var authorizationStatus: CLAuthorizationStatus

    private let tripRepository: TripRepository
    private let locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var tripStartDate: Date?

    // This initializer now accepts the TripRepository dependency.
    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
        self.authorizationStatus = locationManager.authorizationStatus
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .assign(to: \.authorizationStatus, on: self)
            .store(in: &cancellables)
    }

    func toggleDrivingState() {
        isDriving.toggle()
        
        if isDriving {
            // Start Driving
            locationManager.reset()
            tripStartDate = Date()
            locationManager.startUpdatingLocation()
        } else {
            // Stop Driving
            locationManager.stopUpdatingLocation()
            
            guard let startDate = tripStartDate else { return }
            
            let newTrip = Trip(
                startDate: startDate,
                endDate: Date(),
                distance: locationManager.totalDistance,
                route: locationManager.route
            )
            tripRepository.saveTrip(newTrip)
            tripStartDate = nil
        }
    }
}

