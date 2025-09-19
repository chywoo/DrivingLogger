import Foundation
import Combine
import SwiftData
import CoreLocation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var isDriving = false
    @Published var todaySummary: String = "0 km / 0h 0m"
    
    private var locationManager = LocationManager.shared
    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()
    
    private var tripStartDate: Date?

    init() {
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                if status == .notDetermined {
                    self?.locationManager.requestPermission()
                }
            }
            .store(in: &cancellables)
            
        locationManager.$totalDistance
            .map { [weak self] distance -> String in
                let distanceInKm = distance / 1000.0
                let duration = self?.isDriving ?? false ? Date().timeIntervalSince(self?.tripStartDate ?? Date()) : 0
                let hours = Int(duration) / 3600
                let minutes = (Int(duration) % 3600) / 60
                return String(format: "%.1f km / %dh %dm", distanceInKm, hours, minutes)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$todaySummary)
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func toggleDrivingState() {
        isDriving.toggle()
        
        if isDriving {
            startTracking()
        } else {
            stopTracking()
        }
    }
    
    private func startTracking() {
        tripStartDate = Date()
        locationManager.startUpdatingLocation()
    }
    
    private func stopTracking() {
        locationManager.stopUpdatingLocation()
        saveTripData()
    }
    
    private func saveTripData() {
        guard let context = modelContext,
              let startDate = tripStartDate,
              !locationManager.route.isEmpty else { return }

        let newTrip = Trip(
            startDate: startDate,
            endDate: Date(),
            distance: locationManager.totalDistance,
            route: locationManager.route
        )
        
        // SwiftData context에 객체를 삽입합니다.
        context.insert(newTrip)
        
        // 변경사항을 저장합니다. SwiftData는 자동 저장을 지원하지만,
        // 여기서는 운행 종료 시점에 명시적으로 저장합니다.
        do {
            try context.save()
            print("운행 기록이 성공적으로 저장되었습니다.")
        } catch {
            print("운행 기록 저장에 실패했습니다: \(error)")
        }
    }
}

