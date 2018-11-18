//
//  TableViewVC.swift
//  pixel-city
//
//  Created by Mac on 10/28/18.
//  Copyright © 2018 CO.KrystynaKruchcovska. All rights reserved.
//

import UIKit

class TableViewVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var imageInfoArray = [ImageInfo]()
    var imageArray = [UIImage]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

      
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count 
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ImageCell
        
        let selectedImageInfo = imageInfoArray[indexPath .row]
        
        
        let image = imageArray[indexPath .row]
        
        cell.ownerName.text = selectedImageInfo.ownerName
        
        cell.photo.image = image
        cell.views.text = selectedImageInfo.views
        
        return cell
    }

 
    


}
