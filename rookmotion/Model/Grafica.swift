//
//  Grafica.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/3/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation

struct Grafica {
    var id: Int
    var record: String
    var timeChart: String
    var datos: [String:Double]
    var zonas: [String:Int]
    
    init(
        id:Int,
        record:String,
        timeChart: String,
        datos: [String: Double],
        zonas: [String: Int]
    ) {
        self.id = id
        self.record = record
        self.datos = datos
        self.timeChart = timeChart
        self.zonas = zonas
    }
}
