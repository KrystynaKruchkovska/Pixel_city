//
//  MapVC.swift
//  pixel-city
//
//  Created by Mac on 10/11/18.
//  Copyright © 2018 CO.KrystynaKruchcovska. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import MapKit


class MapVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
    }

 
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    }
    
}
    extension MapVC: MKMapViewDelegate{
    
}

