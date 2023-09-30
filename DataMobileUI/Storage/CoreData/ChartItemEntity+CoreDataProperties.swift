//
//  ChartItemEntity+CoreDataProperties.swift
//  DataMobileUI
//
//  Created by b on 23/09/2023.
//
//

import Foundation
import CoreData


extension ChartItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChartItemEntity> {
        return NSFetchRequest<ChartItemEntity>(entityName: "ChartItemEntity")
    }

    @NSManaged public var dimensions: String?
    @NSManaged public var filters: String?
    @NSManaged public var id: String?
    @NSManaged public var measures: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var contents: NSOrderedSet?

}

// MARK: Generated accessors for contents
extension ChartItemEntity {

    @objc(insertObject:inContentsAtIndex:)
    @NSManaged public func insertIntoContents(_ value: ChartContentEntity, at idx: Int)

    @objc(removeObjectFromContentsAtIndex:)
    @NSManaged public func removeFromContents(at idx: Int)

    @objc(insertContents:atIndexes:)
    @NSManaged public func insertIntoContents(_ values: [ChartContentEntity], at indexes: NSIndexSet)

    @objc(removeContentsAtIndexes:)
    @NSManaged public func removeFromContents(at indexes: NSIndexSet)

    @objc(replaceObjectInContentsAtIndex:withObject:)
    @NSManaged public func replaceContents(at idx: Int, with value: ChartContentEntity)

    @objc(replaceContentsAtIndexes:withContents:)
    @NSManaged public func replaceContents(at indexes: NSIndexSet, with values: [ChartContentEntity])

    @objc(addContentsObject:)
    @NSManaged public func addToContents(_ value: ChartContentEntity)

    @objc(removeContentsObject:)
    @NSManaged public func removeFromContents(_ value: ChartContentEntity)

    @objc(addContents:)
    @NSManaged public func addToContents(_ values: NSOrderedSet)

    @objc(removeContents:)
    @NSManaged public func removeFromContents(_ values: NSOrderedSet)

}

extension ChartItemEntity : Identifiable {

}
