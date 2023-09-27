//
//  FirebaseGoogleAuth.swift
//  DataMobileUI
//
//  Created by b on 27/09/2023.
//

import FirebaseCore
import FirebaseAuth
import GoogleSignIn

// Need it only to be initialized once
// Probably shouldn't be a seperate class but who cares this is Apple
struct FirebaseGoogleAuth {
    static let shared = FirebaseGoogleAuth()
    init() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
    }
    
    func signInWithGoogle() async -> Bool {
        await withCheckedContinuation({ continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: self.topViewController()!) { result, error in
                guard error == nil else {
                    continuation.resume(returning: false)
                    return
                }
                
                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else {
                    continuation.resume(returning: false)
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)
                
                 Auth.auth().signIn(with: credential) { res, error in
                    guard error == nil else {
                        continuation.resume(returning: false)
                        return
                    }
                    
                    guard let user = res?.user else {
                        continuation.resume(returning: false)
                        return
                    }
                     
                     debugPrint(user.uid)
                     continuation.resume(returning: true)
                }
            }
        })
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    private func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}
