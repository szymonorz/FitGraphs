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
    
    let store: StoreOf<LoginReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                Image("Logo")
                    .resizable()
                    .frame(width: 128, height: 128)
                Text("FitGraphs")
                    .frame(width: 256, height: 128)
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .fontWidth(.condensed)
                    .foregroundStyle(.black)
                GoogleSignInButton {
                    viewStore.send(.googleAuth(.signIn))
                }.buttonBorderShape(.capsule)
                    .frame(width: 256)
                    .padding(.top, 50)
                Button {
                    viewStore.send(.demo)
                } label: {
                    Text("Demo mode")
                }.buttonBorderShape(.capsule)
                    .frame(width: 256)
                    .padding(.top, 50)
            }.frame(alignment: .top)
        }
    }
}
