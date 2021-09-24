//
//  ResumeSession.swift
//  rockmotion
//
//  Created by John A. Cristobal on 8/28/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation
import UIKit

class ResumeSession: NSObject, NSCoding {
    
    var rewards: Int
    var sesiones: Int
    var peso: Double
    var estatura: Int
    var frecuenciabasal: Int
    var esfuerzo: Int
    var calorias: Int
    var frecuencia: Int
    var RookPoints: Double
    
    init(
        rewards: Int,
        sesiones: Int,
        peso: Double,
        estatura: Int,
        frecuenciabasal: Int,
        esfuerzo: Int,
        calorias: Int,
        frecuencia: Int,
        RookPoints: Double) {
        
        self.rewards = rewards
        self.sesiones = sesiones
        self.peso = peso
        self.estatura = estatura
        self.frecuenciabasal = frecuenciabasal
        self.esfuerzo = esfuerzo
        self.calorias = calorias
        self.frecuencia = frecuencia
        self.RookPoints = RookPoints
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(rewards, forKey: "rewards")
        aCoder.encode(sesiones, forKey: "sesiones")
        aCoder.encode(peso, forKey: "peso")
        aCoder.encode(estatura, forKey: "estatura")
        aCoder.encode(frecuenciabasal, forKey: "frecuenciabasal")
        aCoder.encode(esfuerzo, forKey: "esfuerzo")
        aCoder.encode(calorias, forKey: "calorias")
        aCoder.encode(frecuencia, forKey: "frecuencia")
        aCoder.encode(RookPoints, forKey: "RookPoints")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let rewards = aDecoder.decodeInteger(forKey: "rewards")
        let sesiones = aDecoder.decodeInteger(forKey: "sesiones")
        let peso = aDecoder.decodeDouble(forKey: "peso")
        let estatura = aDecoder.decodeInteger(forKey: "estatura")
        let frecuenciabasal = aDecoder.decodeInteger(forKey: "frecuenciabasal")
        let esfuerzo = aDecoder.decodeInteger(forKey: "esfuerzo")
        let calorias = aDecoder.decodeInteger(forKey: "calorias")
        let frecuencia = aDecoder.decodeInteger(forKey: "frecuencia")
        let RookPoints = aDecoder.decodeDouble(forKey: "RookPoints")

        self.init(
            rewards:rewards,
            sesiones: sesiones,
            peso: peso,
            estatura: estatura,
            frecuenciabasal: frecuenciabasal,
            esfuerzo: esfuerzo,
            calorias: calorias,
            frecuencia: frecuencia,
            RookPoints: RookPoints
        )
    }
}
