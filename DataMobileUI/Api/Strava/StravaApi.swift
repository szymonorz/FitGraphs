//
//  StravaApi.swift
//  DataMobileUI
//
//  Created by b on 17/06/2023.
//

import Foundation
import Alamofire

class StravaApi: ObservableObject {
    
    static let STRAVA_API_URL: String = "https://www.strava.com/api/v3"
    static let STRAVA_ACTIVITIES_URL: String = STRAVA_API_URL + "/athlete/activities"
    
    var stravaAuth: StravaAuth
    
    init(stravaAuth: StravaAuth) {
        self.stravaAuth = stravaAuth
    }
    
    func getUserActivities(){
        AF.request(StravaApi.STRAVA_ACTIVITIES_URL,
                   interceptor: OAuth2RetryHandler(oauth2: stravaAuth.oauth),
                   requestModifier: {$0.timeoutInterval = 5}).validate().response { response in
            
            let data = response.data
            if let statusCode = response.response?.statusCode, statusCode >= 400 {
                debugPrint("[ERROR] Status: \(statusCode); Error: \(String(decoding: data!, as: UTF8.self))")
                return
            }
            
            
            switch response.result {
            case .success(let value):
                let activities = try! JSONDecoder().decode([Activity].self, from: data!)
                debugPrint(activities)
            case .failure(let error):
                debugPrint("[ERROR]: \(error.localizedDescription)")
            }
        }
    }
}
