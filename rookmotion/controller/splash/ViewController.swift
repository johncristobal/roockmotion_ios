//
//  ViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/10/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//
/*
 https://api.rookmotion.com/v1.0/app/users/add
 #Rook19M61#
 1.0.0
 */

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            // Put your code which should be executed with a delay here
            
            let sesion = UserDefaults.standard.string(forKey: "sesion")
            //print(sesion)
            if sesion == "1"{
                /*let manager = DataManager.shared
                let userDefaults = UserDefaults.standard
                let decoded = userDefaults.data(forKey: "user")
                if decoded != nil{
                    let decodedUser = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! User
                    manager.user = decodedUser
                }else{
                    
                }*/
                self.loadUserCD()
            }else{
                self.performSegue(withIdentifier: "login", sender: nil)
            }
        })
    }
    
    func loadUserCD(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserData")
        
        do {
            let dataSesion = try managedContext.fetch(fetchRequest)
            
            if dataSesion.count != 0 {
                print("si hay datos back \(dataSesion.count)")
                for data in dataSesion {
                    let id = data.value(forKeyPath: "id") as? Int
                    let name = data.value(forKeyPath: "name") as? String
                    let fullname = data.value(forKeyPath: "fullname") as? String
                    let email = data.value(forKeyPath: "email") as? String
                    let pass = data.value(forKeyPath: "pass") as? String
                    let edad = data.value(forKeyPath: "edad") as? Int
                    let sexo = data.value(forKeyPath: "sexo") as? String
                    let peso = (data.value(forKeyPath: "peso") as? Double)!
                    let estatura = data.value(forKeyPath: "estatura") as? Int
                    let frecuenciabasal = data.value(forKeyPath: "frecuenciabasal") as? Int
                    let birthday = data.value(forKeyPath: "birthday") as? String
                    let pseudonym = data.value(forKeyPath: "pseudonym") as? String
                    let phone = data.value(forKeyPath: "phone") as? String
                    let tok = data.value(forKeyPath: "tok") as? String
                    let full = (data.value(forKeyPath: "full") as? Int)!

                    let image = data.value(forKeyPath: "image") as? Data
                    let imagefinal = UIImage(data: image!)

                    //let id = data.value(forKeyPath: "id") as? String

                    let user = User(id: id!, name: name!, fullname: fullname!, email: email!, image: imagefinal!, pass: pass!, edad: edad!, sexo: sexo!, peso: peso, estatura: estatura!,  frecuenciabasal: frecuenciabasal!, birthday: birthday!, pseudonym: pseudonym!, phone: phone!, tok: tok!, full: full)
                    
                    let manager = DataManager.shared
                    manager.user = user
                    
                    self.performSegue(withIdentifier: "launchdash", sender: nil)
                }
            }else{
                print("no hay datos back...user")
                // no hay datos, terminanos backservice
                self.performSegue(withIdentifier: "login", sender: nil)

            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

