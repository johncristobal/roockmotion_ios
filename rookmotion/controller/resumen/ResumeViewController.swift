//
//  ResumenViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/24/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import Charts
import EasyTipView

class ResumeViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var scrollViewTip: UIScrollView!
    @IBOutlet weak var maxInfo: UIImageView!
    @IBOutlet weak var intInfo: UIImageView!
    @IBOutlet weak var modInfo: UIImageView!
    @IBOutlet weak var ligInfo: UIImageView!
    @IBOutlet weak var muyInfo: UIImageView!
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var heartLabel: UILabel!
    @IBOutlet var fireLabel: UILabel!
    
    @IBOutlet var timeMaximoLabel: UILabel!
    @IBOutlet var timeIntensoLabel: UILabel!
    @IBOutlet var timeModeradoabel: UILabel!
    @IBOutlet var timeLigeroLabel: UILabel!
    @IBOutlet var timeMuyLigeroLabel: UILabel!
    
    @IBOutlet var sliderMaximo: CustomSlider!
    @IBOutlet var sliderIntenso: CustomSlider!
    @IBOutlet var sliderModerado: CustomSlider!
    @IBOutlet var sliderLigero: CustomSlider!
    @IBOutlet var sliderMuyLigero: CustomSlider!
    
    var showMexTip: EasyTipView?
    var showIntTip: EasyTipView?
    var showModTip: EasyTipView?
    var showLigTip: EasyTipView?
    var showLigx2Tip: EasyTipView?
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("resumen viewdid")
        
        maxInfo.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showMexMessage))
        maxInfo.addGestureRecognizer(gesture)
        
        intInfo.isUserInteractionEnabled = true
        let gestureb = UITapGestureRecognizer(target: self, action: #selector(showIntMessage))
        intInfo.addGestureRecognizer(gestureb)

        modInfo.isUserInteractionEnabled = true
        let gesturec = UITapGestureRecognizer(target: self, action: #selector(showModMessage))
        modInfo.addGestureRecognizer(gesturec)

        ligInfo.isUserInteractionEnabled = true
        let gestured = UITapGestureRecognizer(target: self, action: #selector(showLigMessage))
        ligInfo.addGestureRecognizer(gestured)

        muyInfo.isUserInteractionEnabled = true
        let gesturee = UITapGestureRecognizer(target: self, action: #selector(showLigX2Message))
        muyInfo.addGestureRecognizer(gesturee)

        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor.black //(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.left
        
        /*
         * Optionally you can make these preferences global for all future EasyTipViews
         */
        EasyTipView.globalPreferences = preferences
        
        showMexTip = EasyTipView(text: "Mejora la condición y velocidad del atleta")
        showIntTip = EasyTipView(text: "Incrementa la capacidad máxima de desempeño en sesiones cortas")
        showModTip = EasyTipView(text: "Mejora la condición aeróbica")
        showLigTip = EasyTipView(text: "Mejora la resistencia e incentiva la pérdida de grasa")
        showLigx2Tip = EasyTipView(text: "Ayuda en la recuperación física")
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ocultarTips), userInfo: nil, repeats: true)
     
        scrollViewTip.delegate = self
    }
    
    @objc func ocultarTips(){
        showMexTip!.dismiss()
        showIntTip!.dismiss()
        showModTip!.dismiss()
        showLigTip!.dismiss()
        showLigx2Tip!.dismiss()
        
    }
    
    @objc func showMexMessage(){
        //showmessage(message: "Mejora la condición y velocidad del atleta", controller: self)
        showMexTip!.show(forView: self.maxInfo,
                         withinSuperview: self.view)
    }
    @objc func showIntMessage(){
        //showmessage(message: "Incrementa la capacidad máxima de desempeño en sesiones cortas", controller: self)
        showIntTip!.show(forView: self.intInfo,
                         withinSuperview: self.view)
    }
    @objc func showModMessage(){
        
        //showmessage(message: "Mejora la condición aeróbica", controller: self)
        showModTip!.show(forView: self.modInfo,
                         withinSuperview: self.view)
    }
    @objc func showLigMessage(){
        //showmessage(message: "Mejora la resistencia e incentiva la pérdida de grasa", controller: self)
        showLigTip!.show(forView: self.ligInfo,
                         withinSuperview: self.view)
    }
    @objc func showLigX2Message(){
        //showmessage(message: "Ayuda en la recuperación física", controller: self)
        showLigx2Tip!.show(forView: self.muyInfo,
                         withinSuperview: self.view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        ocultarTips()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        
        if graficasData!.rawValue == 3{ //sesionActiva
            let sesion = sesionRockAll!
            //Sesion(name: "", time: "", image: #imageLiteral(resourceName: "fire"), created_at: created_at, final_at: final, duration: duration!, type_session_id: type_sessions_id!, final_user_id: final_user_id!, type_training_id: type_training_id!, sensors_id: sensors_id!, training: training, labelTraining: label, typeSession: type_session, esfuerzo: Int(esfuerzoMain!), frecuencia: Int(frecuenciaMain!), calorias: caloriasMain!, graficas: [:], rewards: [:])
            
            //sesion.graficas["esfuerzo"] = graficaFinalesfuerzo
            //sesion.graficas["frecuencia"] = graficaFinalfrecuencia
            //sesion.graficas["calorias"] = graficaFinalCalorias
            
            //load data from sesion and show data in view...
            let durationSesion = sesion.duration
            timeLabel.text = "\(getTimeFromDuration(durationSesion: durationSesion))"
            
            let maxTime = sesion.graficas["esfuerzo"]?.zonas["MuyIntenso"] //esfuerzoZonasData["MuyIntenso"].int
            let intTime = sesion.graficas["esfuerzo"]?.zonas["Intenso"] //esfuerzoZonasData["Intenso"].int
            let modTime = sesion.graficas["esfuerzo"]?.zonas["Moderado"] //esfuerzoZonasData["Moderado"].int
            let ligTime = sesion.graficas["esfuerzo"]?.zonas["Ligero"] //esfuerzoZonasData["Ligero"].int
            let muyTime = sesion.graficas["esfuerzo"]?.zonas["MuyLigero"] //esfuerzoZonasData["MuyLigero"].int
            
            timeMaximoLabel.text = "\(getTimeFromDuration(durationSesion: maxTime!))"
            timeIntensoLabel.text = "\(getTimeFromDuration(durationSesion: intTime!))"
            timeModeradoabel.text = "\(getTimeFromDuration(durationSesion: modTime!))"
            timeLigeroLabel.text = "\(getTimeFromDuration(durationSesion: ligTime!))"
            timeMuyLigeroLabel.text = "\(getTimeFromDuration(durationSesion: muyTime!))"
            
            var vTotal = muyTime
            if ligTime! > vTotal! {
                vTotal = ligTime;
            }
            if modTime! > vTotal! {
                vTotal = modTime
            }
            if intTime! > vTotal! {
                vTotal = intTime
            }
            if maxTime! > vTotal! {
                vTotal = maxTime;
            }
            
            if vTotal! > 0 {
                sliderMaximo.value = Float(((maxTime! * 100) / vTotal!))
                sliderIntenso.value = Float((((intTime! * 100) / vTotal!)))
                sliderModerado.value = Float((((modTime! * 100) / vTotal!)))
                sliderLigero.value = Float((((ligTime! * 100) / vTotal!)))
                sliderMuyLigero.value = Float((((muyTime! * 100) / vTotal!)))
            }
            
            heartLabel.text = "\(sesion.heartRate) lpm"
            if sesion.calories > 999 {
                fireLabel.text = "\(sesion.calories / 1000) kcal"
            }else{
                fireLabel.text = "\(sesion.calories) cal"
            }            
            
        }else if graficasData!.rawValue == 2{   //dashboard
            let idcreated = UserDefaults.standard.string(forKey: "idcreated")
            /*
             Recuperamos el json de la base, vamos desarmando y pintando datos
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
                    let data = JSON(dataT["data"])
                    
                    //let sesion = getSesion()
                    //from json, get data to load here
                    let created_at = data["created_at"].description
                    let final = data["final"].description
                    let duration = data["duration"].int
                    let type_sessions_id = data["type_sessions_id"].int
                    let final_user_id = data["final_user_id"].int
                    let type_training_id = data["type_training_id"].int
                    let sensors_id = data["sensors_id"].int
                    let training = data["training"].description
                    let label = data["label"].description
                    let type_session = data["type_session"].description
                    let esfuerzoMain = data["esfuerzo"].double
                    let frecuenciaMain = data["frecuencia"].double
                    let calTemo = data["calorias"].int
                    let caloriasMain = Double(calTemo!.description)
                    
                    //graficas
                    let graficas = JSON(data["graficas"])

                    //esfuerzo
                    let esfuerzoData = JSON(graficas["esfuerzo"])
                    let esfuerzoZonasData = JSON(esfuerzoData["zonas"])
                    var zonasEsfuerzo :[String:Int] = [:]
                    zonasEsfuerzo["MuyLigero"] = esfuerzoZonasData["MuyLigero"].int
                    zonasEsfuerzo["Ligero"] = esfuerzoZonasData["Ligero"].int
                    zonasEsfuerzo["Moderado"] = esfuerzoZonasData["Moderado"].int
                    zonasEsfuerzo["Intenso"] = esfuerzoZonasData["Intenso"].int
                    zonasEsfuerzo["MuyIntenso"] = esfuerzoZonasData["MuyIntenso"].int

                    //let graficaFinalesfuerzo = Grafica(id: idesfuerzo!, record: recordesfuerzo, timeChart: timechartesfuerzo, datos: datosGraficasesfuerzo, zonas: zonasEsfuerzo)
                    //let esfuerzo = ["esfuerzo":graficaFinalesfuerzo]
                    
                    let sesion = Sesion(name: "", time: "", image: #imageLiteral(resourceName: "fire"), created_at: created_at, final_at: final, duration: duration!, type_session_id: type_sessions_id!, final_user_id: final_user_id!, type_training_id: type_training_id!, sensors_id: sensors_id!, training: training, labelTraining: label, typeSession: type_session, percentage: Int(esfuerzoMain!), heartRate: Int(frecuenciaMain!), calories: caloriasMain!, graficas: [:], rewards: [:])
                    
                    //sesion.graficas["esfuerzo"] = graficaFinalesfuerzo
                    //sesion.graficas["frecuencia"] = graficaFinalfrecuencia
                    //sesion.graficas["calorias"] = graficaFinalCalorias
               
                    //load data from sesion and show data in view...
                    let durationSesion = sesion.duration
                    timeLabel.text = "\(getTimeFromDuration(durationSesion: durationSesion))"
                    
                    let maxTime = esfuerzoZonasData["MuyIntenso"].int
                    let intTime = esfuerzoZonasData["Intenso"].int
                    let modTime = esfuerzoZonasData["Moderado"].int
                    let ligTime = esfuerzoZonasData["Ligero"].int
                    let muyTime = esfuerzoZonasData["MuyLigero"].int
                    
                    timeMaximoLabel.text = "\(getTimeFromDuration(durationSesion: maxTime!))"
                    timeIntensoLabel.text = "\(getTimeFromDuration(durationSesion: intTime!))"
                    timeModeradoabel.text = "\(getTimeFromDuration(durationSesion: modTime!))"
                    timeLigeroLabel.text = "\(getTimeFromDuration(durationSesion: ligTime!))"
                    timeMuyLigeroLabel.text = "\(getTimeFromDuration(durationSesion: muyTime!))"
                    
                    var vTotal = muyTime
                    if ligTime! > vTotal! {
                        vTotal = ligTime;
                    }
                    if modTime! > vTotal! {
                        vTotal = modTime
                    }
                    if intTime! > vTotal! {
                        vTotal = intTime
                    }
                    if maxTime! > vTotal! {
                        vTotal = maxTime;
                    }
                    
                    if vTotal! > 0 {
                        sliderMaximo.value = Float(((maxTime! * 100) / vTotal!))
                        sliderIntenso.value = Float((((intTime! * 100) / vTotal!)))
                        sliderModerado.value = Float((((modTime! * 100) / vTotal!)))
                        sliderLigero.value = Float((((ligTime! * 100) / vTotal!)))
                        sliderMuyLigero.value = Float((((muyTime! * 100) / vTotal!)))
                    }
                    
                    heartLabel.text = "\(sesion.heartRate) lpm"
                    if sesion.calories > 999 {
                        fireLabel.text = "\(sesion.calories / 1000) kcal"
                    }else{
                        fireLabel.text = "\(sesion.calories) cal"
                    }
                    
                    break
                }
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }

    func getTimeFromDuration(durationSesion: Int) -> NSString {
        let seconds = durationSesion % 60
        let minutes = (durationSesion / 60) % 60
        let hours = (durationSesion / 3600)
        let lastDuration = NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
        
        return lastDuration
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

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
