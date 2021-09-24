//
//  Equations.swift
//  RookMotion
//
//  Created by John A. Cristobal on 10/30/19.
//  Copyright © 2019 RookMotion. All rights reserved.
//

import Foundation

class Equations {
    var heartRate: Int
    var calories: Float
    var porcent: Int
    
    init() {
        self.heartRate = 0
        self.calories = 0.0
        self.porcent = 0
    }
    
    init(heartRate: Int) {
        self.heartRate = heartRate
        self.calories = 0.0
        self.porcent = 0
    }

    func calculate() {
        self.calories = Float(self.heartRate * 2)
        self.porcent = self.heartRate * 3
    }
    
    func getHeartRate() -> Int{
        return self.heartRate
    }
    
    func getCalories() -> Float {
        return self.calories
    }
    
    func getPorcent() -> Int {
        return self.porcent
    }
}
