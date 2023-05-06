//
//  DataMobileUIApp.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI

@main
struct DataMobileUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Auth())
        }
    }
}
