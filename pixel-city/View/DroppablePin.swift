//
//  DroppablePin.swift
//  pixel-city
//
//  Created by Mac on 10/15/18.
//  Copyright © 2018 CO.KrystynaKruchcovska. All rights reserved.
//

import UIKit
import MapKit
class DroppablePin: NSObject, MKAnnotation{
    public dynamic var coordinate: CLLocationCoordinate2D
    var identifier :String
    init (coordinate: CLLocationCoordinate2D,identifier :String ) {
        self.coordinate = coordinate
        self.identifier = identifier
        super .init()
    }
    
}
