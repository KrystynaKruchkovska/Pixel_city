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
    
    var flowLayout =  UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocalService()
        longPressRecogniser()
        
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
        
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
       
        
        
        UIView.animate(withDuration:0.3, animations: {
            self.hightPullUpConstraint.constant = 300
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (UIScreen.main.bounds.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (UIScreen.main.bounds.width/2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
        progressLbl?.text = "12/40 PHOTOS LOADED"
        collectionView?.addSubview(progressLbl!)
    }
    func removeProgressLbl(){
        if progressLbl != nil{
            progressLbl?.removeFromSuperview()
        }
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
        removeSpinner()
        removeProgressLbl()
        
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchMapCoordinate, identifier: "droppablePin")
        
    
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchMapCoordinate, ragionRadius * 2,ragionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
        
        mapView.addAnnotation(annotation)
        
        print(flickrUrl(forAPIKey: apiKey, withAnnotation: annotation, andNumberofPhotos: 40))
        
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

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
        return cell!
    }
    
}


