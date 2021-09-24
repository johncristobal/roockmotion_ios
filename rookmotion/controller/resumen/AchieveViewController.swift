//
//  LogrosViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/24/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class AchieveViewController: UIViewController {

    @IBOutlet weak var rookLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        cargarDataDB()

        // Do any additional setup after loading the view.
    }

    func cargarDataDB(){
        
        if graficasData!.rawValue == 3{ //sesionActiva
            
            let sesion = sesionRockAll!
            //Sesion(name: "", time: "", image: #imageLiteral(resourceName: "fire"), created_at: created_at, final_at: final, duration: duration!, type_session_id: type_sessions_id!, final_user_id: final_user_id!, type_training_id: type_training_id!, sensors_id: sensors_id!, training: training, labelTraining: label, typeSession: type_session, esfuerzo: Int(esfuerzoMain!), frecuencia: Int(frecuenciaMain!), calorias: caloriasMain!, graficas: [:], rewards: [:])
            
            /*timeLabel.text = "\(lastDuration)"
            
            heartLabel.text = "\(sesion.heartRate) lpm"
            if sesion.calories > 999 {
                fireLabel.text = "\(sesion.calories / 1000) kcal"
            }else{
                fireLabel.text = "\(sesion.calories) cal"
            }
            
            self.setDataCount(Int(10) + 1, range: UInt32(20))*/
            
        }else if graficasData!.rawValue == 2{   //dashboard
        
            let idcreated = UserDefaults.standard.string(forKey: "idcreated")
            
            /*
             Recuperamos el json de la base y pintamos datos
             */
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let predicate = NSPredicate(format: "id = %@", idcreated!)
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sesionjson")
            fetchRequest.predicate = predicate
            
            do {
                let dataSesion = try managedContext.fetch(fetchRequest)
                for data in dataSesion {
                    let datjson = data.value(forKeyPath: "json") as? String
                    let jsonString = datjson?.toJSON()
                    
                    let dataT = JSON(jsonString)
                    //print(dataT)
                    
                    let data = JSON(dataT["data"])
                    
                    if data["RookPoints"].exists(){
                        let rookpoints = data["RookPoints"].description
                        let rookint = Double(rookpoints)
                        rookLabel.text = "\(rookint!) logros"
                    }else{
                        print("no rookpoints")
                    }
                    
                    break
                }
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
