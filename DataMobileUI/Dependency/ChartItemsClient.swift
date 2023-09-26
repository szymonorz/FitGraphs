//
//  ChartItemsClient.swift
//  DataMobileUI
//
//  Created by b on 09/09/2023.
//

import CoreData
import Dependencies
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ChartItemsClient {
    
    enum ClientError: Error {
        case userIdMissing
    }
    
    var fetchChartItems: () async throws-> [ChartItem]
    
    var removeChartItem: (ChartItem) async throws -> Void
    
    var addChartItem: (ChartItem) async throws -> Void
    
    var updateChartItem: (ChartItem) async throws -> Void
}


extension ChartItemsClient: DependencyKey {
    static let liveValue = ChartItemsClient(
        fetchChartItems: {
            
            guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                debugPrint("userId is missing")
                throw ChartItemsClient.ClientError.userIdMissing
            }
            
            let chartItemsCollection = FirebaseDataManager
                .db
                .collection(FirebaseDataManager.FirebaseCollections.user.rawValue)
                .document(userId)
                .collection(FirebaseDataManager.FirebaseCollections.chartItems.rawValue)
            
            let chartItemsQuerySnapshot = try await chartItemsCollection.getDocuments()
            
            var chartItems: [ChartItem] = chartItemsQuerySnapshot.documents.compactMap { try? $0.data(as: ChartItem.self) }
            
            return chartItems

        },
        
        removeChartItem: { chartItem in
            
            guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                debugPrint("userId is missing")
                throw ChartItemsClient.ClientError.userIdMissing
            }
            
            let chartItemsCollection = FirebaseDataManager
                .db
                .collection(FirebaseDataManager.FirebaseCollections.user.rawValue)
                .document(userId)
                .collection(FirebaseDataManager.FirebaseCollections.chartItems.rawValue)
            
            let chartItemDocument = chartItemsCollection.document(chartItem.id!)
            
            chartItemDocument.delete()
        },
        addChartItem: { chartItem in
            
            guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                debugPrint("userId is missing")
                throw ChartItemsClient.ClientError.userIdMissing
            }
            
            let chartItemsCollection = FirebaseDataManager
                .db
                .collection(FirebaseDataManager.FirebaseCollections.user.rawValue)
                .document(userId)
                .collection(FirebaseDataManager.FirebaseCollections.chartItems.rawValue)
            
            
            try chartItemsCollection.addDocument(from: chartItem)
        },
        updateChartItem: {chartItem in
            
            guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                debugPrint("userId is missing")
                throw ChartItemsClient.ClientError.userIdMissing
            }
            
            let chartItemsCollection = FirebaseDataManager
                .db
                .collection(FirebaseDataManager.FirebaseCollections.user.rawValue)
                .document(userId)
                .collection(FirebaseDataManager.FirebaseCollections.chartItems.rawValue)
            
            let chartItemDocument = chartItemsCollection.document(chartItem.id!)
            
            try chartItemDocument.setData(from: chartItem)
        }
    
    )
}

extension DependencyValues {
    var chartItemsClient: ChartItemsClient {
        get { self[ChartItemsClient.self] }
        set { self[ChartItemsClient.self] = newValue }
    }
}
