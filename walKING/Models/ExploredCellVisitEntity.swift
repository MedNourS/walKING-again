// ExploredCellVisitEntity.swift
// Auto-generated NSManagedObject subclass for CoreData

import Foundation
import CoreData

@objc(ExploredCellVisitEntity)
public class ExploredCellVisitEntity: NSManagedObject {
    @NSManaged public var x: Int32
    @NSManaged public var y: Int32
    @NSManaged public var timestamp: Date?
}

extension ExploredCellVisitEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExploredCellVisitEntity> {
        return NSFetchRequest<ExploredCellVisitEntity>(entityName: "ExploredCellVisitEntity")
    }
}
