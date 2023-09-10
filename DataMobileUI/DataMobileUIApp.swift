//
//  DataMobileUIApp.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct DataMobileUIApp: App {
    let store: StoreOf<RootReducer>
    
    init(){
        self.store = Store(initialState: RootReducer.State()){
            RootReducer()
        }
    }
    
    var body: some Scene {
        WindowGroup{
            RootView(store: self.store)
        }
    }
}
