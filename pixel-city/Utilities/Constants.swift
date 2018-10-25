//
//  Constants.swift
//  pixel-city
//
//  Created by Mac on 10/17/18.
//  Copyright © 2018 CO.KrystynaKruchcovska. All rights reserved.
//

import Foundation
let apiKey = "002bad5b3bc5e17f1dfbe2dce39a4029"
let flickrGetRecentMethod = "flickr.photos.getRecent"
//flickr.photos.search&api_key

func flickrUrl(forAPIKey key:String,withAnnotation anotation:DroppablePin,andNumberofPhotos number:Int ) -> String{
    let url =  "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(anotation.coordinate.latitude)&lon=\(anotation.coordinate.longitude)&radius=1&radius=1&radius_units=mi&extras=owner_name,date_taken,description,views&per_page=\(number)&format=json&nojsoncallback=1"
   

    print(url)
    return url
}

