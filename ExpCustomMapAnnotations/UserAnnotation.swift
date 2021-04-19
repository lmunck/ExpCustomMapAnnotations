//
//  MapUserAnnotation.swift
//  GenerateMapPath
//
//  Created by Anders Munck on 29/03/2021.
//

import Foundation
import MapKit

class UserAnnotation: NSObject, MKAnnotation {
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 37.779_379, longitude: -122.418_433)
    
    // Required if you set the annotation view's `canShowCallout` property to `true`
    //var title: String? = NSLocalizedString("SAN_FRANCISCO_TITLE", comment: "SF annotation")
    
    // This property defined by `MKAnnotation` is not required.
    //var subtitle: String? = NSLocalizedString("SAN_FRANCISCO_SUBTITLE", comment: "SF annotation")
    
    var heading:Double = 0
}
