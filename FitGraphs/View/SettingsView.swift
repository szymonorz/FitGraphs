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
                List {
                    if viewStore.demoModeEnabled {
                        Text("You are in demo mode. Features that require internet connection and online services are disabled.")
                        Button("Exit Demo mode") {
                            viewStore.send(.exitDemo)
                        }
                    }
                    Button("Sign out from FitGraphs", action: {
                        viewStore.send(.logoutTapped)
                    }).frame(width: 193, height: 48)
                        .disabled(viewStore.demoModeEnabled)
                    
                    Button(action: {
                        StravaAuth.shared.oauth.authorize() { authParameters, error in
                            if let params = authParameters {
                                print("Authorized! Access token is in `oauth.accessToken`")
                                print("Authorized! Additional parameters: \(params)")
                                Task {
                                    await viewStore.send(.stravaAuth(.storeAthleteData)).finish()
                                    viewStore.send(.stravaAuth(.authorizedChanged(true)))
                                }
    
                            }
                            else {
                                print("Authorization was canceled or went wrong: \(error!.localizedDescription) \(error)")   // error will not be nil
                                if StravaAuth.shared.oauth.isAuthorizing {
                                    StravaAuth.shared.oauth.forgetTokens()
                                    StravaAuth.shared.oauth.forgetClient()
                                    viewStore.send(.stravaAuth(.authorizedChanged(false)))
                                    UserDefaults.standard.removeObject(forKey: "userId")
                                }
                            }
                        }
                    }) {
                        Image("StravaButton")
                    }.disabled(viewStore.stravaAuth.isAuthorized || viewStore.demoModeEnabled)
                    
         
                    
                    if viewStore.stravaAuth.isAuthorized {
                        Button("Fetch data from Strava", action: {
                            viewStore.send(.fetchFromStrava)
                        })
                        .frame(width: 193, height: 48)
                        .disabled(viewStore.demoModeEnabled)
                        
                        Button("Sign out from Strava", action: {
                            viewStore.send(.stravaAuth(.logout))
                        })
                        .frame(width: 193, height: 48)
                        .disabled(viewStore.demoModeEnabled)
                    }
                    
                }.alert(store: self.store.scope(
                    state: \.$alert,
                    action: { .alert($0) }
                ))
            }
        }
    }
}
