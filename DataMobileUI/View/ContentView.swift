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
    @State var isLoggedIn: Bool = false
    var body: some View {
        NavigationView {
            ZStack {
                if stravaAuth.oauth.hasUnexpiredAccessToken() {
                    HomeView()
                        .environmentObject(StravaApi(stravaAuth: stravaAuth))
                } else {
                    LoginView()
                }
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var dashboard: Dashboard
    @EnvironmentObject var stravaAuth: StravaAuth
    var body: some View {
        VStack(spacing: 0){
            Button("Deauth", action: stravaAuth.logout)
            DashboardView(charts: sample_charts)
        }
    }
}
