//
//  MapVC.swift
//  pixel-city
//
//  Created by Mac on 10/11/18.
//  Copyright © 2018 CO.KrystynaKruchcovska. All rights reserved.
//

import UIKit

import MapKit
import CoreLocation


class MapVC: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var hightPullUpConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pullUpView: UIView!
    
    
    let locationManager = CLLocationManager()
    let autherizationStatus = CLLocationManager.authorizationStatus()
    let ragionRadius:Double = 1000
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocalService()
        longPressRecogniser()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }
    
    func longPressRecogniser(){
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapVC.dropPin(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    func addSwipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector (animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    @objc func animateViewDown(){
        hightPullUpConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func animateViewUp(){
        //       hightPullUpConstraint.constant = 300
        
        
        UIView.animate(withDuration:0.3, animations: {
            self.hightPullUpConstraint.constant = 300
            self.view.layoutIfNeeded()
        }, completion: nil)
        //        UIView.animate(withDuration: 0.3) {
        //            self.view.layoutIfNeeded()
        //        }
        
        
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        
        if autherizationStatus == .authorizedAlways || autherizationStatus == .authorizedWhenInUse{
            centerOnMapUserLocation()
        }
    }
    
}
extension MapVC: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
        
    }
    
    func centerOnMapUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, ragionRadius * 2,ragionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    @objc func dropPin(_ gestureRecognizer : UIGestureRecognizer){
        
        if gestureRecognizer.state != .began { return }
        
        removePin()
        animateViewUp()
        addSwipe()
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchMapCoordinate, identifier: "droppablePin")
        
    
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchMapCoordinate, ragionRadius * 2,ragionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
        
        mapView.addAnnotation(annotation)
        
    }
    
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    
    
}
extension MapVC: CLLocationManagerDelegate {
    
    func configureLocalService(){
        if autherizationStatus == .notDetermined{
            self.locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerOnMapUserLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerOnMapUserLocation()
    }
    
}


