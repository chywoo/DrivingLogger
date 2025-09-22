import SwiftUI
import MapKit

import Foundation
import CoreLocation

// 1. GPS 데이터 모델 정의
// GPS의 한 지점을 나타내는 구조체
struct GPSData: Codable, Identifiable {
    let id = UUID()
    let latitude: CLLocationDegrees // 위도
    let longitude: CLLocationDegrees // 경도
    let timestamp: Date // 시간
}

// 2. GPS 데이터 생성 클래스
// 가상의 GPS 운행 데이터를 생성하는 기능을 제공합니다.
class GPSDataGenerator {

    // 두 지점 사이의 거리를 계산하는 함수 (하버사인 공식)
    private static func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371e3 // 지구 반지름 (미터)
        let phi1 = lat1.degreesToRadians
        let phi2 = lat2.degreesToRadians
        let deltaPhi = (lat2 - lat1).degreesToRadians
        let deltaLambda = (lon2 - lon1).degreesToRadians

        let a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
                cos(phi1) * cos(phi2) *
                sin(deltaLambda / 2) * sin(deltaLambda / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return R * c
    }

    // 출발점에서 도착점까지 가상 GPS 데이터를 생성하는 함수
    func generateTripData(
        startLocation: CLLocationCoordinate2D,
        endLocation: CLLocationCoordinate2D,
        totalTimeInSeconds: Double
    ) -> [GPSData] {
        var tripData: [GPSData] = []

        let totalDistance = GPSDataGenerator.haversineDistance(
            lat1: startLocation.latitude, lon1: startLocation.longitude,
            lat2: endLocation.latitude, lon2: endLocation.longitude
        )

        // 데이터 생성 간격 (예: 1초마다)
        let interval = 1.0
        let numberOfSteps = Int(totalTimeInSeconds / interval)

        // 각 단계별 이동 거리
        let stepDistance = totalDistance / Double(numberOfSteps)

        for i in 0..<numberOfSteps {
            let ratio = Double(i) / Double(numberOfSteps)

            // 두 지점 사이의 선형 보간 (Linear Interpolation)
            let currentLat = startLocation.latitude + (endLocation.latitude - startLocation.latitude) * ratio
            let currentLon = startLocation.longitude + (endLocation.longitude - startLocation.longitude) * ratio

            let timestamp = Date().addingTimeInterval(TimeInterval(i) * interval)

            let dataPoint = GPSData(
                latitude: currentLat,
                longitude: currentLon,
                timestamp: timestamp
            )

            tripData.append(dataPoint)
        }

        return tripData
    }
}

//// MARK: - Extension for Helper Methods
extension Double {
    var degreesToRadians: Double {
        return self * .pi / 180.0
    }
}

//// 3. 사용 예시
//let generator = GPSDataGenerator()
//
//// 출발 지점 (서울)과 도착 지점 (부산)을 정의
//let seoul = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
//let busan = CLLocationCoordinate2D(latitude: 35.1796, longitude: 129.0756)
//
//// 서울에서 부산까지 2시간(7200초) 동안 이동하는 가상 데이터 생성
//let simulatedTrip = generator.generateTripData(
//    startLocation: seoul,
//    endLocation: busan,
//    totalTimeInSeconds: 7200
//)

// 생성된 데이터의 첫 번째와 마지막 지점 출력
//if let firstPoint = simulatedTrip.first, let lastPoint = simulatedTrip.last {
//    print("생성된 데이터의 총 개수: \(simulatedTrip.count)")
//    print("첫 번째 지점: 위도 \(firstPoint.latitude), 경도 \(firstPoint.longitude), 시간 \(firstPoint.timestamp)")
//    print("마지막 지점: 위도 \(lastPoint.latitude), 경도 \(lastPoint.longitude), 시간 \(lastPoint.timestamp)")
//}


struct MapVisualizer: View {
    // 가상 GPS 데이터를 저장할 상태 변수
    @State private var tripData: [GPSData] = []

    // 지도의 카메라 위치를 제어
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position) {
            // 생성된 GPS 데이터 지점을 지도에 표시
            ForEach(tripData) { point in
                Marker("지점", coordinate: CLLocationCoordinate2D(
                    latitude: point.latitude,
                    longitude: point.longitude
                ))
            }
        }
        .onAppear {
            // 뷰가 나타날 때 가상 GPS 데이터 생성
            let generator = GPSDataGenerator()
            let seoul = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
            let busan = CLLocationCoordinate2D(latitude: 35.1796, longitude: 129.0756)

            tripData = generator.generateTripData(
                startLocation: seoul,
                endLocation: busan,
                totalTimeInSeconds: 720 // 2시간 운행 데이터
            )

            // 생성된 데이터의 첫 번째 지점으로 카메라 이동
            if let startPoint = tripData.first {
                position = .camera(MapCamera(
                    centerCoordinate: CLLocationCoordinate2D(
                        latitude: startPoint.latitude,
                        longitude: startPoint.longitude
                    ),
                    distance: 1000000 // 1000km
                ))
            }
        }
    }
}

#Preview {
    MapVisualizer()
}

