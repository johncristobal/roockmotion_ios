//
//  Respuesta.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/18/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation

struct Respuesta {
    var resp: String
    var mes:String
    var id: String
    
    init(resp:String,mes:String, id:String) {
        self.resp = resp
        self.mes = mes
        self.id = id
    }
}
