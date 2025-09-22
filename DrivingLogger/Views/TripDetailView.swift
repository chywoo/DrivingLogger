import SwiftUI
import MapKit

struct TripDetailView: View {
    let trip: Trip

    @State private var position: MapCameraPosition

    init(trip: Trip) {
        self.trip = trip
        
            if !trip.route.isEmpty {
            let region = MKCoordinateRegion(coordinates: trip.route)
            self._position = State(initialValue: .region(region))
        } else {
            self._position = State(initialValue: .automatic)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                    Map(position: $position) {
                    MapPolyline(coordinates: trip.route)
                        .stroke(.blue, lineWidth: 5)
                }
                .frame(height: 300)
                .cornerRadius(15)

                VStack(alignment: .leading, spacing: 15) {
                    Text("Trip Details")
                        .font(.title)
                        .fontWeight(.bold)

                    InfoRow(label: "Date", value: trip.startDate.formatted(date: .long, time: .omitted))
                    InfoRow(label: "Time", value: trip.startDate.formatted(date: .omitted, time: .shortened) + " - " + (trip.endDate?.formatted(date: .omitted, time: .shortened) ?? "Now"))
                    
                    InfoRow(label: "Duration", value: trip.formattedDuration)
                    
                    InfoRow(label: "Distance", value: String(format: "%.2f miles", trip.distance / 1609.34))
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Trip on \(trip.startDate.formatted(date: .abbreviated, time: .omitted))")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

extension MKCoordinateRegion {
    init(coordinates: [CLLocationCoordinate2D]) {
        var minLat: CLLocationDegrees = 90.0
        var maxLat: CLLocationDegrees = -90.0
        var minLon: CLLocationDegrees = 180.0
        var maxLon: CLLocationDegrees = -180.0

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4, longitudeDelta: (maxLon - minLon) * 1.4)
        self.init(center: center, span: span)
    }
}

