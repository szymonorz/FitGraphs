//
//  DataTransformer.swift
//  DataMobileUI
//
//  Created by b on 20/06/2023.
//

import Foundation
import Dependencies


struct ActivitiesClient {
    var saveToDevice: (Data) -> ()
    var saveToFirebase: (DM_User) async throws -> ()
    var loadFromFirebase: () throws -> (DM_User)
}

extension ActivitiesClient: DependencyKey {
    static let liveValue = ActivitiesClient(
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
            let userId = try await FirebaseGoogleAuth.shared.getUserId()
            let userCollection = FirebaseDataManager
                                        .db
                                        .collection(FirebaseDataManager.FirebaseCollections.user.rawValue)
               
            let userRef = userCollection.document(userId)
            try userRef.setData(from: user)
        },
        loadFromFirebase: {
            guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                debugPrint("userId is missing")
                throw ChartItemsClient.ClientError.userIdMissing
            }
            
            let docRef = FirebaseDataManager
                                        .db
                                        .collection(FirebaseDataManager.FirebaseCollections.user.rawValue)
                                        .document(userId)
            
            var user: DM_User? = nil
            var error: Error? = nil
            docRef.getDocument(as: DM_User.self) { result in
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
    var activitiesClient: ActivitiesClient {
        get { self[ActivitiesClient.self] }
        set { self[ActivitiesClient.self] = newValue }
    }
}
