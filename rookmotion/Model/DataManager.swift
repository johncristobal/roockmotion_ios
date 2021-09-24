//
//  DataManager.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/18/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CryptoSwift
import CoreData
import CoreLocation

class DataManager{
    
    var ip = "https://api.rookmotion.com/v1.0/app/"
    let llave = "Au34y#gjhFS35W#&";
    /**
     *
     */
    let iv = "fnF354#fft#d4jRw";
    /**
     *
     */
    let CIPHER_NAME = "AES/CBC/PKCS5PADDING";
    
    static let shared = DataManager()
    var user: User?
    var lastSession: ResumeSession?
    var actualSession: ResumeSession?
    var arraySessions: [Sesion]? = []
    var arrayMyDevices: [Devices]? = []
    var arrayBranch: [Branch]? = []
    var activities: [Actividad]? = []
    var branchTemp : Branch? = nil
    var flagSesion = true
    var sensorId = 0
    var weightData : [String:Double] = [:]

    var startPage = 0
    let updateDataSessiones = Notification.Name("updateDataSessiones")

    private init(){
        
    }
    
    func encrypt(data:String) -> String {
        do {
            let data8: Array<UInt8> = (data.data(using: .utf8)?.bytes)!
            let key8: Array<UInt8> = (llave.data(using: .utf8)?.bytes)!
            let iv8: Array<UInt8> = (iv.data(using: .utf8)?.bytes)!
            
            let encrypted = try AES(key: key8, blockMode: CBC(iv: iv8), padding: .pkcs7).encrypt(data8)
            let encryptedData = Data(encrypted)
            
            return encryptedData.base64EncodedString()
        } catch let error {
            print(error)
            return "-1"
        }
    }

    func getTokens() -> [String] {
        
        let date = Date()
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MM"
        let dateMonth = dayTimePeriodFormatter.string(from: date)
        dayTimePeriodFormatter.dateFormat = "dd"
        let day = dayTimePeriodFormatter.string(from: date)
        
        do{
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: date)
            
            let aptok = "#Rook19M61#-\(day)-\(year)-\(dateMonth)"
            let apv = "1.0.0-\(day)-\(year)-\(dateMonth)"
            
            let aptokcrypt = encrypt(data: aptok)
            let apvcrypt = encrypt(data: apv)
            
            print(aptokcrypt)
            print("---")
            print(apvcrypt)
            print("***")
            
            return [aptokcrypt,apvcrypt]
        } catch {
            return []
        }
    }
    
// ********************** get token ************************************
    func getToken(user:User, completion: @escaping (Respuesta) -> Void){
        
        let url = "\(ip)users/add"

        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            let parametros = [
                "name":user.name,
                "email":user.email,
                "password":user.pass,
                "password_confirmation":user.pass] as [String : Any]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt
            ]
            
            request(
                url,
                method:.post,
                parameters:parametros,
                encoding:JSONEncoding.default,
                headers: headerss)
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0{
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json["id"])
                                    completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["id"].description))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
            
        } catch let error{
                print("error catch: \(error)")
        }
    }

// ********************** validate token ************************************
    func validateToken(idUsuario:String, codigo: String, completion: @escaping (Respuesta) -> Void){
        
        let url = "\(ip)users/activate"

        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            let parametros = [
                "apidu":idUsuario,
                "code":codigo] as [String : Any]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt
            ]
            
            request(
                url,
                method:.post,
                parameters:parametros,
                encoding:JSONEncoding.default,
                headers: headerss)
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0{
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["tok"].description))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
// ********************** validate token ************************************
    func userslogin(email:String, password: String, completion: @escaping (Respuesta) -> Void){

        do{
            let url = "\(ip)users/login"

            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            let parametros = [
                "email":email,
                "password":password] as [String : Any]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt
            ]
            
            request(
                url,
                method:.post,
                parameters:parametros,
                encoding:JSONEncoding.default,
                headers: headerss)
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0{
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json)
                                    UserDefaults.standard.set("1", forKey: "sesion")
                                    
                                    if json["resp"] != "error"{
                                    
                                        let id = Int(json["id"].description) as! Int
                                        let name = json["name"].description
                                        let email = json["email"].description
                                        let pseudonym = json["pseudonym"].description
                                        let gender = json["gender"].description
                                        let birthday = json["birthday"].description
                                        let phone = json["phone"].description
                                        let full = Int(json["full"].description) as! Int
                                        let tok = json["tok"].description
                                        
                                        var peso = 0.0
                                        if json["peso"].exists(){
                                            peso = Double(json["peso"].description) as! Double
                                        }
                                        var estatura = 0
                                        if json["estatura"].exists(){
                                            estatura = Int(json["estatura"].description) as! Int
                                        }
                                        var frecuenciabasal = 0
                                        if json["frecuenciabasal"].exists(){
                                            frecuenciabasal = Int(json["frecuenciabasal"].description) as! Int
                                        }
                                        
                                        var photo = ""
                                        if json["photo"].exists() && json["photo"] != ""{
                                            
                                            photo = json["photo"].description
                                            if photo != "null"{
                                                //strong64 to image
                                                let dataDecoded : Data = Data(base64Encoded: photo, options: .ignoreUnknownCharacters)!
                                                
                                                let decodedimage:UIImage = UIImage(data: dataDecoded)!
                                                
                                                self.user = User(id: id, name: name, fullname: pseudonym, email: email, image: decodedimage, pass: "", edad: 1, sexo: gender, peso: peso, estatura: estatura,  frecuenciabasal: frecuenciabasal, birthday: birthday, pseudonym: pseudonym, phone: phone, tok: tok, full: full)
                                            }
                                            
                                            else{
                                                self.user = User(id: id, name: name, fullname: pseudonym, email: email, image: UIImage(named: "iconsubir_imagen")!, pass: "", edad: 1, sexo: gender, peso: peso, estatura: estatura,  frecuenciabasal: frecuenciabasal, birthday: birthday, pseudonym: pseudonym, phone: phone, tok: tok, full: full)
                                            }
                                        }else{
                                            self.user = User(id: id, name: name, fullname: pseudonym, email: email, image: UIImage(named: "iconsubir_imagen")!, pass: "", edad: 1, sexo: gender, peso: peso, estatura: estatura,  frecuenciabasal: frecuenciabasal, birthday: birthday, pseudonym: pseudonym, phone: phone, tok: tok, full: full)
                                        }
                                        
                                        self.flagSesion = true
                                        self.saveCoreUser(user: self.user!)
                                        /*let userDefaults = UserDefaults.standard
                                        let encodedData: Data =  NSKeyedArchiver.archivedData(withRootObject: self.user)
                                        userDefaults.set(encodedData, forKey: "user")
                                        //userDefaults.set("1", forKey: "sesion")
                                        userDefaults.synchronize()*/
                                        
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["tok"].description))
                                    }else{
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["tok"].description))
                                    }
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                            
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }

// ********************** validate token ************************************
    func usersloginSocial(user:User, social: String, completion: @escaping (Respuesta) -> Void){
        
        do{
            let url = "\(ip)users/loginSocial"
            
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            let parametros = [
                "id":user.id,
                "name": user.name,
                "email": user.email,
                "toks": user.tok,
                "social": social] as [String : Any]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt
            ]
            
            request(
                url,
                method:.post,
                parameters:parametros,
                encoding:JSONEncoding.default,
                headers: headerss)
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0{
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print("usuario...")
                                    print(json)
                                    UserDefaults.standard.set("1", forKey: "sesion")
                                    if json["resp"] != "error"{
                                        
                                        let id = Int(json["id"].description) as! Int
                                        let name = json["name"].description
                                        let email = json["email"].description
                                        let pseudonym = json["pseudonym"].description
                                        let gender = json["gender"].description
                                        let birthday = json["birthday"].description
                                        let phone = json["phone"].description
                                        let full = Int(json["full"].description) as! Int
                                        let tok = json["tok"].description
                                        
                                        var peso = 0.0
                                        if json["peso"].exists(){
                                            peso = Double(json["peso"].description) as! Double
                                        }
                                        var estatura = 0
                                        if json["estatura"].exists(){
                                            estatura = Int(json["estatura"].description) as! Int
                                        }
                                        var frecuenciabasal = 0
                                        if json["frecuenciabasal"].exists(){
                                            frecuenciabasal = Int(json["frecuenciabasal"].description) as! Int
                                        }
                                        
                                        var photo = ""
                                        if json["photo"].exists() && json["photo"] != ""{
                                            
                                            photo = json["photo"].description
                                            if photo != "null"{
                                                //strong64 to image
                                                let dataDecoded : Data = Data(base64Encoded: photo, options: .ignoreUnknownCharacters)!
                                                
                                                let decodedimage:UIImage = UIImage(data: dataDecoded)!
                                                
                                                self.user = User(id: id, name: name, fullname: pseudonym, email: email, image: decodedimage, pass: "", edad: 1, sexo: gender, peso: peso, estatura: estatura,  frecuenciabasal: frecuenciabasal, birthday: birthday, pseudonym: pseudonym, phone: phone, tok: tok, full: full)
                                            }
                                                
                                            else{
                                                self.user = User(id: id, name: name, fullname: pseudonym, email: email, image: user.image, pass: "", edad: 1, sexo: gender, peso: peso, estatura: estatura,  frecuenciabasal: frecuenciabasal, birthday: birthday, pseudonym: pseudonym, phone: phone, tok: tok, full: full)
                                            }
                                        }else{
                                            self.user = User(id: id, name: name, fullname: pseudonym, email: email, image: user.image, pass: "", edad: 1, sexo: gender, peso: peso, estatura: estatura,  frecuenciabasal: frecuenciabasal, birthday: birthday, pseudonym: pseudonym, phone: phone, tok: tok, full: full)
                                        }
                                        
                                        self.flagSesion = true
                                        self.saveCoreUser(user: self.user!)
                                        /*let userDefaults = UserDefaults.standard
                                        let encodedData: Data =  NSKeyedArchiver.archivedData(withRootObject: self.user)
                                        userDefaults.set(encodedData, forKey: "user")
                                        //userDefaults.set("1", forKey: "sesion")
                                        userDefaults.synchronize()*/
                                        
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["tok"].description))
                                    }else{
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["tok"].description))
                                    }
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                            
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
    func saveCoreUser(user: User){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "UserData", in: managedContext)!
        let sesinojson = NSManagedObject(entity: entity, insertInto: managedContext)

        /*var id: Int
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
        var full: Int*/
        
        sesinojson.setValue(user.id, forKeyPath: "id")
        sesinojson.setValue(user.name, forKeyPath: "name")
        sesinojson.setValue(user.fullname, forKeyPath: "fullname")
        sesinojson.setValue(user.email, forKeyPath: "email")
        sesinojson.setValue(user.pass, forKeyPath: "pass")
        sesinojson.setValue(user.edad, forKeyPath: "edad")
        sesinojson.setValue(user.sexo, forKeyPath: "sexo")
        sesinojson.setValue(user.peso, forKeyPath: "peso")
        sesinojson.setValue(user.estatura, forKeyPath: "estatura")
        sesinojson.setValue(user.frecuenciabasal, forKeyPath: "frecuenciabasal")
        sesinojson.setValue(user.birthday, forKeyPath: "birthday")
        sesinojson.setValue(user.pseudonym, forKeyPath: "pseudonym")
        sesinojson.setValue(user.phone, forKeyPath: "phone")
        sesinojson.setValue(user.tok, forKeyPath: "tok")
        sesinojson.setValue(user.full, forKeyPath: "full")
        
        //let dataImage = user.image.jpegData(compressionQuality: 1.0)
        let dataImage = user.image.pngData()
        sesinojson.setValue(dataImage, forKeyPath: "image")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
// ********************** validate token ************************************
    func usersUpdate(user:User, completion: @escaping (Respuesta) -> Void){
        
        let url = "\(ip)users/update"

        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)

            let parametros = [
                "name":user.name,
                "pseudonym":user.pseudonym,
                "email" : user.email,
                "phone" : user.phone,
                "birthday" : user.birthday,
                "gender" : user.sexo,
                "peso" : user.peso,
                "estatura" : user.estatura,
                "frecuenciabasal" : user.frecuenciabasal
            ] as [String : Any]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user.tok
            ]
            
            request(
                url,
                method:.post,
                parameters:parametros,
                encoding:JSONEncoding.default,
                headers: headerss)
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0 {
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json)
                                    
                                    completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["tok"].description))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                            
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
// ********************** validate token ************************************
    func sessionsResume(user:User, perido: Int, completion: @escaping (Respuesta) -> Void){
        
        let url = "\(ip)sessions/resume"
        
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)

            let parametros = [
                "op":"\(perido.description)"
                ]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/x-www-form-urlencoded",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user.tok
            ]
            
            request(
                url,
                method:.get,
                parameters:parametros,
                //encoding: JSONEncoding.default,
                headers: headerss)
                .validate()
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                            }//
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0 {
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json)
                                    //let id = Int(json["id"].description) as! Int
                                    let resp = json["resp"].description
                                    
                                    if resp == "ok" {
                                        let data = JSON(json["data"])
                                        if data["anterior"].exists(){
                                            let objAN = JSON(data["anterior"])

                                            var rewardsAnterior = 0
                                            var sesionesAnterior = 0
                                            var pesoAnterior = 0.0
                                            var estaturaAnterior = 0
                                            var frecuenciabasalAnterior = 0
                                            var esfuerzoAnterior = 0
                                            var frecuenciaAnterior = 0.0
                                            var caloriasAnterior = 0
                                            var RookPointsAnterior = 0.0
                                            if objAN["rewards"].exists(){
                                                rewardsAnterior = Int(objAN["rewards"].int!)
                                            }
                                            if objAN["sesiones"].exists(){
                                                sesionesAnterior = Int(objAN["sesiones"].int!)
                                            }
                                            if objAN["peso"].exists(){
                                                pesoAnterior = Double(objAN["peso"].description)!
                                            }
                                            if objAN["estatura"].exists(){
                                                estaturaAnterior = Int(objAN["estatura"].description) as! Int
                                            }
                                            if objAN["frecuenciabasal"].exists(){
                                                frecuenciabasalAnterior = Int(objAN["frecuenciabasal"].description)!
                                            }
                                            if objAN["esfuerzo"].exists(){
                                                esfuerzoAnterior = Int(objAN["esfuerzo"].int!)
                                            }
                                            if objAN["frecuencia"].exists(){
                                                frecuenciaAnterior = objAN["frecuencia"].double!
                                            }
                                            if objAN["calorias"].exists(){
                                                caloriasAnterior = Int(objAN["calorias"].int!) // as! Int
                                            }
                                            if objAN["RookPoints"].exists(){
                                                //RookPointsAnterior = objAN["RookPoints"].double!
                                                
                                                RookPointsAnterior = Double(objAN["RookPoints"].description)! // as! Int
                                            }
                                            
                                            /*let sesionesAnterior = Int(objAN["sesiones"].int!)
                                            let pesoAnterior = Double(objAN["peso"].description) as! Double
                                            let estaturaAnterior = Int(objAN["estatura"].description) as! Int
                                            let frecuenciabasalAnterior = Int(objAN["frecuenciabasal"].description) as! Int
                                            let esfuerzoAnterior = Int(objAN["esfuerzo"].int!)
                                            let frecuenciaAnterior = Int(objAN["frecuencia"].double!)
                                            let caloriasAnterior = Int(objAN["calorias"].description) as! Int*/
                                            
                                            self.lastSession = ResumeSession(rewards: rewardsAnterior, sesiones: sesionesAnterior, peso: pesoAnterior, estatura: estaturaAnterior, frecuenciabasal: frecuenciabasalAnterior, esfuerzo: esfuerzoAnterior, calorias: caloriasAnterior, frecuencia: Int(frecuenciaAnterior), RookPoints: RookPointsAnterior)
                                        }else{
                                            //no hay anterior
                                        }
                                        
                                        if data["actual"].exists(){
                                            let objAN = JSON(data["actual"])
                                            
                                            var rewardsActual = 0
                                            var sesionesActual = 0
                                            var pesoActual = 0.0
                                            var estaturaActual = 0
                                            var frecuenciabasalActual = 0
                                            var esfuerzoActual = 0
                                            var frecuenciaActual = 0
                                            var caloriasActual = 0
                                            var RookPointsActual = 0.0
                                            if objAN["rewards"].exists(){
                                                rewardsActual = Int(objAN["rewards"].int!)
                                            }
                                            if objAN["sesiones"].exists(){
                                                sesionesActual = Int(objAN["sesiones"].int!)
                                            }
                                            if objAN["peso"].exists(){
                                                pesoActual = Double(objAN["peso"].description)!
                                            }
                                            if objAN["estatura"].exists(){
                                                estaturaActual = Int(objAN["estatura"].description) as! Int
                                            }
                                            if objAN["frecuenciabasal"].exists(){
                                                frecuenciabasalActual = Int(objAN["frecuenciabasal"].description)!
                                            }
                                            if objAN["esfuerzo"].exists(){
                                                esfuerzoActual = Int(objAN["esfuerzo"].int!)
                                            }
                                            if objAN["frecuencia"].exists(){
                                                frecuenciaActual = Int(objAN["frecuencia"].double!)
                                            }
                                            if objAN["calorias"].exists(){
                                                caloriasActual = Int(objAN["calorias"].int!) // as! Int
                                            }
                                            if objAN["RookPoints"].exists(){
                                                //RookPointsActual = objAN["frecuencia"].double!
                                                RookPointsActual = Double(objAN["RookPoints"].description)! // as! Int
                                            }
                                            
                                            /*let rewardsActual = Int(objAN["rewards"].int!)
                                            let sesionesActual = Int(objAN["sesiones"].int!)
                                            let pesoActual = Double(objAN["peso"].description) as! Double
                                            let estaturaActual = Int(objAN["estatura"].description) as! Int
                                            let frecuenciabasalActual = Int(objAN["frecuenciabasal"].description) as! Int
                                            let esfuerzoActual = Int(objAN["esfuerzo"].int!)
                                            let frecuenciaActual = Int(objAN["frecuencia"].double!)
                                            let caloriasActual = Int(objAN["calorias"].description) as! Int*/
                                            
                                            self.actualSession = ResumeSession(rewards: rewardsActual, sesiones: sesionesActual, peso: pesoActual, estatura: estaturaActual, frecuenciabasal: frecuenciabasalActual, esfuerzo: esfuerzoActual, calorias: caloriasActual, frecuencia: Int(frecuenciaActual),RookPoints: RookPointsActual)
                                            
                                        }else{
                                            //no hay actual
                                        }
                                        
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                                    }else{
                                        //respiuesto no ok...mando el error
                                      completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                    }
                                    
                                    //completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
// ********************** validate token ************************************
    func sessionsList(user:User, perido: Int, page: Int, completion: @escaping (Respuesta) -> Void){
        
        startPage = page
        self.arraySessions?.removeAll()
        
        sessionsMoreList(user: user, perido: perido)
        
        if self.arraySessions?.count == 0{
            completion(Respuesta(resp: "error", mes: "Cargando datos...", id: ""))
        }else{
            completion(Respuesta(resp: "ok", mes: "", id: ""))
        }
    }
    
//MARK: - Get more sessiones
     func sessionsMoreList(user:User, perido: Int){
        
        let url = "\(ip)sessions/list"
        //var arrayTemp : [Sesion]? = []
        
        if startPage == -1 {
            
            NotificationCenter.default.post(name: self.updateDataSessiones, object: nil, userInfo: nil)
            return
        }
        
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)

            let parametros = [
                "op":"\(perido.description)",
                "page" : "\(startPage)"
            ]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user.tok
            ]
            
            request(
                url,
                method:.get,
                parameters:parametros,
                //encoding: JSONEncoding.default,
                headers: headerss)
                .validate()
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                self.startPage = -1
                                self.sessionsMoreList(user: user, perido: perido)
                            }
                        }else{
                            self.startPage = -1
                            self.sessionsMoreList(user: user, perido: perido)
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0 {
                                    self.startPage = -1
                                    self.sessionsMoreList(user: user, perido: perido)
                                }
                                else
                                {
                                    print(json)
                                    //let id = Int(json["id"].description) as! Int
                                    let resp = json["resp"].description
                                    
                                    if resp == "ok" {
                                        let data = JSON(json["data"])
                                        let array = data["data"].array
                                        
                                        //self.arraySessions?.removeAll()
                                        if array!.count == 0{
                                            self.startPage = -1
                                            self.sessionsMoreList(user: user, perido: perido)
                                        }else{

                                            for item in array!{
                                            //jalar los demas datos, iniciar rreglo de sesinoes para tabla
                                            let sesionTemp = Sesion(name: "", time: "0", image: #imageLiteral(resourceName: "playredxxhdpi"), created_at: item["created_at"].description, final_at: item["final"].description, duration: item["duration"].int!, type_session_id: item["type_sessions_id"].int!, final_user_id: item["final_user_id"].int!, type_training_id: item["type_training_id"].int!, sensors_id: item["sensors_id"].int!, training: item["training"].description, labelTraining: item["label"].description, typeSession: item["type_session"].description, percentage: item["esfuerzo"].int!, heartRate: item["frecuencia"].int!, calories: Double(item["calorias"].int!) * 1.0, graficas: [:], rewards: [:])
                                            
                                            self.arraySessions?.append(sesionTemp)
                                            }
                                        
                                        self.startPage += 1
                                        self.sessionsMoreList(user: user, perido: perido)
                                        }
                                    }else{
                                        //respiuesto no ok...mando el error
                                        self.startPage = -1
                                        self.sessionsMoreList(user: user, perido: perido)
                                    }
                                }
                            }else{
                                self.startPage = -1
                                self.sessionsMoreList(user: user, perido: perido)
                            }
                        case .failure(let error):
                            print(error)
                                self.startPage = -1
                                self.sessionsMoreList(user: user, perido: perido)
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
//MARK: - info de sessiones
// ********************** validate token ************************************
    func sessionsInfo(user:User, sessionId:String, completion: @escaping (Respuesta) -> Void){
        
        let url = "\(ip)sessions/info"
        
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            let parametros = [
                "id":"\(sessionId)"
                // "op":"2"
            ]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user.tok
            ]
            
            request(
                url,
                method:.get,
                parameters:parametros,
                //encoding: JSONEncoding.default,
                headers: headerss)
                .validate()
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                //print(json.description)
                                if json.count == 0 {
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    //print(json)
                                    //let id = Int(json["id"].description) as! Int
                                    let resp = json["resp"].description
                                    
                                    if resp == "ok" {
                                        
                                        /*
                                            Haremos lo mismo => a la base de datos...
                                         */
                                        self.saveResponseCD(json: json.description, sessionId: sessionId)
                                        
                                        //let data = JSON(json["data"])
                                        //print(data)
                                        
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: sessionId))
                                        
                                    }else{
                                        //respiuesto no ok...mando el error
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                    }
                                    
                                    //completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
    func saveResponseCD(json: String, sessionId: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Sesionjson", in: managedContext)!
        let sesinojson = NSManagedObject(entity: entity, insertInto: managedContext)
        
        sesinojson.setValue(json, forKeyPath: "json")
        sesinojson.setValue(1, forKeyPath: "estatus")
        sesinojson.setValue(sessionId, forKeyPath: "id")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
// ********************** validate token ************************************
    func sensorsList(completion: @escaping (Respuesta) -> Void){
        
        let url = "\(ip)sensors/list"
        
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            //let parametros = []
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user!.tok
            ]
            
            request(
                url,
                method:.get,
                //parameters:parametros,
                //encoding: JSONEncoding.default,
                headers: headerss)
                .validate()
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0 {
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    //print(json)
                                    //let id = Int(json["id"].description) as! Int
                                    let resp = json["resp"].description
                                    
                                    if resp == "ok" {
                                        let data = JSON(json["data"])
                                        let sensors = JSON(data["sensors"])
                                        let array = sensors["data"].array
                                        
                                        self.arrayMyDevices?.removeAll()
                                        
                                        for item in array!{
                                            
                                            let object = JSON(item)
                                            let id = object["id"].int
                                            let name = object["name"].description
                                            let mac = object["mac"].description
                                            let brand = object["brand"].description
                                            
                                            self.arrayMyDevices?.append(Devices(id: id!, name: name, price: "", mac: mac, brand: brand, active: false))
                                        }
                                        
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                        
                                    }else{
                                        //respiuesto no ok...mando el error
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                    }
                                    
                                    //completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
//*********************** lsita de gyms ************************************
    func BranchGeoListTask(location: CLLocation,completion: @escaping (Respuesta) -> Void){
        let url = "\(ip)branch/geolist"
        
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            let parametros = [
                "lat": location.coordinate.latitude,
                "lon": location.coordinate.longitude
            ]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user!.tok
            ]
            
            request(
                url,
                method:.get,
                parameters:parametros,
                //encoding: JSONEncoding.default,
                headers: headerss)
                .validate()
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0 {
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json)
                                    //let id = Int(json["id"].description) as! Int
                                    let resp = json["resp"].description
                                    
                                    if resp == "ok" {
                                        let array = json["data"].array
                                        
                                        self.arrayBranch?.removeAll()
                                        
                                        for item in array!{
                                            
                                            let object = JSON(item)
                                            let id = object["id"].description
                                            let name = object["name"].description
                                            let address = object["address"].description
                                            let distance = object["distance"].description
                                            let latitude = object["latitude"].description
                                            let longitude = object["longitude"].description
                                            
                                            self.arrayBranch?.append(Branch(id: id, name: name, description: "", address: address, distance: distance, longitude: Double(longitude) as! Double, latitude: Double(latitude) as! Double, images: [], link: -1))
                                        }
                                        
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                        
                                    }else{
                                        //respiuesto no ok...mando el error
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                    }
                                    
                                    //completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }

// ********************** get token ************************************
    func BranchInfoActive(branch: Branch, option: String, completion: @escaping (Respuesta) -> Void){
        
        let url = "\(ip)branch/subscribe"
        
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            let parametros = [
                "id":branch.id,
                "op": option
                ] as [String : Any]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user!.tok
            ]
            
            request(
                url,
                method:.post,
                parameters:parametros,
                encoding:JSONEncoding.default,
                headers: headerss)
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0{
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json["id"])
                                    
                                    let resp = json["resp"].description
                                    
                                    if resp == "ok" {
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: option))
                                        
                                    }else{
                                        //respiuesto no ok...mando el error
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                    }
                                    
                                    //completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["id"].description))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
            
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
// ********************** lsita de gyms ************************************
    func BranchInfo(branch: Branch, completion: @escaping (Respuesta) -> Void){
        let url = "\(ip)branch/info/\(branch.id)"
        
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            /*let parametros = [
                "lat": location.coordinate.latitude,
                "lon": location.coordinate.longitude
            ]*/
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user!.tok
            ]
            
            request(
                url,
                method:.get,
                //parameters:parametros,
                //encoding: JSONEncoding.default,
                headers: headerss)
                .validate()
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0 {
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json)
                                    //let id = Int(json["id"].description) as! Int
                                    let resp = json["resp"].description
                                    
                                    if resp == "ok" {
                                        let data = JSON(json["data"])
                                        
                                        let id = data["id"].description
                                        let name = data["name"].description
                                        let description = data["description"].description
                                        let address = data["address"].description
                                        let link = data["link"].int
                                        let latitude = data["latitude"].description
                                        let longitude = data["longitude"].description
                                        let array = data["gallery"].array
                                        var tempImages: [String] = []
                                        for item in array!{
                                            let obj = JSON(item)
                                            tempImages.append(obj["image"].description)
                                        }

                                        self.branchTemp = Branch(id: id, name: name, description: description, address: address, distance: "", longitude: Double(longitude) as! Double, latitude: Double(latitude) as! Double, images: tempImages, link: link!)
                                        
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                        
                                    }else{
                                        //respiuesto no ok...mando el error
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                    }
                                    
                                    //completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
// ********************** get token ************************************
    func sensorsAdd(name: String, mac: String, completion: @escaping (Respuesta) -> Void){
        
        let url = "\(ip)sensors/addIos"
        
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            let parametros = [
                "name":name,
                "mac": mac
            ] as [String : Any]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user!.tok
            ]
            
            request(
                url,
                method:.post,
                parameters:parametros,
                encoding:JSONEncoding.default,
                headers: headerss)
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0{
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json["id"])
                                    completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["id"].description))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
            
        } catch let error{
            print("error catch: \(error)")
        }
    }

// ********************** lsita de gyms ************************************
    func trainingList(completion: @escaping (Respuesta) -> Void){
        let url = "\(ip)training/list"
        
        if isConnectedToNetwork(){
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            /*let parametros = [
             "lat": location.coordinate.latitude,
             "lon": location.coordinate.longitude
             ]*/
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user!.tok
            ]
            
            request(
                url,
                method:.get,
                //parameters:parametros,
                //encoding: JSONEncoding.default,
                headers: headerss)
                .validate()
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0 {
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json)
                                    //let id = Int(json["id"].description) as! Int
                                    let resp = json["resp"].description
                                    self.activities?.removeAll()
                                    
                                    if resp == "ok" {
                                        let data = JSON(json["data"])
                                        let dataTra = JSON(data["training"])
                                        let array = dataTra["data"].array

                                        for item in array!{
                                            let obj = JSON(item)
                                            let id = obj["id"].int
                                            let training = obj["training"].description
                                            let label = obj["label"].description

                                            self.activities?.append(Actividad(id: id!, training: training, label: label))
                                        }
                                        
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                        
                                    }else{
                                        //respiuesto no ok...mando el error
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                    }
                                    
                                    //completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
        }else{
            
            self.activities?.append(Actividad(id: 1, training: "aerobics", label: "Aerobics"))
            self.activities?.append(Actividad(id: 2, training: "baloncesto", label: "Baloncesto"))
            self.activities?.append(Actividad(id: 3, training: "calistenia", label: "Calistenia"))
            self.activities?.append(Actividad(id: 4, training: "crossfit", label: "Crossfit"))
            self.activities?.append(Actividad(id: 5, training: "escalada", label: "Escalada"))
            self.activities?.append(Actividad(id: 6, training: "futbol", label: "Futbol"))
            self.activities?.append(Actividad(id: 7, training: "gimnasia", label: "Gimnasia"))
            self.activities?.append(Actividad(id: 8, training: "golf", label: "Golf"))
            self.activities?.append(Actividad(id: 9, training: "hit", label: "Hit"))
            self.activities?.append(Actividad(id: 10, training: "indoor-cycling", label: "Indoor-cycling"))
            self.activities?.append(Actividad(id: 11, training: "mountain-cycling", label: "Mountain-cycling"))
            self.activities?.append(Actividad(id: 12, training: "pole-dance", label: "Pole-dance"))
            self.activities?.append(Actividad(id: 13, training: "rowing", label: "Rowing"))
            self.activities?.append(Actividad(id: 14, training: "running", label: "Running"))
            self.activities?.append(Actividad(id: 15, training: "soccer", label: "Soccer"))
            self.activities?.append(Actividad(id: 16, training: "tenis", label: "Tenis"))
            self.activities?.append(Actividad(id: 17, training: "yoga", label: "Yoga"))

            completion(Respuesta(resp: "ok", mes: "", id: ""))
        }
    }

// ********************** add sesion ************************************
    func sessionsAddTaskBack(json: String, completion: @escaping (Respuesta) -> Void){
        
        let url = "\(ip)sessions/add"
        if json != ""{
            
            do{
                let tokens = getTokens()
                let aptokcrypt = tokens[0] //encrypt(data: aptok)
                let apvcrypt = tokens[1] //encrypt(data: apv)
                
                let parametros = [
                    "data":json
                    ] as [String : Any]
                
                let headerss: HTTPHeaders = [
                    "Content-Type": "application/json",
                    "aptok" : aptokcrypt,
                    "apv" : apvcrypt,
                    "tok" : user!.tok
                ]
                
                request(
                    url,
                    method:.post,
                    parameters:parametros,
                    encoding:JSONEncoding.default,
                    headers: headerss)
                    .responseJSON() { response in
                        
                        let estatus = response.response?.statusCode
                        if estatus != 200{
                            //self.loading.dismiss(animated: true, completion: {
                            if let value = response.result.value {
                                let json = JSON(value)
                                let mensaje = json["msg"].description
                                if mensaje != "null"{
                                    completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        }
                        else{
                            switch response.result {
                            case .success:
                                if let value = response.result.value {
                                    let json = JSON(value)
                                    print(json)
                                    if json.count == 0{
                                        completion(Respuesta(resp: "error", mes: "", id: ""))
                                    }
                                    else
                                    {
                                        print(json["id"])
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["id"].description))
                                    }
                                }else{
                                    completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                                }
                            case .failure(let error):
                                print(error)
                                completion(Respuesta(resp: "error", mes: error as! String, id: ""))
                            }
                        }
                }
            } catch let error{
                print("error catch: \(error)")
                completion(Respuesta(resp: "error", mes: error.localizedDescription, id: ""))
            }
        
        }
        
    }
    
// ********************** add sesion ************************************
    func sessionsAddTask(sesion: Sesion, mac: String, completion: @escaping (Respuesta) -> Void){
        
        let url = "\(ip)sessions/add"
        let json = getJson(session: sesion)

        if !isConnectedToNetwork(){
            //no hay conexion...guardamos json, iniciamos thread para lanzar json
            //lanzamos comletion handler
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Notwifidata", in: managedContext)!
            let sesinojson = NSManagedObject(entity: entity, insertInto: managedContext)
            
            sesinojson.setValue(json, forKeyPath: "json")
            sesinojson.setValue(1, forKeyPath: "estatus")
            sesinojson.setValue(sesion.created_at, forKeyPath: "id")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
            
            //post para mandar a timer...backservice
            let backServiceName = Notification.Name("backServiceName")
            NotificationCenter.default.post(name: backServiceName, object: nil)
            
        }else{
        if json != ""{
            
            do{
                let tokens = getTokens()
                let aptokcrypt = tokens[0] //encrypt(data: aptok)
                let apvcrypt = tokens[1] //encrypt(data: apv)
                
                let parametros = [
                    "data":json
                    ] as [String : Any]
                
                let headerss: HTTPHeaders = [
                    "Content-Type": "application/json",
                    "aptok" : aptokcrypt,
                    "apv" : apvcrypt,
                    "tok" : user!.tok
                ]
                
                request(
                    url,
                    method:.post,
                    parameters:parametros,
                    encoding:JSONEncoding.default,
                    headers: headerss)
                    .responseJSON() { response in
                        
                        let estatus = response.response?.statusCode
                        if estatus != 200{
                            //self.loading.dismiss(animated: true, completion: {
                            if let value = response.result.value {
                                let json = JSON(value)
                                let mensaje = json["msg"].description
                                if mensaje != "null"{
                                    completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        }
                        else{
                            switch response.result {
                            case .success:
                                if let value = response.result.value {
                                    let json = JSON(value)
                                    print(json)
                                    if json.count == 0{
                                        completion(Respuesta(resp: "error", mes: "", id: ""))
                                    }
                                    else
                                    {
                                        print(json["id"])
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["id"].description))
                                    }
                                }else{
                                    completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                                }
                            case .failure(let error):
                                print(error)
                                completion(Respuesta(resp: "error", mes: error as! String, id: ""))
                            }
                        }
                }
            } catch let error{
                print("error catch: \(error)")
                completion(Respuesta(resp: "error", mes: error.localizedDescription, id: ""))
            }
        }
        }
    }
    
    func getJson(session: Sesion) -> String {
        
        var arrayFinal : [[String:Any]] = []
        var arrayFrecuencia : [[String:Any]] = []
        var arrayCalorias : [[String:Any]] = []
        var arrayPorcentaje : [[String:Any]] = []
        var arrayRecordsFrec : [[String:Any]] = []
        var arraySessions : [[String:Any]] = []
        
        let frecuenciaData = datosHeartRate.sorted(by : <)
        let caloriasData = datosCalories.sorted(by : <)
        let procentajeData = datosPercentage.sorted(by : <)
        
        frecuenciaData.forEach({ (arg0) in
            
            let (key, value) = arg0
            var object: [String:Any] = [:]
            object["date"] = key
            object["value"] = value
            arrayFrecuencia.append(object)
        })
        
        caloriasData.forEach({ (arg0) in
            
            let (key, value) = arg0
            var object: [String:Any] = [:]
            object["date"] = key
            object["value"] = value
            arrayCalorias.append(object)
        })
        
        procentajeData.forEach({ (arg0) in
            
            let (key, value) = arg0
            var object: [String:Any] = [:]
            object["date"] = key
            object["value"] = value
            arrayPorcentaje.append(object)
        })
        
        do
        {
            var datafre: [String: Any] = [:]
            var datacal: [String: Any] = [:]
            var datapor: [String: Any] = [:]
            
            let dataHeart = try JSONSerialization.data(withJSONObject: arrayFrecuencia, options: [])
            let dataCalorias = try JSONSerialization.data(withJSONObject: arrayCalorias, options: [])
            let dataPorcentaje = try JSONSerialization.data(withJSONObject: arrayPorcentaje, options: [])
            
            let stringjsonHeart = String(data: dataHeart, encoding: String.Encoding.utf8)
            let stringjsonCalorias = String(data: dataCalorias, encoding: String.Encoding.utf8)
            let stringjsonPorcentaje = String(data: dataPorcentaje, encoding: String.Encoding.utf8)
            
            datafre["data"] = arrayFrecuencia//stringjsonHeart
            datafre["type_record_id"] = "2"
            
            datacal["data"] = arrayCalorias//stringjsonCalorias
            datacal["type_record_id"] = "3"
            
            datapor["data"] = arrayPorcentaje//stringjsonPorcentaje
            datapor["type_record_id"] = "1"
            
            arrayRecordsFrec.append(datafre)
            arrayRecordsFrec.append(datacal)
            arrayRecordsFrec.append(datapor)
            
            let dataRecords = try JSONSerialization.data(withJSONObject: arrayRecordsFrec, options: [])
            let stringjRecords = String(data: dataRecords, encoding: String.Encoding.utf8)
            
            var dataSessions : [String: Any] = [:]
            dataSessions["start"] = session.created_at
            dataSessions["stop"] = session.final_at
            dataSessions["type_training"] = session.type_training_id
            dataSessions["sensors_id"] = session.sensors_id
            dataSessions["records"] = arrayRecordsFrec//stringjRecords
            
            arraySessions.append(dataSessions)
            
            var dataffinal : [String: Any] = [:]
            let dataFinal = try JSONSerialization.data(withJSONObject: arraySessions, options: [])
            let stringjFinal = String(data: dataFinal, encoding: String.Encoding.utf8)
            
            dataffinal["sessions"] = arraySessions//stringjFinal
            
            arrayFinal.append(dataffinal)
            
            let dataSend = try JSONSerialization.data(withJSONObject: dataffinal, options: [])
            let stringSend = String(data: dataSend, encoding: String.Encoding.utf8)
            
            return (stringSend!)
            
        }catch {
            print("erro")
            return ""
        }
    }
    
// ********************** lsita de gyms ************************************
    func UserPhotoCameraUp(imagen: UIImage, completion: @escaping (Respuesta) -> Void){
        let url = "\(ip)users/updateImg"
        
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            let data = compressImage(image: imagen)
            let stringData = data.base64EncodedString()
            
            let parametros = [
             "img": stringData
             ]
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user!.tok
            ]
            
            request(
                url,
                method:.post,
                parameters:parametros,
                encoding: JSONEncoding.default,
                headers: headerss)
                .validate()
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0 {
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json)
                                    let resp = json["resp"].description
                                    
                                    if resp == "ok" {
                                        
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                        
                                    }else{
                                        //respiuesto no ok...mando el error
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                    }
                                    
                                    //completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
//********************* compress image and get data**************//
    func compressImage(image:UIImage) -> Data {
        // Reducing file size to a 10th
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        var maxHeight : CGFloat = image.size.height/1//300
        var maxWidth : CGFloat = image.size.width/1//400.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        var maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 0.8
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
                compressionQuality = 1;
            }
        }
        
        //var rect = CGRect(0.0, 0.0, actualWidth, actualHeight);
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: actualWidth, height: actualHeight));
        UIGraphicsBeginImageContext(rect.size);
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = img?.jpegData(compressionQuality: 0.9) //UIImageJPEGRepresentation(img!,0.9);
        UIGraphicsEndImageContext();
        
        return imageData!
    }
    
// ********************** lsita de gyms ************************************
    func weightData(completion: @escaping (Respuesta) -> Void){
        let url = "\(ip)users/variable/1"
        
        do{
            let tokens = getTokens()
            let aptokcrypt = tokens[0] //encrypt(data: aptok)
            let apvcrypt = tokens[1] //encrypt(data: apv)
            
            /*let parametros = [
             "lat": location.coordinate.latitude,
             "lon": location.coordinate.longitude
             ]*/
            
            let headerss: HTTPHeaders = [
                "Content-Type": "application/json",
                "aptok" : aptokcrypt,
                "apv" : apvcrypt,
                "tok" : user!.tok
            ]
            
            request(
                url,
                method:.get,
                //parameters:parametros,
                //encoding: JSONEncoding.default,
                headers: headerss)
                .validate()
                .responseJSON() { response in
                    
                    let estatus = response.response?.statusCode
                    if estatus != 200{
                        //self.loading.dismiss(animated: true, completion: {
                        if let value = response.result.value {
                            let json = JSON(value)
                            let mensaje = json["msg"].description
                            if mensaje != "null"{
                                completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                            }
                        }else{
                            completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                        }
                    }
                    else{
                        switch response.result {
                        case .success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json.count)
                                if json.count == 0 {
                                    completion(Respuesta(resp: "error", mes: "", id: ""))
                                }
                                else
                                {
                                    print(json)
                                    //let id = Int(json["id"].description) as! Int
                                    let resp = json["resp"].description
                                    self.weightData.removeAll()
                                    
                                    if resp == "ok" {
                                        let data = JSON(json["data"])
                                        let dataTra = JSON(data["variable"])
                                        let array = dataTra["data"].array
                                        
                                        for item in array!{
                                            let obj = JSON(item)
                                            let created_at = obj["created_at"].description
                                            let value = obj["value"].description
                                            
                                            self.weightData[created_at] = Double(value)
                                        }
                                        
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                        
                                    }else{
                                        //respiuesto no ok...mando el error
                                        completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: json["cod"].description))
                                    }
                                    
                                    //completion(Respuesta(resp: json["resp"].description, mes: json["msg"].description, id: ""))
                                }
                            }else{
                                completion(Respuesta(resp: "error", mes: "No pudimos recuperar la información. Intente más tarde...", id: ""))
                            }
                        case .failure(let error):
                            print(error)
                            completion(Respuesta(resp: "error", mes: "", id: ""))
                        }
                    }
            }
        } catch let error{
            print("error catch: \(error)")
        }
    }
    
}
