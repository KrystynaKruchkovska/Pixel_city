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
import Alamofire
import AlamofireImage


class MapVC: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var hightPullUpConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pullUpView: UIView!
    
    
    @IBOutlet weak var showTableViewBtn: RoundedBtn!
    
    
    let locationManager = CLLocationManager()
    let autherizationStatus = CLLocationManager.authorizationStatus()
    let ragionRadius:Double = 1000
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    
    var flowLayout =  UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var imageInfoArray = [ImageInfo]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocalService()
        longPressRecogniser()
        showTableViewBtn.isHidden = true
        
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

        
        pullUpView.addSubview(collectionView!)
        
        
        registerForPreviewing(with: self, sourceView: collectionView!)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is TableViewVC
        {
            let vc = segue.destination as? TableViewVC
            vc?.imageArray = imageArray
            vc?.imageInfoArray = imageInfoArray
            
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
        cencelAllSessions()
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
        progressLbl?.text = "0/40 PHOTOS LOADED"
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
    
    
    @IBAction func showInTableViewBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "toTableView", sender: nil)
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
        cencelAllSessions()
        
        self.imageArray = []
        self.imageInfoArray = []
        self.collectionView?.reloadData()
        
        
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
        
        print(flickrUrl(forAPIKey: apiKey, withAnnotation: annotation, andNumberofPhotos: NUMBER_OF_PHOTOS))
        retrieveUrls(forAnnotation: annotation) { (finished) in
            if finished{
                self.retrieveImages(handler: { (finished) in
                    if finished{
                        //hide spinner
                        self.removeSpinner()
                        self.removeProgressLbl()
                        //hide lbl
                        self.collectionView?.reloadData()
                        //reload collectionView
                        self.showTableViewBtn.isHidden = false
                        
                        self.getFavorites(handler: { (finished) in
                            
                        })
                    }
                })
                
            }
        }
        
    }
    
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        let requestUrl = flickrUrl(forAPIKey: apiKey, withAnnotation: annotation, andNumberofPhotos: NUMBER_OF_PHOTOS)
        Alamofire.request(requestUrl).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                
                let photoId = photo["id"]
                let photoOwner = photo["ownername"]
                let description = photo["description"]!["_content"]
                let dateTaken = photo["datetaken"]
                let view = photo["views"]
                var imageInfo = ImageInfo()
                imageInfo.favourites = []
                imageInfo.url = postUrl
                imageInfo.ownerName = (photoOwner as! String)
                imageInfo.description = (description as! String)
                imageInfo.dateTaken = dateTaken as! String
                imageInfo.views = (view as! String)
                imageInfo.id = (photoId as! String)
                
                self.imageInfoArray.append(imageInfo)
            }
            
            handler(true)
        }
    }
    

    
    func retrieveImages(handler: @escaping (_ status: Bool)-> ()) {
    
        
        for item in self.imageInfoArray {
            
            Alamofire.request(item.url!).responseImage { (response) in
                guard let image = response.result.value else {
                    return
                }
                
                self.imageArray.append(image)
                
                self.progressLbl?.text = "\(self.imageArray.count)/\(NUMBER_OF_PHOTOS) IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageInfoArray.count{
                    handler(true)
                }
                
            }
        }
        
    }
    
    func  getFavorites(handler: @escaping (_ status: Bool)-> ()){
        
        for i in 0...imageInfoArray.count - 1 {
            var imageInfo = self.imageInfoArray[i]
            
            let favoritesRequest = favoritesUrl(forAPIKey: apiKey, id: imageInfo.id!)
            
            print("getFavourites url:\(favoritesRequest)")
            
            Alamofire.request(favoritesRequest).responseJSON { (response) in
                
                print("getFavourites: statusCode:\(response.response?.statusCode)")
                
                let error = response.result.error
                
                if let e = error {
                    print("getFavourites error:\(e)")
                    return
                }
                
                guard let json = response.result.value as? Dictionary<String, AnyObject> else {
                    return
                }
                
                let photo = json["photo"] as! Dictionary<String, AnyObject>
                let personsArray = photo["person"] as! [Dictionary<String, AnyObject>]
                for person in personsArray{
                    let username = person["username"]
                    imageInfo.favourites!.append(username as! String)
                }
                
                print("Favourites got: \(imageInfo.favourites?.count)")
                
                handler(true)
            }
            
        }
       
    }
    
    func cencelAllSessions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ ($0.cancel()) })
            downloadData.forEach({ ($0.cancel()) })
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
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell ()}
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(withImage: imageArray[indexPath.row], imageInfo: imageInfoArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
    
}


extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else  {return nil}
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return nil}
        popVC.initData(withImage: imageArray[indexPath.row],imageInfo: imageInfoArray[indexPath.row])
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}



