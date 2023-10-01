//
//  ContentView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Combine
import ComposableArchitecture
import FirebaseAuth

struct ContentView: View {
    @State private var showAlert: Bool = false
    @State private var alertText: String = ""
    
    let store: StoreOf<RootReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            if viewStore.googleAuth.isAuthorized {
                MainView(store: self.store)
            } else {
                LoginView(store: self.store.scope(
                    state: \.googleAuth,
                    action: RootReducer.Action.googleAuth
                    )
                ).onAppear {
                    if Auth.auth().currentUser != nil {
                        viewStore.send(RootReducer.Action.googleAuth(.authorized(true)))
                    }
                }
            }
        }
    }
}

struct MainView: View {
    let store: StoreOf<RootReducer>
    
    var body: some View {
        TabView {
            HomeView(store: self.store)
                .tabItem {
                    Label("Home", systemImage: "house.circle.fill")
                }
            Text("DashboardList")
                .tabItem {
                    Label("Dashboards", systemImage: "list.bullet.rectangle.fill")
                }
            Text("User settings")
                .tabItem {
                    Label("Settings", systemImage: "gear.circle.fill")
                }
        }
    }
}

struct HomeView: View {
    let store: StoreOf<RootReducer>
    
    var body: some View {
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                Button("Deauth", action: {
                    viewStore.send(RootReducer.Action.googleAuth(.signOut))
                })
                if viewStore.stravaAuth.isAuthorized {
                    Button("Fetch data from Strava", action: {
                        viewStore.send(RootReducer.Action.dashboard(.fetchFromStrava))
                    })
                } else {
                    Button("Log in to Strava", action: {
                        viewStore.send(RootReducer.Action.stravaAuth(.authorize))
                    })
                }

                DashboardView(
                    store: self.store.scope(state: \.dashboard,
                                            action: RootReducer.Action.dashboard)
                    )
            }
        }
    }
}
