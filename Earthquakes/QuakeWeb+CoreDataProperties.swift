//
//  QuakeWeb+CoreDataProperties.swift
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

extension QuakeWeb {

    @NSManaged var link: String?
    @NSManaged var quakeLocation: QuakeLocation?

}
