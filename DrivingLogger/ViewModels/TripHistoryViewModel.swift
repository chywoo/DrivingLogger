import Foundation

class TripHistoryViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    
    private let tripRepository: TripRepository
    
    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }
    
    func loadTrips() {
        self.trips = tripRepository.fetchAllTrips()
    }
    
    func deleteTrip(at offsets: IndexSet) {
        offsets.forEach { index in
            let tripToDelete = trips[index]
            tripRepository.deleteTrip(tripToDelete)
        }
        trips.remove(atOffsets: offsets)
    }
}
