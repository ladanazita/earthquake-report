//
//  QuakeLocation+CoreDataProperties.swift
//  Earthquakes
//
//  Created by Ladan  on 5/26/16.
//  Copyright © 2016 LadanAzita. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension QuakeLocation {

    @NSManaged var latitude: NSNumber?
    @NSManaged var depth: NSNumber?
    @NSManaged var location: String?
    @NSManaged var longitude: NSNumber?
    @NSManaged var quake: Quake?
    @NSManaged var quakeWeb: QuakeWeb?

}
