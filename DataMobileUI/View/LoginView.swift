//
//  LoginView.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    
    @Dependency(\.stravaApi) var stravaApi
    
    let store: StoreOf<StravaAuthReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Button("Log in to Strava", action: {
                    StravaAuth.shared.oauth.authorize() { authParameters, error in
                        if let params = authParameters {
                            print("Authorized! Access token is in `oauth.accessToken`")
                            print("Authorized! Additional parameters: \(params)")
                            Task {
                                await viewStore.send(StravaAuthReducer.Action.storeAthleteData).finish()
                                viewStore.send(StravaAuthReducer.Action.authorizedChanged(true))
                            }
                            
                        }
                        else {
                            print("Authorization was canceled or went wrong: \(error!.localizedDescription) \(error)")   // error will not be nil
                            if StravaAuth.shared.oauth.isAuthorizing {
                                StravaAuth.shared.oauth.forgetTokens()
                                UserDefaults.standard.removeObject(forKey: "userId")
                            }
                        }
                    }
                })
            }
        }
    }
}
