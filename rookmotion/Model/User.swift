//
//  User.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/14/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation
import UIKit

class User: NSObject, NSCoding {
    
    var id: Int
    var name: String
    var fullname:String
    var email: String
    var image: UIImage
    var pass: String
    var edad: Int
    var sexo: String
    var peso: Double
    var estatura: Int
    var frecuenciabasal: Int
    var birthday: String
    var pseudonym: String
    var phone: String
    var tok: String
    var full: Int
    
    
    init(id:Int, name:String,fullname:String, email:String, image: UIImage, pass:String,edad:Int, sexo: String, peso:Double, estatura: Int,  frecuenciabasal: Int, birthday:String, pseudonym:String,phone:String, tok:String, full: Int) {
        
        self.id = id
        self.name = name
        self.fullname = fullname
        self.email = email
        self.image = image
        self.pass = pass
        self.edad = edad
        self.sexo = sexo
        self.peso = peso
        self.estatura = estatura
        self.frecuenciabasal = frecuenciabasal
        self.birthday = birthday
        self.pseudonym = pseudonym
        self.phone = phone
        self.tok = tok
        self.full = full
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(fullname, forKey: "fullname")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(image, forKey: "image")
        aCoder.encode(pass, forKey: "pass")
        aCoder.encode(edad, forKey: "edad")
        aCoder.encode(sexo, forKey: "sexo")
        aCoder.encode(peso, forKey: "peso")
        aCoder.encode(estatura, forKey: "estatura")
        aCoder.encode(frecuenciabasal, forKey: "frecuenciabasal")
        aCoder.encode(birthday, forKey: "birthday")
        aCoder.encode(pseudonym, forKey: "pseudonym")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(tok, forKey: "tok")
        aCoder.encode(full, forKey: "full")

    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let fullname = aDecoder.decodeObject(forKey: "fullname") as! String
        let email = aDecoder.decodeObject(forKey: "email") as! String
        let image = aDecoder.decodeObject(forKey: "image") as! UIImage
        let pass = aDecoder.decodeObject(forKey: "pass") as! String
        let edad = aDecoder.decodeInteger(forKey: "edad")
        let sexo = aDecoder.decodeObject(forKey: "sexo") as! String
        let peso = aDecoder.decodeDouble(forKey: "peso")
        let estatura = aDecoder.decodeInteger(forKey: "estatura")
        let frecuenciabasal = aDecoder.decodeInteger(forKey: "frecuenciabasal")
        let birthday = aDecoder.decodeObject(forKey: "birthday") as! String
        let pseudonym = aDecoder.decodeObject(forKey: "pseudonym") as! String
        let phone = aDecoder.decodeObject(forKey: "phone") as! String
        let tok = aDecoder.decodeObject(forKey: "tok") as! String
        let full = aDecoder.decodeInteger(forKey: "full")
        
        self.init(
            id:id,
            name: name,
            fullname: fullname,
            email: email,
            image: image,
            pass: pass,
            edad: edad,
            sexo: sexo,
            peso: peso,
            estatura: estatura,
            frecuenciabasal: frecuenciabasal,
            birthday: birthday,
            pseudonym: pseudonym,
            phone: phone,
            tok: tok,
            full: full
        )
    }
}
