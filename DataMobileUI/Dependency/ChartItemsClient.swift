//
//  ChartItemsClient.swift
//  DataMobileUI
//
//  Created by b on 09/09/2023.
//

import CoreData
import Dependencies

struct ChartItemsClient {
    
    var fetchChartItems: () async -> [ChartItem]
    
    var removeChartItem: (ChartItem) async -> Void
    
    var addChartItem: (ChartItem) async -> Void
    
    var updateChartItem: (ChartItem) async -> Void
}

extension ChartItemsClient: DependencyKey {
    
    static let liveValue = ChartItemsClient(
        fetchChartItems: {
            let viewContext = CoreDataManager.shared.container.viewContext
            let fetchRequest: NSFetchRequest<ChartItemEntity> = ChartItemEntity.fetchRequest()
            
            do {
                let fetchedEntities = try viewContext.fetch(fetchRequest)
                let chartItems = fetchedEntities.map { entity in
                    let contentsEntity = entity.contents?.array as! [ChartContentEntity]
                    let chartItemContets = contentsEntity.map { ce in
                        return ChartItem._ChartContent(
                            id: ce.id!,
                            key: ce.key!,
                            value: ce.val! as Decimal
                        )
                    }
                    return ChartItem(
                        id: entity.id!,
                        name: entity.name!,
                        type: entity.type!,
                        contents: chartItemContets,
                        dimensions: entity.dimensions!.components(separatedBy: ";"),
                        measures: entity.measures!.components(separatedBy: ";"),
                        filters: entity.filters!.components(separatedBy: ";")
                    )
                }
                
                return chartItems
            } catch {
                debugPrint("Encountered an error while fetching.... Reason: \(error.localizedDescription)")
            }
        },
        
        removeChartItem: { chartItem in
            let viewContext = CoreDataManager.shared.container.viewContext
            let fetchRequest: NSFetchRequest<ChartItemEntity> = ChartItemEntity.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "id == %@", chartItem.id as CVarArg)
            
            do {
                let fetchedEntities = try viewContext.fetch(fetchRequest)
                if let entity = fetchedEntities.first {
                    viewContext.delete(entity)
                    try viewContext.save()
                } else {
                    debugPrint("ChartItem of id: \(chartItem.id) not found")
                }
            } catch {
                debugPrint("Couldn't delete chartItem of id : \(chartItem.id). Reason: \(error.localizedDescription)")
            }
        }
        ,
        addChartItem: { chartItem in
            let viewContext = CoreDataManager.shared.container.viewContext
            let entity = ChartItemEntity(context: viewContext)
            
            entity.id = UUID()
            entity.name = chartItem.name
            entity.type = chartItem.type
            entity.dimensions = chartItem.dimensions.joined(separator: ";")
            entity.measures = chartItem.measures.joined(separator: ";")
            entity.filters = chartItem.filters.joined(separator: ";")
            
            for content in chartItem.contents {
                let contentEntity = ChartContentEntity()
                contentEntity.id = UUID()
                contentEntity.key = content.key
                contentEntity.val = content.value as NSDecimalNumber
                
                entity.addToContents(contentEntity)
            }
            
            do {
                viewContext.insert(entity)
                try viewContext.save()
            } catch {
                debugPrint("Couldn't save chartItem. Reason: \(error.localizedDescription)")
            }
        }
        ,
        updateChartItem: {chartItem in
            let viewContext = CoreDataManager.shared.container.viewContext
            let fetchRequest: NSFetchRequest<ChartItemEntity> = ChartItemEntity.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "id == %@", chartItem.id as CVarArg)
            
            do {
                let fetchedEntities = try viewContext.fetch(fetchRequest)
                if let entity = fetchedEntities.first {
                    entity.name = chartItem.name
                    entity.type = chartItem.type
                    entity.dimensions = chartItem.dimensions.joined(separator: ";")
                    entity.measures = chartItem.measures.joined(separator: ";")
                    entity.filters = chartItem.filters.joined(separator: ";")
                    
                    if let chartContents = entity.contents {
                        var chartContentArray = chartContents.array as! [ChartItem._ChartContent]
                        
                        chartContentArray.enumerated().forEach { idx, _ in
                            let ci = chartItem.contents[idx]
                            chartContentArray[idx].key = ci.key
                            chartContentArray[idx].value = ci.value
                        }
                        
                        let chartContentsArrayAsOrderedSet = NSOrderedSet(array: chartContentArray)
                        entity.contents = chartContentsArrayAsOrderedSet
                    }
                    
                    
                    
                    try viewContext.save()
                } else {
                    debugPrint("ChartItem of id: \(chartItem.id) not found")
                }
            } catch {
                debugPrint("Couldn't delete chartItem of id : \(chartItem.id). Reason: \(error.localizedDescription)")
            }
        }
    
    )
}

extension DependencyValues {
    var chartItemsClient: ChartItemsClient {
        get { self[ChartItemsClient.self] }
        set { self[ChartItemsClient.self] = newValue }
    }
}
