import SwiftUI
import MapKit

struct TripDetailView: View {
    let trip: Trip
    @State private var position: MapCameraPosition

    init(trip: Trip) {
        self.trip = trip
        // 여행 경로에 맞춰 지도의 초기 위치와 범위를 설정합니다.
        if let region = TripDetailView.regionFor(coordinates: trip.route) {
            self._position = State(initialValue: .region(region))
        } else {
            // 경로가 없는 경우 기본 위치로 설정합니다.
            self._position = State(initialValue: .automatic)
        }
    }
    
    var body: some View {
        VStack {
            Map(position: $position) {
                if !trip.route.isEmpty {
                    MapPolyline(coordinates: trip.route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .frame(height: 300)
            
            VStack(alignment: .leading, spacing: 15) {
                Text(trip.startDate, style: .date)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Distance")
                            .font(.headline)
                        let distanceInKm = trip.distance / 1000.0
                        Text("\(String(format: "%.1f", distanceInKm)) km")
                            .font(.title2)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Duration")
                            .font(.headline)
                        let duration = trip.duration
                        let hours = Int(duration) / 3600
                        let minutes = (Int(duration) % 3600) / 60
                        Text("\(hours)h \(minutes)m")
                            .font(.title2)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Trip Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    // 경로 전체가 보이도록 지도 영역을 계산하는 헬퍼 함수
    static func regionFor(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }

        var minLat = coordinates[0].latitude
        var maxLat = minLat
        var minLon = coordinates[0].longitude
        var maxLon = minLon

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        // 경로가 잘 보이도록 약간의 여백(1.4배)을 줍니다.
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4, longitudeDelta: (maxLon - minLon) * 1.4)
        return MKCoordinateRegion(center: center, span: span)
    }
}

