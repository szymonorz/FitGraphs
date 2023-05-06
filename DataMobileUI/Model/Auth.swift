//
//  Auth.swift
//  DataMobileUI
//
//  Created by b on 06/05/2023.
//

import Foundation
import Combine

class Auth: ObservableObject {
    
    let didChange = PassthroughSubject<Auth,Never>()

    let willChange = PassthroughSubject<Auth,Never>()

    @Published var isLoggedIn = false {
        didSet {
            didChange.send(self)
        }
    }

    func login(){
        self.isLoggedIn = true
    }
}
