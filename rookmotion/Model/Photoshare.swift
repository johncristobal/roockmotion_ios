//
//  Photoshare.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/10/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation
import UIKit

struct Photoshare {
    var calories: String
    var heart: String
    var esfuerzo: String
    var fecha: String
    var duration: String
    var fotoback: UIImage
    
    init(
        calories:String,
        heart:String,
        esfuerzo: String,
        fecha: String,
        duration: String,
        fotoback: UIImage
        ) {
        self.calories = calories
        self.heart = heart
        self.esfuerzo = esfuerzo
        self.fecha = fecha
        self.duration = duration
        self.fotoback = fotoback
    }
}
