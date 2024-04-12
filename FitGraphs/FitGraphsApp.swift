//
//  DataMobileUIApp.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct FitGraphsApp: App {
    let store: StoreOf<RootReducer>
    
    init(){
        self.store = Store(initialState: RootReducer.State()){
            RootReducer()
        }
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup{
            RootView(store: self.store)
        }
    }
}
