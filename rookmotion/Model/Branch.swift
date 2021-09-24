//
//  Branch.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/9/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation
import UIKit

class Branch: NSObject, NSCoding {
    
    var id: String
    var name: String
    var descriptionB: String
    var address: String
    var longitude: Double
    var latitude: Double
    var distance: String
    var images: [String]
    var link: Int
    
    init(id:String, name:String,description:String, address:String, distance: String, longitude: Double, latitude: Double,images:[String], link: Int) {
        
        self.id = id
        self.name = name
        self.descriptionB = description
        self.address = address
        self.distance = distance
        self.longitude = longitude
        self.latitude = latitude
        self.images = images
        self.link = link
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(descriptionB, forKey: "description")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(distance, forKey: "distance")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(images, forKey: "images")
        aCoder.encode(link, forKey: "link")
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let description = aDecoder.decodeObject(forKey: "description") as! String
        let address = aDecoder.decodeObject(forKey: "address") as! String
        let distance = aDecoder.decodeObject(forKey: "distance") as! String
        let longitude = aDecoder.decodeDouble(forKey: "longitude")
        let latitude = aDecoder.decodeDouble(forKey: "latitude")
        let images = aDecoder.decodeObject(forKey: "images") as! [String]
        let link = aDecoder.decodeInteger(forKey: "link")
        
        self.init(
            id:id,
            name: name,
            description: description,
            address: address,
            distance: distance,
            longitude: longitude,
            latitude: latitude,
            images: images,
            link: link
        )
    }
}
