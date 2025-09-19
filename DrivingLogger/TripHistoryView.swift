import SwiftUI
import SwiftData

struct TripHistoryView: View {
    // @Query 프로퍼티 래퍼를 사용하여 SwiftData로부터 Trip 데이터를 가져옵니다.
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            List {
                ForEach(trips) { trip in
                    NavigationLink(destination: TripDetailView(trip: trip)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(trip.startDate, style: .date)
                                .font(.headline)
                            HStack {
                                let distanceInKm = trip.distance / 1000.0
                                Text("Distance: \(String(format: "%.1f", distanceInKm)) km")
                                    .foregroundColor(.secondary)
                                Spacer()
                                let duration = trip.duration
                                let hours = Int(duration) / 3600
                                let minutes = (Int(duration) % 3600) / 60
                                Text("Duration: \(hours)h \(minutes)m")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onDelete(perform: deleteTrips)
            }
            .navigationTitle("Trip History")
        }
    }

    func deleteTrips(at offsets: IndexSet) {
        for index in offsets {
            let tripToDelete = trips[index]
            modelContext.delete(tripToDelete)
        }
    }
}

