//
//  FirebaseDataManager.swift
//  DataMobileUI
//
//  Created by b on 25/09/2023.
//

import FirebaseFirestore


class FirebaseDataManager {
    static let db: Firestore = Firestore.firestore()
}

extension FirebaseDataManager {
    enum FirebaseCollections: String {
        case user             = "users"
        case dashboards       = "dashboards"
        case chartItems       = "chartItems"
        case chartItemContets = "chartItemContets"
    }
}
