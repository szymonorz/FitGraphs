//
//  ChartContentEntity+CoreDataProperties.swift
//  DataMobileUI
//
//  Created by b on 23/09/2023.
//
//

import Foundation
import CoreData


extension ChartContentEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChartContentEntity> {
        return NSFetchRequest<ChartContentEntity>(entityName: "ChartContentEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var key: String?
    @NSManaged public var val: NSDecimalNumber?
    @NSManaged public var chartItem: ChartItemEntity?

}

extension ChartContentEntity : Identifiable {

}
