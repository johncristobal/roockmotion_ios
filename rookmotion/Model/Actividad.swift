//
//  Actividad.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/12/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation

struct Actividad {
    var id: Int
    var training: String
    var label: String
    
    init(
        id:Int,
        training:String,
        label: String
        ) {
        self.id = id
        self.training = training
        self.label = label
    }
}
