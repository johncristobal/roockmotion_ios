//
//  Devices.swift
//  rockmotion
//
//  Created by i7 on 9/5/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation

struct Devices {
    var id: Int
    var name: String
    var price: String
    var mac: String
    var brand: String
    var active: Bool
    
    init(
        id:Int,
        name:String,
        price: String,
        mac: String,
        brand: String,
        active: Bool
        ) {
        self.id = id
        self.name = name
        self.price = price
        self.mac = mac
        self.brand = brand
        self.active = active
    }
}
