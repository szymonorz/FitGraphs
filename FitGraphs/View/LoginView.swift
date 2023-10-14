//
//  LoginView.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI
import ComposableArchitecture
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    
    @Dependency(\.stravaApi) var stravaApi
    
    let store: StoreOf<GoogleAuthReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                GoogleSignInButton {
                    viewStore.send(GoogleAuthReducer.Action.signIn)
                }
            }
        }
    }
}
