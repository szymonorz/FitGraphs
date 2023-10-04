//
//  SettingsView.swift
//  DataMobileUI
//
//  Created by b on 04/10/2023.
//

import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: StoreOf<SettingsReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                Button("Deauth", action: {
                    viewStore.send(.logoutTapped)
                })
                if viewStore.stravaAuth.isAuthorized {
                    Button("Fetch data from Strava", action: {
                        viewStore.send(.fetchFromStrava)
                    })
                } else {
                    Button("Log in to Strava", action: {
                        viewStore.send(.stravaAuth(.authorize))
                    })
                }
            }.alert(store: self.store.scope(
                state: \.$alert,
                action: { .alert($0) }
            ))
        }
    }
}
