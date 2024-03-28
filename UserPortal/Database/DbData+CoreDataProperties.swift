//
//  DbData+CoreDataProperties.swift
//  UserPortal
//
//  Created by Dhwani Shah on 21/03/24.
//
//

import Foundation
import CoreData


extension DbData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DbData> {
        return NSFetchRequest<DbData>(entityName: "DbData")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var mobile: String?
    @NSManaged public var gender: Int16
    @NSManaged public var createdAt: String?
    @NSManaged public var updatedAt: String?

}

extension DbData : Identifiable {

}
