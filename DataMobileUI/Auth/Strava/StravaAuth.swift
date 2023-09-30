//
//  StravaAuth.swift
//  DataMobileUI
//
//  Created by b on 17/06/2023.
//

import Foundation
import OAuth2

struct StravaAuth {
    static let shared = StravaAuth()
    var oauth: OAuth2CodeGrant
    
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
    
    func authorize() async {	
        oauth.authorize() { authParameters, error in
            if let params = authParameters {
                print("Authorized! Access token is in `oauth.accessToken`")
                print("Authorized! Additional parameters: \(params)")
            }
            else {
                print("Authorization was canceled or went wrong: \(error!.localizedDescription) \(error)")   // error will not be nil
                if self.oauth.isAuthorizing {
                    self.oauth.forgetTokens()
                }
            }
        }
    }
    
    func logout() async {
        oauth.forgetTokens()
    }
    
}
