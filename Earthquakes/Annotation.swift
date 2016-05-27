//
//  Annotation.swift
//  Earthquakes
//
//  Created by Ladan  on 5/26/16.
//  Copyright © 2016 LadanAzita. All rights reserved.
//

import MapKit

class Annotation: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        // initialize super class
        super.init()
    }
    

}
