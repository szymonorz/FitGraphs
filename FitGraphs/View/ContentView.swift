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
            Image("StravaLogo")
            if viewStore.login.googleAuth.isAuthorized || viewStore.demoModeEnabled {
                MainView(store: self.store)
            } else {
                LoginView(store: self.store.scope(
                    state: \.login,
                    action: RootReducer.Action.login
                    )
                ).onAppear {
                    if Auth.auth().currentUser != nil {
                        viewStore.send(RootReducer.Action.login(.googleAuth(.authorized(true))))
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
            DashboardListView(store: self.store.scope(state: \.dashboardList, action: RootReducer.Action.dashboardList))
                .tabItem {
                    Label("Dashboards", systemImage: "list.bullet.rectangle.fill")
                }
            SettingsView(store: self.store.scope(state: \.settings, action: RootReducer.Action.settings))
                .tabItem {
                    Label("Settings", systemImage: "gear.circle.fill")
                }
        }
    }
}

