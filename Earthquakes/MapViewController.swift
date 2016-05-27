//
//  MapViewController.swift
//  Earthquakes
//
//  Created by Ladan  on 5/26/16.
//  Copyright © 2016 LadanAzita. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    
    var quakeLocation: QuakeLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let quakeLoc = quakeLocation,
        let latitude = quakeLoc.latitude?.doubleValue,
        let longitude = quakeLoc.longitude?.doubleValue,
        let quakeTitle = quakeLoc.location,
        let quakeDepth = quakeLoc.depth {
            
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegionMakeWithDistance(center, 10000000, 1000000)
            mapView.region = region
            
            let annotation = Annotation(coordinate: center)
            annotation.title = quakeTitle
            annotation.subtitle = quakeDepth.stringValue
            // adds annotation to map view
            mapView.addAnnotation(annotation)
            
        }
    }
    
    let pinId: String = "com.ladanazita.pin"
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
                                                                                // downcast
        var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(pinId) as? MKPinAnnotationView
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
        }
        
        pin?.animatesDrop = true
        pin?.pinTintColor = UIColor.darkGrayColor()
        pin?.enabled = true
        pin?.canShowCallout = true
        
        let button = UIButton(type: UIButtonType.DetailDisclosure)
        pin?.rightCalloutAccessoryView = button
        
        return pin
    }
    // this executes the info icon within the annotation box
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let urlString = quakeLocation?.quakeWeb?.link, let url = NSURL(string: urlString) else { return }
        
        let vc = SFSafariViewController(URL: url)
        
        showViewController(vc, sender: nil)

    }
    
}
