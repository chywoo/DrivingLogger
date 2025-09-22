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

import SwiftUI
import SwiftData

// MARK: - Xcode Preview

// 1. 경로 데이터가 있는 완전한 운행 기록 Preview
#Preview("Complete Trip") {
    // Preview를 위한 가짜 Trip 객체 생성
    let sampleTrip = Trip(
        startDate: Date().addingTimeInterval(-3600), // 1시간 전 시작
        endDate: Date().addingTimeInterval(-1820),   // 약 30분 운행
        distance: 8530, // 약 5.3마일 (미터 단위)
        route: [ // Apple Park 주변을 도는 가짜 경로
            CLLocationCoordinate2D(latitude: 37.3348, longitude: -122.0090),
            CLLocationCoordinate2D(latitude: 37.3323, longitude: -122.0113),
            CLLocationCoordinate2D(latitude: 37.3304, longitude: -122.0097),
            CLLocationCoordinate2D(latitude: 37.3328, longitude: -122.0069)
        ]
    )
    
    // Detail View는 보통 NavigationView 안에서 보이므로, 동일한 환경을 구성
    return NavigationView {
        TripDetailView(trip: sampleTrip)
    }
}

// 2. 경로 데이터가 없는 운행 기록 Preview
#Preview("Trip Without Route") {
    let sampleTrip = Trip(
        startDate: Date().addingTimeInterval(-86400), // 어제
        endDate: Date().addingTimeInterval(-86000),
        distance: 1200,
        route: [] // 경로 데이터가 비어있는 경우
    )
    
    return NavigationView {
        TripDetailView(trip: sampleTrip)
    }
}
