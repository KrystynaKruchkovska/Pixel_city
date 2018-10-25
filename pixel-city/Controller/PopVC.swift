//
//  PopVC.swift
//  pixel-city
//
//  Created by Mac on 10/18/18.
//  Copyright © 2018 CO.KrystynaKruchcovska. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var popImageView: UIImageView!
    
    
    @IBOutlet weak var descriptionLbl: UILabel!
    
    @IBOutlet weak var ownerName: UILabel!
    var passedImage: UIImage!
    var passedImageInfo: ImageInfo!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        ownerName.text = passedImageInfo.ownerName!
        addDoubleTap()
        // Do any additional setup after loading the view.
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


}
