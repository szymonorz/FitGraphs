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
    let distance: Decimal?
    let movingTime, elapsedTime, totalElevationGain: Decimal?
    let type, sportType: String?
    let id: Int
    let startDate, startDateLocal: String?
    let timezone: String?
    let utcOffset: Int?
    let startLatlng, endLatlng: [Decimal]?
    let locationCountry: String?
    let achievementCount, kudosCount, commentCount, athleteCount: Int?
    let photoCount: Int?
    let trainer, commute, manual, activityPrivate: Bool?
    let flagged, fromAcceptedTag: Bool?
    let averageSpeed: Decimal?
    let maxSpeed: Decimal?
    let averageCadence, averageWatts: Decimal?
    let weightedAverageWatts: Decimal?
    let kilojoules: Decimal?
    let deviceWatts, hasHeartrate: Bool?
    let averageHeartrate: Decimal?
    let maxHeartrate, maxWatts: Decimal?
    let prCount, totalPhotoCount: Int?
    let hasKudoed: Bool?
    let sufferScore: Int?

    enum CodingKeys: String, CodingKey {
        case name, distance
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
        case achievementCount = "achievement_count"
        case kudosCount = "kudos_count"
        case commentCount = "comment_count"
        case athleteCount = "athlete_count"
        case photoCount = "photo_count"
        case trainer, commute, manual
        case activityPrivate = "private"
        case flagged
        case fromAcceptedTag = "from_accepted_tag"
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
        case prCount = "pr_count"
        case totalPhotoCount = "total_photo_count"
        case hasKudoed = "has_kudoed"
        case sufferScore = "suffer_score"
    }
}
