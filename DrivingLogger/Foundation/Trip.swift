import Foundation
import SwiftData
import CoreLocation

@Model
final class Trip {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date?
    var distance: Double // Stored in meters
    var route: [CLLocationCoordinate2D]

    init(id: UUID = UUID(), startDate: Date, endDate: Date? = nil, distance: Double = 0.0, route: [CLLocationCoordinate2D] = []) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.distance = distance
        self.route = route
    }
    
    var duration: TimeInterval? {
        guard let endDate = endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }
    
    var formattedDuration: String {
        guard let duration = duration else { return "In Progress" }
        
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}


extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}

