//
//  StravaApi.swift
//  DataMobileUI
//
//  Created by b on 17/06/2023.
//

import Foundation
import Alamofire

class StravaApi: ObservableObject {
    
    static let STRAVA_API_URL: String = "https://www.strava.com"
    static let STRAVA_ACTIVITIES_URL: String = STRAVA_API_URL + "/activites"
    
    var stravaAuth: StravaAuth
    
    init(stravaAuth: StravaAuth) {
        self.stravaAuth = stravaAuth
    }
    
    func getUserActivities(){
        AF.request(StravaApi.STRAVA_ACTIVITIES_URL,
                   interceptor: OAuth2RetryHandler(oauth2: stravaAuth.oauth),
                   requestModifier: {$0.timeoutInterval = 5}).validate().response { response in
            debugPrint(response)
        }
    }
}
