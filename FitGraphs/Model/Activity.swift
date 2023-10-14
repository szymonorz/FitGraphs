//
//  Activity.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import Foundation

// MARK: - Activity
struct Activity: Codable {
    let name: String
    let distance: Double?
    let movingTime, elapsedTime, totalElevationGain: Decimal?
    let type, sportType: String?
    let id: Decimal
    let startDate, startDateLocal: String?
    let timezone: String?
    let utcOffset: Int?
    let startLatlng, endLatlng: [Decimal]?
    let locationCountry: String?
    let averageSpeed: Decimal?
    let maxSpeed: Decimal?
    let averageCadence, averageWatts: Decimal?
    let weightedAverageWatts: Decimal?
    let kilojoules: Decimal?
    let deviceWatts, hasHeartrate: Bool?
    let averageHeartrate: Decimal?
    let maxHeartrate, maxWatts: Decimal?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case name
        case distance
        case movingTime = "moving_time"
        case elapsedTime = "elapsed_time"
        case totalElevationGain = "total_elevation_gain"
        case type
        case sportType = "sport_type"
        case id
        case startDate = "start_date"
        case startDateLocal = "start_date_local"
        case timezone
        case utcOffset = "utc_offset"
        case startLatlng = "start_latlng"
        case endLatlng = "end_latlng"
        case locationCountry = "location_country"
        case averageSpeed = "average_speed"
        case maxSpeed = "max_speed"
        case averageCadence = "average_cadence"
        case averageWatts = "average_watts"
        case weightedAverageWatts = "weighted_average_watts"
        case kilojoules
        case deviceWatts = "device_watts"
        case hasHeartrate = "has_heartrate"
        case averageHeartrate = "average_heartrate"
        case maxHeartrate = "max_heartrate"
        case maxWatts = "max_watts"
    }
    
    // When refactoring, let Charlie Gepetto handle this :^)
    static func generateDuckDBSchema() -> String {
        let schema: [String: String] = [
                    "name": "VARCHAR",
                    "distance": "DOUBLE",
                    "moving_time": "DECIMAL",
                    "elapsed_time": "DECIMAL",
                    "total_elevation_gain": "DECIMAL",
                    "type": "VARCHAR",
                    "sport_type": "VARCHAR",
                    "id": "DECIMAL",
                    "start_date": "VARCHAR",
                    "start_date_local": "VARCHAR",
                    "timezone": "VARCHAR",
                    "utc_offset": "INTEGER",
                    "start_latlng": "DECIMAL[]",
                    "end_latlng": "DECIMAL[]",
                    "location_country": "VARCHAR",
                    "average_speed": "DECIMAL",
                    "max_speed": "DECIMAL",
                    "average_cadence": "DECIMAL",
                    "average_watts": "DECIMAL",
                    "weighted_average_watts": "DECIMAL",
                    "kilojoules": "DECIMAL",
                    "device_watts": "BOOLEAN",
                    "has_heartrate": "BOOLEAN",
                    "average_heartrate": "DECIMAL",
                    "max_heartrate": "DECIMAL",
                    "max_watts": "DECIMAL"
                ]
                
        var result = "{"
        for (key, value) in schema {
            result += "'\(key)':'\(value)', "
        }
        
        result = String(result.dropLast(2))
        result += "}"
                
        return result
    }
}
