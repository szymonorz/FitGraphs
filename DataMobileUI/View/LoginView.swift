//
//  LoginView.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject  var stravaAuth: StravaAuth
    var body: some View {
        VStack {
            Button("Log in to Strava", action: stravaAuth.authorize)
        }
    }
}
