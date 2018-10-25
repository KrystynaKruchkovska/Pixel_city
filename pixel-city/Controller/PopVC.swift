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
    
    var passedImage: UIImage!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        addDoubleTap()
        // Do any additional setup after loading the view.
    }
    
    func initData(withImage image:UIImage){
        self.passedImage = image
        //self.descriptionLbl
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
