//
//  DataTransformer.swift
//  DataMobileUI
//
//  Created by b on 20/06/2023.
//

import Foundation
import Dependencies


struct FirebaseClient {
    var saveToDevice: (Data) -> ()
    var saveToFirebase: (Athlete) async throws -> ()
    var loadFromFirebase: () throws -> Athlete
}

extension FirebaseClient: DependencyKey {
    static let liveValue = FirebaseClient(
        saveToDevice: { data in
            let fileManager = FileManager.default
            if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let dataPth = dir.appendingPathComponent("data")
                
                do {
                    try fileManager.createDirectory(atPath: dataPth.path(), withIntermediateDirectories: true)
                } catch let error as NSError{
                    debugPrint("Failed to create directory at \(dataPth.absoluteString): \(error.localizedDescription)")
                    return
                }
                
                let fileUrl = dataPth.appendingPathComponent("activities.json")
                
                do {
                    debugPrint(data)
                    try data.write(to: fileUrl)
                } catch {
                    debugPrint("Failed to save file: \(error.localizedDescription)")
                }
            }
        },
        saveToFirebase: { user in
            let userId = try FirebaseGoogleAuth.shared.getUserId()
            let userCollection = FirebaseDataManager
                                        .db
                                        .collection(FirebaseDataManager.FirebaseCollections.user.rawValue)
               
            let userRef = userCollection.document(userId)
            try userRef.setData(from: user)
        },
        loadFromFirebase: {
            let userId = try FirebaseGoogleAuth.shared.getUserId()
            
            let docRef = FirebaseDataManager
                                        .db
                                        .collection(FirebaseDataManager.FirebaseCollections.user.rawValue)
                                        .document(userId)
            
            var user: Athlete? = nil
            var error: Error? = nil
            docRef.getDocument(as: Athlete.self) { result in
                switch result {
                case .success(let _user):
                    user = _user
                case .failure(let _error):
                    error = _error
                }
            }
            
            if error != nil {
                throw error!
            }
            
            return user!
        }
    )
}

extension DependencyValues {
    var firebaseClient: FirebaseClient {
        get { self[FirebaseClient.self] }
        set { self[FirebaseClient.self] = newValue }
    }
}
