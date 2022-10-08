//
//  Trip+CoreDataProperties.swift
//  MapDemo
//
//  Created by Milan on 08/10/22.
//
//

import Foundation
import CoreData


extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var startTime: String?
    @NSManaged public var endTime: String?
    @NSManaged public var kms: String?
    @NSManaged public var startLet: Double
    @NSManaged public var startLong: Double
    @NSManaged public var endLet: Double
    @NSManaged public var endLong: Double

}
