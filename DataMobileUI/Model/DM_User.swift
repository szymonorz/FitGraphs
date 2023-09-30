//
//  User.swift
//  DataMobileUI
//
//  Created by b on 29/09/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct DM_User: Codable {
    @DocumentID var id: String?
    var userId: String
    var activities: [Activity]
}
