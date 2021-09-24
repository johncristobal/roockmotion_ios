//
//  ResumenMainViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/24/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import Charts

var valuesHeartRate: [ChartDataEntry]?
var valuesCalories: [ChartDataEntry]?
var valuesPercentage: [ChartDataEntry]?

var set1 : LineChartDataSet?
var set2 : LineChartDataSet?
var set3 : LineChartDataSet?

var maxHeart = 0.0
var maxCalo = 0.0
var maxPorc = 0.0
var minHeart = 1000.0
var minCalo = 1000.0
var minPorc = 1000.0
var colorBack: UIColor = .white
var stringLabel = ""
var graficaTipo = ""
var flagGraficaFirst = true

var sesionRockAll: Sesion?

class ResumeMainViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var cameraIcon: UIImageView!
    @IBOutlet var rockIcon: UIImageView!
    
    @IBOutlet var contentView: UIView!
    
    var resumenController: ResumeViewController!
    var graficaController: GraphViewController!
    var logrosController: AchieveViewController!
    
    var viewControllers: [UIViewController]!
    
    var selectedIndex: Int = 0
    @IBOutlet var resumenButton: UIButton!
    @IBOutlet var graphButton: UIButton!
    @IBOutlet var achieveButton: UIButton!
    
    /*@IBOutlet var tuautoLabel: UILabel!
    @IBOutlet var tudatosLabel: UILabel!
    @IBOutlet var cotizaLabel: UILabel!*/
    
    @IBOutlet var buttons: [UIButton]!
    
    let name = Notification.Name("autoData")
    let nameDataNotification = Notification.Name("personalData")
    
    var idcreated: String? = ""
    var sesionRock: Sesion? 
    
    var imagePicker: UIImagePickerController!
    var imagenFoto: UIImage?
    var flagFoto = false
    
    var loadingSesiones: UIAlertController?
    var loadDataJust = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        flagGraficaFirst = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        resumenController = storyboard.instantiateViewController(withIdentifier: "resumen") as! ResumeViewController
        
        graficaController = storyboard.instantiateViewController(withIdentifier: "grafica") as! GraphViewController
        
        logrosController = storyboard.instantiateViewController(withIdentifier: "logros") as! AchieveViewController
        
        viewControllers = [resumenController,graficaController,logrosController]
        buttons[selectedIndex].isSelected = true
        
        UserDefaults.standard.set(0, forKey: "autodata")
        UserDefaults.standard.set(0, forKey: "personaldata")
        UserDefaults.standard.set(0, forKey: "plandata")
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: name, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveDataPersonal(_:)), name: nameDataNotification, object: nil)
        //F7F7F7
        resumenButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .selected)
        resumenButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .highlighted)
        resumenButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .focused)
        resumenButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .disabled)
        
        graphButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .selected)
        graphButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .highlighted)
        graphButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .focused)
        graphButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .disabled)
        
        achieveButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .selected)
        achieveButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .highlighted)
        achieveButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .focused)
        achieveButton.setBackgroundColor(color: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0), forState: .disabled)

        let gestureSesion = UITapGestureRecognizer(target: self, action: #selector(sesionButton))
        rockIcon.isUserInteractionEnabled = true
        rockIcon.addGestureRecognizer(gestureSesion)
        
        let gestureShare = UITapGestureRecognizer(target: self, action: #selector(shareSession))
        cameraIcon.isUserInteractionEnabled = true
        cameraIcon.addGestureRecognizer(gestureShare)

        //loadDataFromSesion()
        sesionRockAll = sesionRock
        maxHeart = 0.0
        maxCalo = 0.0
        maxPorc = 0.0
        minHeart = 1000.0
        minCalo = 1000.0
        minPorc = 1000.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*if flagFoto{
            flagFoto = false
            
            
        }*/
        
        if loadDataJust{
            loadDataJust = false
            loadDataFromSesion()
        }
    }
    
    //cargamos json con el id...obtenemos datos del api y lo guardamos en base
    func loadDataFromSesion(){

        if graficasData!.rawValue == 3{ //finsesion cargamos de la ssion recien hecha!
            showLoading(titulo: "Información", mensaje: "Cargando datos")
            
            //let esfuerzoZonasData = JSON(esfuerzoData["zonas"])
            var zonasEsfuerzo :[String:Int] = [:]
            zonasEsfuerzo["MuyLigero"] = sesionRock?.graficas["esfuerzo"]?.zonas["MuyLigero"] // esfuerzoZonasData["MuyLigero"].int
            zonasEsfuerzo["Ligero"] = sesionRock?.graficas["esfuerzo"]?.zonas["Ligero"] //esfuerzoZonasData["Ligero"].int
            zonasEsfuerzo["Moderado"] = sesionRock?.graficas["esfuerzo"]?.zonas["Moderado"] //esfuerzoZonasData["Moderado"].int
            zonasEsfuerzo["Intenso"] = sesionRock?.graficas["esfuerzo"]?.zonas["Intenso"] //esfuerzoZonasData["Intenso"].int
            zonasEsfuerzo["MuyIntenso"] = sesionRock?.graficas["esfuerzo"]?.zonas["MuyIntenso"] //esfuerzoZonasData["MuyIntenso"].int
            
            /*
             Ordenamos datos ====================================
             */
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "es_MX")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //let heartOrdered =  datosGraficas.sorted(by: < )
            let heartOrdered = (sesionRock?.graficas["frecuencia"]!.datos)!.sorted(by: < )

            //sesionRock?.graficas["frecuencia"]?.datos
            //let frecuenciasOrdered =  datosGraficasfrecuencia.sorted(by: < )
            let frecuenciasOrdered = (sesionRock?.graficas["calorias"]?.datos)!.sorted(by: < )
            
            //let porcentajeOrdered =  datosGraficasesfuerzo.sorted(by: < )
            let porcentajeOrdered = (sesionRock?.graficas["esfuerzo"]?.datos)!.sorted(by: < )
            
            /*
             Llenamos arreglos para graficas ======================
             */
            valuesHeartRate = heartOrdered.map({ (arg0) -> ChartDataEntry in
                let (key, value) = arg0
                if value > maxHeart{
                    maxHeart = value
                }
                if value < minHeart{
                    minHeart = value
                }
                
                let date = dateFormatter.date(from: key)
                let nowDouble = date!.timeIntervalSince1970
                return ChartDataEntry(x: Double(nowDouble), y: Double(value), icon: #imageLiteral(resourceName: "fire"))
            })
            
            valuesCalories = frecuenciasOrdered.map({ (arg0) -> ChartDataEntry in
                let (key, value) = arg0
                if value > maxCalo  {
                    maxCalo = value
                }
                if value < minCalo{
                    minCalo = value
                }
                
                let date = dateFormatter.date(from: key)
                let nowDouble = date!.timeIntervalSince1970
                return ChartDataEntry(x: Double(nowDouble), y: Double(value), icon: #imageLiteral(resourceName: "fire"))
            })
            
            valuesPercentage = porcentajeOrdered.map({ (arg0) -> ChartDataEntry in
                let (key, value) = arg0
                if value > maxPorc {
                    maxPorc = value
                }
                
                if value < minPorc {
                    minPorc = value
                }
                let date = dateFormatter.date(from: key)
                let nowDouble = date!.timeIntervalSince1970
                return ChartDataEntry(x: Double(nowDouble), y: Double(value), icon: #imageLiteral(resourceName: "fire"))
            })
            set1 = LineChartDataSet(entries: valuesPercentage, label: "Esfuerzo")
            set2 = LineChartDataSet(entries: valuesCalories, label: "Frecuencia")
            set3 = LineChartDataSet(entries: valuesHeartRate, label: "Calorias")
            
            //let esfuerzo = ["esfuerzo":graficaFinalesfuerzo]
            DispatchQueue.main.async {
                self.loadingSesiones?.dismiss(animated: true, completion: {
                    
                    self.didPressedAction(self.buttons[self.selectedIndex])
                    UserDefaults.standard.set(self.idcreated, forKey: "idcreated")
                })
            }
            
        }else if graficasData!.rawValue == 2{   //dashboard
            showLoading(titulo: "Información", mensaje: "Cargando datos")
            
            let manager = DataManager.shared
            manager.sessionsInfo(user: manager.user!, sessionId: idcreated!) { (respuesta) in
                
                switch respuesta.resp {
                case "ok":
                    
                    //el json ya esta en base cuando llamamos service, ahora lo obtenemos y los vamos desenrollando
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    
                    let managedContext = appDelegate.persistentContainer.viewContext
                    let predicate = NSPredicate(format: "id = %@", self.idcreated!)
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
                            /*
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
                            */
                            //graficas
                            let graficas = JSON(data["graficas"])
                            
                            //calorias
                            let caloriasData = JSON(graficas["calorias"])
                            /*
                            let caloriasType = JSON(caloriasData["type"])
                            let idCalorias = caloriasType["id"].int
                            let recordCalorias = caloriasType["record"].description
                            let timechartCalorias = caloriasType["time_chart"].description
                            */
                            let arrayFechaCalorias = caloriasData["fechas"].array
                            let arrayValoresCalorias = caloriasData["valores"].array
                            var datosGraficas : [String:Double] = [:]
                            if arrayFechaCalorias!.count > 0 {
                                //let fecha = arrayFechaCalorias![i].description
                                //let valor = arrayValoresCalorias![i].description
                                for i in 0...arrayFechaCalorias!.count - 1{
                                    datosGraficas[arrayFechaCalorias![i].description] = Double(arrayValoresCalorias![i].description)!
                                }
                            }
                            
                            //let graficaFinalCalorias = Grafica(id: idCalorias!, record: recordCalorias, timeChart: timechartCalorias, datos: datosGraficas, zonas: [:])
                            //let calorias = ["calorias":graficaFinalCalorias]
                            
                            //frecencia
                            let frecuenciaData = JSON(graficas["frecuencia"])
                            /*
                            let frecuenciaType = JSON(frecuenciaData["type"])
                            let idfrecuencia = frecuenciaType["id"].int
                            let recordfrecuencia = frecuenciaType["record"].description
                            let timechartfrecuencia = frecuenciaType["time_chart"].description
                            */
                            let arrayFechafrecuencia = frecuenciaData["fechas"].array
                            let arrayValoresfrecuencia = frecuenciaData["valores"].array
                            var datosGraficasfrecuencia : [String:Double] = [:]
                            
                            if arrayFechafrecuencia!.count > 0 {
                                //let fecha = arrayFechafrecuencia![i].description
                                //let valor = arrayValoresfrecuencia![i].description
                                for i in 0...arrayFechafrecuencia!.count - 1{               datosGraficasfrecuencia[arrayFechafrecuencia![i].description] = Double(arrayValoresfrecuencia![i].description)!
                                }
                            }
                            
                            //let graficaFinalfrecuencia = Grafica(id: idfrecuencia!, record: recordfrecuencia, timeChart: timechartfrecuencia, datos: datosGraficasfrecuencia, zonas: [:])
                            
                            //esfuerzo
                            let esfuerzoData = JSON(graficas["esfuerzo"])
                            /*
                            let esfuerzoType = JSON(esfuerzoData["type"])
                            let idesfuerzo = esfuerzoType["id"].int
                            let recordesfuerzo = esfuerzoType["record"].description
                            let timechartesfuerzo = esfuerzoType["time_chart"].description
                            */
                            let arrayFechaesfuerzo = esfuerzoData["fechas"].array
                            let arrayValoresesfuerzo = esfuerzoData["valores"].array
                            var datosGraficasesfuerzo : [String:Double] = [:]
                            
                            if arrayFechaesfuerzo!.count > 0{
                                //let fecha = arrayFechaesfuerzo![i].description
                                //let valor = arrayValoresesfuerzo![i].description
                                for i in 0...arrayFechaesfuerzo!.count - 1{
                                    datosGraficasesfuerzo[arrayFechaesfuerzo![i].description] = Double(arrayValoresesfuerzo![i].description)!
                                }
                            }
                            
                            let esfuerzoZonasData = JSON(esfuerzoData["zonas"])
                            var zonasEsfuerzo :[String:Int] = [:]
                            zonasEsfuerzo["MuyLigero"] = esfuerzoZonasData["MuyLigero"].int
                            zonasEsfuerzo["Ligero"] = esfuerzoZonasData["Ligero"].int
                            zonasEsfuerzo["Moderado"] = esfuerzoZonasData["Moderado"].int
                            zonasEsfuerzo["Intenso"] = esfuerzoZonasData["Intenso"].int
                            zonasEsfuerzo["MuyIntenso"] = esfuerzoZonasData["MuyIntenso"].int
                            
                            //let graficaFinalesfuerzo = Grafica(id: idesfuerzo!, record: recordesfuerzo, timeChart: timechartesfuerzo, datos: datosGraficasesfuerzo, zonas: zonasEsfuerzo)
                            //let frecuencia = ["frecuencia":graficaFinalfrecuencia]
                            
                            /*
                             Ordenamos datos ====================================
                             */
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            dateFormatter.locale = Locale(identifier: "es_MX")
                            let heartOrdered =  datosGraficas.sorted(by: < ) /*{
                             guard let date0 = dateFormatter.date(from: $0.key), let date1 = dateFormatter.date(from: $1.key) else{
                             return false
                             }
                             return date0 < date1
                             }*/
                            let frecuenciasOrdered =  datosGraficasfrecuencia.sorted(by: < ) /*{
                             guard let date0 = dateFormatter.date(from: $0.key), let date1 = dateFormatter.date(from: $1.key) else{
                             return false
                             }
                             return date0 < date1
                             }*/
                            
                            let porcentajeOrdered =  datosGraficasesfuerzo.sorted(by: < ) /*{
                             guard let date0 = dateFormatter.date(from: $0.key), let date1 = dateFormatter.date(from: $1.key) else{
                             return false
                             }
                             return date0 < date1
                             }*/
                            
                            /*
                             Llenamos arreglos para graficas ======================
                             */
                            valuesHeartRate = heartOrdered.map({ (arg0) -> ChartDataEntry in
                                let (key, value) = arg0
                                if value > maxHeart{
                                    maxHeart = value
                                }
                                if value < minHeart{
                                    minHeart = value
                                }
                                
                                let date = dateFormatter.date(from: key)
                                let nowDouble = date!.timeIntervalSince1970
                                return ChartDataEntry(x: Double(nowDouble), y: Double(value), icon: #imageLiteral(resourceName: "fire"))
                            })
                            
                            valuesCalories = frecuenciasOrdered.map({ (arg0) -> ChartDataEntry in
                                let (key, value) = arg0
                                if value > maxCalo  {
                                    maxCalo = value
                                }
                                if value < minCalo{
                                    minCalo = value
                                }
                                
                                let date = dateFormatter.date(from: key)
                                let nowDouble = date!.timeIntervalSince1970
                                return ChartDataEntry(x: Double(nowDouble), y: Double(value), icon: #imageLiteral(resourceName: "fire"))
                            })
                            
                            valuesPercentage = porcentajeOrdered.map({ (arg0) -> ChartDataEntry in
                                let (key, value) = arg0
                                if value > maxPorc {
                                    maxPorc = value
                                }
                                
                                if value < minPorc {
                                    minPorc = value
                                }
                                let date = dateFormatter.date(from: key)
                                let nowDouble = date!.timeIntervalSince1970
                                return ChartDataEntry(x: Double(nowDouble), y: Double(value), icon: #imageLiteral(resourceName: "fire"))
                            })
                            set1 = LineChartDataSet(entries: valuesPercentage, label: "Esfuerzo")
                            set2 = LineChartDataSet(entries: valuesCalories, label: "Frecuencia")
                            set3 = LineChartDataSet(entries: valuesHeartRate, label: "Calorias")
                            //let esfuerzo = ["esfuerzo":graficaFinalesfuerzo]
                            
                            /*let sesion = Sesion(name: "", time: "", image: #imageLiteral(resourceName: "fire"), created_at: created_at, final_at: final, duration: duration!, type_session_id: type_sessions_id!, final_user_id: final_user_id!, type_training_id: type_training_id!, sensors_id: sensors_id!, training: training, labelTraining: label, typeSession: type_session, esfuerzo: Int(esfuerzoMain!), frecuencia: Int(frecuenciaMain!), calorias: caloriasMain!, graficas: [:], rewards: [:])
                            
                            sesion.graficas["esfuerzo"] = graficaFinalesfuerzo
                            sesion.graficas["frecuencia"] = graficaFinalfrecuencia
                            sesion.graficas["calorias"] = graficaFinalCalorias*/
                            
                            break
                        }
                        
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                    
                    /*
                     Mostramos el primer view y en su viewdid cargamos la info con el idcreated
                     */
                    
                    //self.didPressedAction(self.buttons[1])
                    DispatchQueue.main.async {
                        self.loadingSesiones?.dismiss(animated: true, completion: {
                            
                            self.didPressedAction(self.buttons[self.selectedIndex])
                            UserDefaults.standard.set(self.idcreated, forKey: "idcreated")
                        })
                    }
                    break
                    
                default:
                    DispatchQueue.main.async {
                        self.loadingSesiones?.dismiss(animated: true, completion: {
                            showmessage(message: respuesta.mes, controller: self)
                        }
                        )}
                    break
                }
            }
        }
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        // Do something now
        /*tudatosLabel.textColor = UIColor.blue
        buttons[1].isSelected = true
        didPressedAction(buttons[1])*/
    }
    
    @objc func onDidReceiveDataPersonal(_ notification:Notification) {
        // Do something now
        /*cotizaLabel.textColor = UIColor.blue
        buttons[2].isSelected = true
        didPressedAction(buttons[2])*/
    }
    
    @objc func sesionButton(){
        //open camera to take photo
        performSegue(withIdentifier: "blueconnect", sender: nil)
    }
    
    @objc func shareSession(){
        //load session and send data to photoController
        abrirAlertaFoto()
    }
    
    @IBAction func didPressedAction(_ sender: UIButton) {
        
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        buttons[previousIndex].isSelected = false
        
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParent: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParent()
        
        sender.isSelected = true
        
        let vc = viewControllers[selectedIndex]
        
        addChild(vc)
        vc.view.frame = contentView.bounds
        
        contentView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }

    func abrirAlertaFoto(){
        let alerta = UIAlertController(title: "Elige tu foto", message: "", preferredStyle: .actionSheet)
        alerta.addAction(UIAlertAction(title: "Toma foto", style: .default, handler: { (alert) in
            print("camara")
            self.cameraButton()
        }))
        alerta.addAction(UIAlertAction(title: "Elegir de la galería", style: .default, handler: { (alert) in
            print("galeria")
            self.galeriaButton()
        }))
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { (alert) in
            print("cancela")
        }))
        
        present(alerta, animated: true, completion: nil)
    }
    
    func galeriaButton(){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func cameraButton(){
        //open camera to take photo
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: {
            
            self.imagenFoto = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            
            if self.imagenFoto != nil{
            
            if graficasData!.rawValue == 3{ //finsesion
                
                let created_at = self.sesionRock?.created_at
                let duration = self.sesionRock?.duration
                let percentageMain = self.sesionRock?.percentage
                let heartRateMain = self.sesionRock?.heartRate
                let calTemo = self.sesionRock?.calories
                let caloriasMain = Double(calTemo!.description)
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "es_MX")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.date(from: created_at!)
                dateFormatter.dateFormat = "MMMM dd"
                let fianlDate = dateFormatter.string(from: date!)   //fechafinal...
                let hearttwopoints = String(format: "%d lpm", Int(heartRateMain!))
                let hearttext = hearttwopoints //"\(frecuenciaMain!) lpm"
                let esfi = String(format: "%d", Int(percentageMain!))
                var firetext = ""
                if caloriasMain! > 999.0 {
                    firetext = "\(caloriasMain! / 1000) kcal"
                }else{
                    firetext = "\(caloriasMain!) cal"
                }
                let durationSesion = duration
                let timeLabeltext = "\(getTimeFromDuration(durationSesion: durationSesion!))"
                
                let photoData = Photoshare(calories: firetext, heart: hearttext, esfuerzo: "\(esfi) %", fecha: fianlDate, duration: timeLabeltext, fotoback: self.imagenFoto!)
                
                self.performSegue(withIdentifier: "photoShare", sender: photoData)
                
            }else if graficasData!.rawValue == 2{ //dasjboard
            
                let idcreated = UserDefaults.standard.string(forKey: "idcreated")
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
                        let duration = data["duration"].int
                        let esfuerzoMain = data["esfuerzo"].double
                        let frecuenciaMain = data["frecuencia"].double
                        let calTemo = data["calorias"].int
                        let caloriasMain = Double(calTemo!.description)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "es_MX")
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = dateFormatter.date(from: created_at)
                        dateFormatter.dateFormat = "MMMM dd"
                        let fianlDate = dateFormatter.string(from: date!)   //fechafinal...
                        let hearttwopoints = String(format: "%d lpm", Int(frecuenciaMain!))
                        let hearttext = hearttwopoints //"\(frecuenciaMain!) lpm"
                        let esfi = String(format: "%d", Int(esfuerzoMain!))
                        var firetext = ""
                        if caloriasMain! > 999.0 {
                            firetext = "\(caloriasMain! / 1000) kcal"
                        }else{
                            firetext = "\(caloriasMain!) cal"
                        }
                        let durationSesion = duration
                        let timeLabeltext = "\(getTimeFromDuration(durationSesion: durationSesion!))"
                        
                        let photoData = Photoshare(calories: firetext, heart: hearttext, esfuerzo: "\(esfi) %", fecha: fianlDate, duration: timeLabeltext, fotoback: self.imagenFoto!)
                        
                        self.performSegue(withIdentifier: "photoShare", sender: photoData)
                        
                        break
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
            }
            }
        })
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        //borramos sesion de base
        let idcreated = UserDefaults.standard.string(forKey: "idcreated")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let predicate = NSPredicate(format: "id = %@", idcreated!)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sesionjson")
        fetchRequest.predicate = predicate

        do {
            let dataSesion = try managedContext.fetch(fetchRequest)
            for item in dataSesion{
                try managedContext.delete(item)
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }  
        
        let manager = DataManager.shared
        if manager.flagSesion{
           
           performSegue(withIdentifier: "dashboard", sender: nil)
            //self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoShare"{
             let vc = segue.destination as! PhotoViewController
             vc.sesion = sender as? Photoshare
         }
        
        /*if segue.identifier == "photoShare"{
            let vc = segue.destination as! PhotoViewController
            vc.idcreated = sender as? String
        }*/
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    func showLoading(titulo: String, mensaje: String){
        loadingSesiones = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        loadingSesiones!.view.tintColor = UIColor.black
        //CGRect(x: 1, y: 5, width: self.view.frame.size.width - 20, height: 120))
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        loadingSesiones!.view.addSubview(loadingIndicator)
        self.present(loadingSesiones!, animated: true, completion: nil)
    }
}
