//
//  ContentView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Combine


struct ContentView: View {
    @EnvironmentObject var stravaAuth: StravaAuth
    var body: some View {
        NavigationView {
            ZStack {
                if(stravaAuth.oauth.hasUnexpiredAccessToken()) {
                    HomeView()
                }else {
                    LoginView()
                }
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var dashboard: Dashboard
    var body: some View {
        DashboardView(charts: sample_charts)
    }
}

struct LoginView: View {
    @EnvironmentObject  var stravaAuth: StravaAuth
    var body: some View {
        VStack {
            Button("Log in to Strava", action: stravaAuth.authorize)
        }
    }
}
