//
//  StravaAuth.swift
//  DataMobileUI
//
//  Created by b on 17/06/2023.
//

import Foundation
import OAuth2

class StravaAuth: ObservableObject {
    var oauth: OAuth2CodeGrant
    @Published var isLoggedIn: Bool = false
    
    init() {
        let clientId     = Bundle.main.object(forInfoDictionaryKey:"STRAVA_CLIENT_ID") ?? "2"
        let clientSecret = Bundle.main.object(forInfoDictionaryKey:"STRAVA_CLIENT_SECRET") ?? ""
        
        let settings = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "authorize_uri": "https://www.strava.com/oauth/authorize",
            "token_uri": "https://www.strava.com/oauth/token",
            "redirect_uris": ["datamobileui://callback"],
            "response_type": "code",
            "scope": "activity:read",
            "grant_type": "authorization_code",
            "parameters": [
                "client_id": clientId,
                "client_secret": clientSecret
            ]
        ] as OAuth2JSON
        
        oauth = OAuth2CodeGrant(settings: settings)
    }
    
    func authorize() {
        oauth.authorize() { authParameters, error in
            if let params = authParameters {
                print("Authorized! Access token is in `oauth.accessToken`")
                print("Authorized! Additional parameters: \(params)")
                self.isLoggedIn = true
            }
            else {
                print("Authorization was canceled or went wrong: \(error!.localizedDescription)")   // error will not be nil
                self.isLoggedIn = false
                if self.oauth.isAuthorizing {
                    self.oauth.forgetTokens()
                }
            }
        }
    }
    
    func logout() {
        oauth.forgetTokens()
        oauth.forgetClient()
        self.isLoggedIn = false
    }
    
}
