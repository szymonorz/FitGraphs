//
//  LoginView.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    let store: StoreOf<StravaAuthReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Button("Log in to Strava", action: {
                    viewStore.send(StravaAuthReducer.Action.authorize)
                })
            }
        }
    }
}
