//
//  Sesion.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/17/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation
import UIKit

class Sesion : NSObject, NSCoding{
    
    var name: String
    var time: String
    var image: UIImage
    var created_at: String
    var final_at: String
    var duration: Int
    var type_session_id: Int
    var final_user_id: Int
    var type_training_id: Int
    var sensors_id: Int
    var training: String
    var labelTraining: String
    var typeSession:String
    var percentage: Int
    var heartRate: Int
    var calories: Double
    var graficas: [String:Grafica]
    var rewards: [String:Reward]
    
    init(name:String,time:String, image: UIImage,created_at: String, final_at: String, duration: Int, type_session_id: Int, final_user_id: Int, type_training_id: Int, sensors_id: Int, training: String, labelTraining: String, typeSession:String, percentage: Int, heartRate: Int, calories: Double, graficas: [String:Grafica], rewards: [String:Reward]) {

        self.name = name
        self.time = time
        self.image = image
        self.created_at = created_at
        self.final_at = final_at
        self.duration = duration
        self.type_session_id = type_session_id
        self.final_user_id = final_user_id
        self.type_training_id = type_training_id
        self.sensors_id = sensors_id
        self.training = training
        self.labelTraining = labelTraining
        self.typeSession = typeSession
        self.percentage = percentage
        self.heartRate = heartRate
        self.calories = calories
        self.graficas = graficas
        self.rewards = rewards        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(image, forKey: "image")
        aCoder.encode(created_at, forKey: "created_at")
        aCoder.encode(final_at, forKey: "final_at")
        aCoder.encode(duration, forKey: "duration")
        aCoder.encode(type_session_id, forKey: "type_session_id")
        aCoder.encode(final_user_id, forKey: "final_user_id")
        aCoder.encode(type_training_id, forKey: "type_training_id")
        aCoder.encode(sensors_id, forKey: "sensors_id")
        aCoder.encode(training, forKey: "training")
        aCoder.encode(labelTraining, forKey: "labelTraining")
        aCoder.encode(typeSession, forKey: "typeSession")
        aCoder.encode(percentage, forKey: "esfuerzo")
        aCoder.encode(heartRate, forKey: "frecuencia")
        aCoder.encode(calories, forKey: "calorias")
        aCoder.encode(graficas, forKey: "graficas")
        aCoder.encode(rewards, forKey: "rewards")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let time = aDecoder.decodeObject(forKey: "time") as! String
        let image = aDecoder.decodeObject(forKey: "image") as! UIImage
        let created_at = aDecoder.decodeObject(forKey: "created_at") as! String
        let final_at = aDecoder.decodeObject(forKey: "final_at") as! String
        let duration = aDecoder.decodeInteger(forKey: "duration")
        let type_session_id = aDecoder.decodeInteger(forKey: "type_session_id")
        let final_user_id = aDecoder.decodeInteger(forKey: "final_user_id")
        let type_training_id = aDecoder.decodeInteger(forKey: "type_training_id")
        let sensors_id = aDecoder.decodeInteger(forKey: "sensors_id")
        let training = aDecoder.decodeObject(forKey: "training") as! String
        let labelTraining = aDecoder.decodeObject(forKey: "labelTraining") as! String
        let typeSession = aDecoder.decodeObject(forKey: "typeSession") as! String
        let esfuerzo = aDecoder.decodeInteger(forKey: "esfuerzo")
        let frecuencia = aDecoder.decodeInteger(forKey: "frecuencia")
        let calorias = aDecoder.decodeDouble(forKey: "calorias")
        let graficas = aDecoder.decodeObject(forKey: "graficas") as! [String:Grafica]
        let rewards = aDecoder.decodeObject(forKey: "rewards") as! [String:Reward]
        
        self.init(
            name: name,
            time: time,
            image: image,
            created_at: created_at,
            final_at: final_at,
            duration: duration,
            type_session_id: type_session_id,
            final_user_id: final_user_id,
            type_training_id: type_training_id,
            sensors_id: sensors_id,
            training: training,
            labelTraining: labelTraining,
            typeSession: typeSession,
            percentage: esfuerzo,
            heartRate: frecuencia,
            calories: calorias,
            graficas: graficas,
            rewards: rewards
        )
    }
}
