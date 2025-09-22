import Foundation
import SwiftData

/// This class is the single source of truth for all Trip data.
/// It encapsulates all the logic for interacting with the SwiftData database.
class TripRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveTrip(_ trip: Trip) {
        modelContext.insert(trip)
        do {
            try modelContext.save()
            print("✅ TripRepository: Trip successfully saved!")
        } catch {
            print("🚨 TripRepository: Failed to save trip: \(error.localizedDescription)")
        }
    }

    func fetchAllTrips() -> [Trip] {
        do {
            let descriptor = FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
            return try modelContext.fetch(descriptor)
        } catch {
            print("🚨 TripRepository: Failed to fetch trips: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteTrip(_ trip: Trip) {
        modelContext.delete(trip)
    }
}
