//
//  RootView.swift
//  DataMobileUI
//
//  Created by b on 10/09/2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<RootReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ContentView(store: store)
                .onOpenURL(perform: { url in
                    debugPrint(url)
                    guard url.scheme == "datamobileui" else {
                        return
                    }
                    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                        print("Invalid URL")
                        return
                    }
                    guard let action = components.host, action == "callback" else {
                        print("Unknown URL, we can't handle this one!")
                        return
                    }
                    StravaAuth.shared.oauth.handleRedirectURL(url)
                })
        }
        
    }

}
