//
//  PopVC.swift
//  pixel-city
//
//  Created by Mac on 10/18/18.
//  Copyright © 2018 CO.KrystynaKruchcovska. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var infoBtn: UIButton!
    
    @IBOutlet weak var popImageView: UIImageView!
    
    
    @IBOutlet weak var descriptionLbl: UILabel!
    
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var detaTaken: UILabel!
    
    
    
    var passedImage: UIImage!
    var passedImageInfo: ImageInfo!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        ownerName.text = passedImageInfo.ownerName!
        descriptionLbl.text = passedImageInfo.description
        detaTaken.text = passedImageInfo.dateTaken
        addDoubleTap()
        
        self.hideInfo()
    }
    
    func initData(withImage image:UIImage,imageInfo:ImageInfo){
        self.passedImage = image
        self.passedImageInfo = imageInfo
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector (screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func infoBtnWasPressed(_ sender: Any) {
        
        
        //        self.showInfo()
        //
        
        
        if isInfoHidden() {
            self.showInfo()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.hideInfo()
            }
            
        } else {
            self.hideInfo()
        }
    }
    
    func showInfo() {
        self.ownerName.isHidden = false
        self.descriptionLbl.isHidden = false
        self.detaTaken.isHidden = false
    }
    
    func hideInfo() {
        self.ownerName.isHidden = true
        self.descriptionLbl.isHidden = true
        self.detaTaken.isHidden = true
    }
    
    func isInfoHidden()-> Bool {
        return self.ownerName.isHidden      &&
            self.descriptionLbl.isHidden &&
            self.detaTaken.isHidden
    }
    
}
