//
//  DataMobileUIApp.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI

@main
struct DataMobileUIApp: App {
    @StateObject var stravaAuth: StravaAuth = StravaAuth()
    
    var body: some Scene {
        WindowGroup {
            if(stravaAuth.oauth.hasUnexpiredAccessToken()) {
                ContentView()
                    .environmentObject(stravaAuth)
            } else {
                LoginView()
                    .environmentObject(stravaAuth)
                    .onOpenURL(perform: { url in
                        debugPrint(url)
                        guard url.scheme == "datamobileui" else {
                            return
                        }
                        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                            print("Invalid URL")
                            return
                        }
                        guard let action = components.host, action == "callback" else {
                            print("Unknown URL, we can't handle this one!")
                            return
                        }
                        stravaAuth.oauth.handleRedirectURL(url)
                        
                    })
            }
        }
    }
}
