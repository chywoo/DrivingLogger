import Foundation
import SwiftData
import CoreLocation

@Model
final class Trip {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date
    var distance: Double // 미터 단위로 저장
    
    // CLLocationCoordinate2D 배열은 직접 저장이 안되므로 Data 형태로 변환하여 저장
    private var routeData: Data
    
    init(startDate: Date, endDate: Date, distance: Double, route: [CLLocationCoordinate2D]) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = endDate
        self.distance = distance
        
        // 경로 데이터를 JSON으로 인코딩하여 저장
        let encoder = JSONEncoder()
        self.routeData = (try? encoder.encode(route.map { [$0.latitude, $0.longitude] })) ?? Data()
    }
    
    // 저장된 Data를 다시 경로 배열로 변환하는 계산 프로퍼티
    var route: [CLLocationCoordinate2D] {
        let decoder = JSONDecoder()
        if let decodedRoute = try? decoder.decode([[Double]].self, from: routeData) {
            return decodedRoute.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
        }
        return []
    }
    
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}
