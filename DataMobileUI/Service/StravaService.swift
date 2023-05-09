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
        "client_id": "my_swift_app",
        "client_secret": "C7447242",
        "authorize_uri": "https://github.com/login/oauth/authorize",
        "token_uri": "https://github.com/login/oauth/access_token",   // code grant only
        "redirect_uris": ["myapp://oauth/callback"],   // register your own "myapp" scheme in Info.plist
        "scope": "user repo:status",
        "secret_in_body": true,    // Github needs this
        "keychain": false,         // if you DON'T want keychain integration
    ] as OAuth2JSON)
}
