//
//  Blue.swift
//  rockmotion
//
//  Created by John A. Cristobal on 7/12/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Blue {
    //var manager: CBCentralManager
    var peri: CBPeripheral
    var text: String
    
    init(peri:CBPeripheral, text: String) {
        //self.manager = manager
        self.peri = peri
        self.text = text
    }
}
