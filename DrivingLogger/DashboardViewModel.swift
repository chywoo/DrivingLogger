import Foundation
import Combine
import CoreLocation // Import needed for CLAuthorizationStatus

class DashboardViewModel: ObservableObject {
    @Published var isDriving: Bool = false
    
    // ⭐️ We will now also observe the authorization status
    @Published var authorizationStatus: CLAuthorizationStatus

    private var locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Get the initial status
        authorizationStatus = locationManager.authorizationStatus
        
        // Subscribe to changes in the driving state
        locationManager.$isDriving
            .receive(on: DispatchQueue.main)
            .assign(to: \.isDriving, on: self)
            .store(in: &cancellables)
            
        // ⭐️ Subscribe to changes in the authorization status
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .assign(to: \.authorizationStatus, on: self)
            .store(in: &cancellables)
    }

    /// Toggles the driving state by calling the correct public methods on the LocationManager.
    func toggleDrivingState() {
        if isDriving {
            // ⭐️ CORRECTED: Use the public method, not the internal one.
            locationManager.stopDriving()
        } else {
            // ⭐️ CORRECTED: Use the public method, not the internal one.
            locationManager.startDriving()
        }
    }
}

