//
//  UserLocations.swift
//  ArtonTap
//
//  Created by user on 2019-02-19.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import MapKit

class UserLocations: NSObject, MKAnnotation {
    
    var title: String?
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        
        self.coordinate = coordinate
        
    }
    

    
    
}
