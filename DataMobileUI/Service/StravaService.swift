//
//  StravaService.swift
//  DataMobileUI
//
//  Created by b on 10/05/2023.
//

import Foundation
import Alamofire
import p2_OAuth2

class StravaService {
    let base = URL(string: "https://strava.com/api/v3")
    
    let oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "changeme",
        "client_secret": "changeme",
        "authorize_uri": "https://www.strava.com/oauth/authorize",
        "token_uri": "https://www.strava.com/oauth/token",   // code grant only
        "redirect_uris": ["datamobileui://oauth/callback"],   // register your own "myapp" scheme in Info.plist
        "scope": "read,activity:read,profile:read_all",
        "keychain": false,         // if you DON'T want keychain integration
    ] as OAuth2JSON)
}
