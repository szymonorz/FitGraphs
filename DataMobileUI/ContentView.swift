//
//  ContentView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Combine

class Auth: ObservableObject {
    
    let didChange = PassthroughSubject<Auth,Never>()

    let willChange = PassthroughSubject<Auth,Never>()

    @Published var isLoggedIn = false {
        didSet {
            didChange.send(self)
        }
    }

    func login(){
        self.isLoggedIn = true
    }
}

struct ContentView: View {
    @EnvironmentObject var auth: Auth
    
    var body: some View {
//        if( !auth.isLoggedIn ) {
//            LoginView()
//        } else {
            HomeView().environmentObject(Dashboard())
//        }
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
    }
}
