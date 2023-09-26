//
//  StravaApi.swift
//  DataMobileUI
//
//  Created by b on 17/06/2023.
//

import Foundation
import Alamofire
import Dependencies

struct StravaApi {
    
    static let STRAVA_API_URL: String = "https://www.strava.com/api/v3"
    static let STRAVA_ATHLETE_URL: String = STRAVA_API_URL + "/athlete"
    static let STRAVA_ACTIVITIES_URL: String = STRAVA_ATHLETE_URL + "/activities"
    
    var getUserActivities: () async throws -> [Activity]
    
    var getUserId: () async throws -> String
}

extension StravaApi: DependencyKey {
    static let liveValue: StravaApi = StravaApi(
        getUserActivities: {
            try await withCheckedThrowingContinuation({ continuation in
                AF.request(StravaApi.STRAVA_ACTIVITIES_URL,
                           interceptor: OAuth2RetryHandler(oauth2: StravaAuth.shared.oauth),
                           requestModifier: {$0.timeoutInterval = 5}).validate().responseData { response in
                    
                    let data = response.data
                    if let statusCode = response.response?.statusCode, statusCode >= 400 {
                        debugPrint("[ERROR] Status: \(statusCode); Error: \(String(decoding: data!, as: UTF8.self))")
                        return
                    }
                    
                    switch response.result {
                    case .success(let data):
                        let activities = try! JSONDecoder().decode([Activity].self, from: data)
                        for a in activities {
                            debugPrint(a)
                        }
                        continuation.resume(returning: activities)
                    case .failure(let error):
                        debugPrint("[ERROR]: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                }
            })
        },
        getUserId: {
            try await withCheckedThrowingContinuation({ continuation in
                AF.request(StravaApi.STRAVA_ATHLETE_URL,
                           interceptor: OAuth2RetryHandler(oauth2: StravaAuth.shared.oauth),
                           requestModifier: {$0.timeoutInterval = 5}).validate().responseData { response in
                    let data = response.data
                    if let statusCode = response.response?.statusCode, statusCode >= 400 {
                        debugPrint("[ERROR] Status: \(statusCode); Error: \(String(decoding: data!, as: UTF8.self))")
                        return
                    }
                    
                    switch response.result {
                    case .success(let data):
                        let athlete = try! JSONDecoder().decode(Athlete.self, from: data)
                        continuation.resume(returning: String(athlete.id))
                    case .failure(let error):
                        debugPrint("[ERROR]: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                }
                
            })
        }
    )
}

extension DependencyValues {
    var stravaApi: StravaApi {
        get { self[StravaApi.self] }
        set { self[StravaApi.self] = newValue }
    }
}
