//
//  ContentView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Combine


struct ContentView: View {
    @EnvironmentObject var auth: Auth
    
    var body: some View {
        LoginView().environmentObject(Auth())
    }
}

struct HomeView: View {
    @EnvironmentObject var dashboard: Dashboard
    var body: some View {
        DashboardView(charts: sample_charts)
    }
}

struct LoginView: View {
    @EnvironmentObject  var  auth: Auth
    var body: some View {
        VStack {
            Button("Log in to Strava", action: auth.login)
        }

        if(auth.isLoggedIn){
            HomeView()
                .transition(.slide)
                .environmentObject(Dashboard())
        }
    }
}
