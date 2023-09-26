//
//  ContentView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct ContentView: View {
    @State private var showAlert: Bool = false
    @State private var alertText: String = ""
    
    let store: StoreOf<RootReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            if viewStore.stravaAuth.isAuthorized {
                HomeView(store: self.store)
            } else {
                LoginView(store: self.store.scope(
                    state: \.stravaAuth,
                    action: RootReducer.Action.stravaAuth
                    )
                )
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
                    viewStore.send(RootReducer.Action.stravaAuth(.logout))
                })
                DashboardView(
                    store: self.store.scope(state: \.dashboard,
                                            action: RootReducer.Action.dashboard)
                    )
            }
        }
    }
}
