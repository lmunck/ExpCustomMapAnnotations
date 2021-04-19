//
//  FerryAnnotationView.swift
//  ExpCustomMapAnnotations
//
//  Created by Anders Munck on 01/04/2021.
//

import MapKit

class FerryAnnotation: NSObject, MKAnnotation {
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 37.795_316, longitude: -122.393_760)
    
    var title: String? = NSLocalizedString("FERRY_BUILDING_TITLE", comment: "Ferry Building annotation")
}
