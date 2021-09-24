//
//  SesionRookViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/17/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import CoreBluetooth
import Charts
import AudioToolbox

var bpmmaximo = 0
var flagmax = false
var datosHeartRate : [String:Double] = [:]
var datosCalories : [String:Double] = [:]
var datosPercentage : [String:Double] = [:]

class SesionRookViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var heartImage: UIImageView!
    @IBOutlet var fireImage: UIImageView!
    
    @IBOutlet weak var icoConnect: UIImageView!
    @IBOutlet weak var imageBattery: UIImageView!
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var heartRateLabel: UILabel!
    @IBOutlet var fireLabel: UILabel!
    @IBOutlet var porcentLabel: UILabel!
    @IBOutlet var back: UIView!
    
    @IBOutlet var playIcon: UIImageView!
    @IBOutlet var cameraIcon: UIImageView!    
    @IBOutlet var stopIcon: UIImageView!
    @IBOutlet var loading: UIActivityIndicatorView!
    
    var seconds = 0
    var timer = Timer()
    var isTimerRunning = false
    var flagDisconnectedSensor = false

    let manager = DataManager.shared

    var imagePicker: UIImagePickerController!
    var imagePhoto: UIImage?
   
    var muyintenso = 0
    var intenso = 0
    var moderado = 0
    var ligero = 0
    var muyligero = 0

    //var centralManager: CBCentralManager?
    //this is the id device
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    let batteryServiceCBUUID = CBUUID(string: "0x180F")
    //this is for heart rate
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    //this is for the battery
    let batteryMeasurementCharacteristicCBUUID = CBUUID(string: "2A19")
    
    var rockmotion: Blue!
    var rookmotionSensor: CBPeripheral!
    var device: Blue?
    
    var sesion: Sesion?
    var counter = 0
    var timerVibrar: Timer?
    
    var graphHeartRate: Grafica?
    var graphCalories: Grafica?
    var graphPorcentage: Grafica?
    
    var zones : [String:Int] = [:]

    var firstStart = true
    var flagCamera = false
    var primeroFotoLuegoTimer = false
    var finSesion = false
    var datoBmp = 0
    var flagDisconnected = false

    var loadingSesiones : UIAlertController?

    var mode = ModoContador.arriba // arriba = 1 // abajo = 2
    var nextStep : Step = .share
    let reestart = Notification.Name("reestartTimer")
    let finsesion = Notification.Name("finsesion")
    let periperalNoti = Notification.Name("periferico")
    let re_startSession = Notification.Name("re_startSession")

    var startTimeDate: Date?
    var contTime = 0
    
    var inactivityTimer: Timer?
    var equations: Equations?
    var blemanager: BLEManager?

    let serviceUUIDs:[CBUUID] = [CBUUID(string: "180D")] //0x180D
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timerLabel.text = timeString(time: TimeInterval(seconds))
        
        let gesturePlay = UITapGestureRecognizer(target: self, action: #selector(playpauseButton))
        playIcon.isUserInteractionEnabled = true
        playIcon.addGestureRecognizer(gesturePlay)
        
        let gestureStop = UITapGestureRecognizer(target: self, action: #selector(stopButton))
        stopIcon.isUserInteractionEnabled = true
        stopIcon.addGestureRecognizer(gestureStop)
        
        let gestureCamera = UITapGestureRecognizer(target: self, action: #selector(abrirAlertaFoto))
        cameraIcon.isUserInteractionEnabled = true
        cameraIcon.addGestureRecognizer(gestureCamera)

        let gestureActividad = UITapGestureRecognizer(target: self, action: #selector(actividadSegue))
        activityLabel.isUserInteractionEnabled = true
        activityLabel.addGestureRecognizer(gestureActividad)
        
        let gestureTime = UITapGestureRecognizer(target: self, action: #selector(timeSegue))
        timerLabel.isUserInteractionEnabled = true
        timerLabel.addGestureRecognizer(gestureTime)
        
        //centralManager = CBCentralManager.init(delegate: self, queue: nil)
        //centralManager?.delegate = self
        
        //get last idexcersie and string from defaults
        var ejercicio = "Aerobics"
        var idejercicio = 1
        if UserDefaults.standard.string(forKey: "ejercicio") != nil{
            ejercicio = UserDefaults.standard.string(forKey: "ejercicio")!
            idejercicio = UserDefaults.standard.integer(forKey: "idejercicio")
        }
        
        graphHeartRate = Grafica(id: 2, record: "Frecuencia", timeChart: "n", datos: [:], zonas: [:])
        graphCalories = Grafica(id: 3, record: "Calorias", timeChart: "n", datos: [:], zonas: [:])
        graphPorcentage = Grafica(id: 1, record: "Esfuerzo", timeChart: "s", datos: [:], zonas: [:])
        
        sesion = Sesion(name: "", time: "", image: #imageLiteral(resourceName: "rookmotionmini"), created_at: "", final_at: "", duration: -1, type_session_id: 1, final_user_id: manager.user!.id, type_training_id: idejercicio, sensors_id: manager.sensorId, training: ejercicio, labelTraining: ejercicio, typeSession: "Sesión en centro de entrenamiento", percentage: -1, heartRate: -1, calories: -1, graficas: [:], rewards: [:])
        
        NotificationCenter.default.addObserver(self, selector: #selector(reestartTime(_:)), name: reestart, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(finSesionFunc(_:)), name: finsesion, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(re_startSessionFunc(_:)), name: re_startSession, object: nil)

        //obtengo datos del skeleton
        blemanager = BLEManager.sharedBle
        /*
         TODO: Descomentar esto y quitar el icoConnect y el showButtons
         */
//        rookmotionSensor = blemanager?.rookmotionSensor
//        rookmotionSensor.delegate = self
//        rookmotionSensor.discoverServices(
//            [heartRateServiceCBUUID,batteryServiceCBUUID]
//        )
        icoConnect.isHidden = true
        showButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(periperalNoti(_:)), name: periperalNoti, object: nil)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        heartImage.image = #imageLiteral(resourceName: "whiteheartxxhdpi")
        fireImage.image = #imageLiteral(resourceName: "whitefirexxhdpi")
        
        stopIcon.image = #imageLiteral(resourceName: "stop")
        playIcon.image = #imageLiteral(resourceName: "play")
        cameraIcon.image = #imageLiteral(resourceName: "photo")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        
        if UserDefaults.standard.string(forKey: "ejercicio") != nil{
            let ejercicio = UserDefaults.standard.string(forKey: "ejercicio")!
            let idejercicio = UserDefaults.standard.integer(forKey: "idejercicio")
            
            sesion?.training = ejercicio
            sesion?.type_training_id = idejercicio
            
            activityLabel.text = ejercicio
        }else{
            sesion?.training = "Aerobics"
            sesion?.type_training_id = 1 //idejercicio
            activityLabel.text = "Aerobics"//ejercicio
        }
        
        if UserDefaults.standard.string(forKey: "timeSesion") != nil {
            if UserDefaults.standard.string(forKey: "timeSesion") != "-1" {
                
                let ejercicio = UserDefaults.standard.integer(forKey: "timeSesion")
                seconds = ejercicio * 60;
                timerLabel.text = timeString(time: TimeInterval(seconds))
                if seconds > 0{
                    mode = ModoContador.abajo
                }else {
                    mode = ModoContador.arriba
                }
                
                UserDefaults.standard.set("-1", forKey: "timeSesion")
            }
        }
    }
        
    @objc func inactivityCheck(){
       if flagDisconnected{
           print("conectando....")
           
           //centralManager!.connect(rookmotionSensor, options: nil)
       }else{
       
       print("sensro...")
       print(rookmotionSensor.state.rawValue)
       if rookmotionSensor.state.rawValue == 2{
           flagDisconnected = false
       }
       if rookmotionSensor.state.rawValue == 0{
           print("desconectando in timer....")
           //rookmotionSensor = rockmotion.peri
           //rookmotionSensor.delegate = self
           
           //centralManager?.cancelPeripheralConnection(rookmotionSensor)
           //centralManager = CBCentralManager.init(delegate: self, queue: nil)
           //centralManager?.delegate = self
           //self.centralManager!.scanForPeripherals(withServices: serviceUUIDs, options: nil)
           blemanager!.startConnecting()
           blemanager!.banderaReconectar = true


           if !flagDisconnectedSensor{

               icoConnect.isHidden = false
               flagDisconnected = true
               vibrar()
            }
           //centralManager!.connect(rookmotionSensor, options: nil)
       }
       /*if rookmotionSensor.state.rawValue == 1{
           centralManager!.connect(rookmotionSensor, options: nil)
       }*/
       }
    }
    
    @objc func reestartTime(_ notification: NSNotification){
        //runTimer()
        
        /*if finSesion{
            finSesion = false
            graficasData = .finSesion
            
        }else{
            
        }*/
    }
    
    @objc func finSesionFunc(_ notification: NSNotification){
        self.performSegue(withIdentifier: "showGraficas", sender: self.sesion)
    }
    
    func stopTimer() {
        isTimerRunning = false
        timer.invalidate()
    }
    
    func runTimer() {
        playIcon.image = UIImage(named: "pause")
        isTimerRunning = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    func vibrar(){
        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        timerVibrar = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(vibrarTimer)), userInfo: nil, repeats: true)
        counter = 0
    }
    
    @objc func vibrarTimer(){
        counter += 1
        switch counter {
        case 1, 2, 3, 4:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            //let generator = UINotificationFeedbackGenerator()
            //generator.notificationOccurred(.success)
        default:
            counter = 0
            timerVibrar?.invalidate()
        }
    }

//======================= timer every seconds ========================
    @objc func updateTimer(){
        
        if isTimerRunning{
            contTime += 1
            
            print("seconds: \(seconds)")
            if mode == ModoContador.arriba{
                seconds += 1
            }else{
                seconds -= 1
                if seconds == 0{
                    stopTimer()
                    vibrar()
                    showPlusMessage()
                }
            }
            
            let date = startTimeDate!.addingTimeInterval(TimeInterval(contTime))

            let bpm = datoBmp
            equations = Equations(heartRate: bpm)
            equations!.calculate()
            
            heartRateLabel.text = "\(equations!.getHeartRate())"
            fireLabel.text = "\(equations!.getCalories())"
            porcentLabel.text = "\(equations!.getPorcent()) %"
            
            if (equations!.getPorcent() < 60){
                muyligero += 1
                back.backgroundColor = UIColorFromHex(rgbValue: 0x868686)
            }else if(equations!.getPorcent() > 60 && equations!.getPorcent() <= 70){
                ligero += 1
                back.backgroundColor = UIColorFromHex(rgbValue: 0x60B9C7)
            }else if(equations!.getPorcent() > 70 && equations!.getPorcent() <= 80){
                moderado += 1
                back.backgroundColor = UIColorFromHex(rgbValue: 0x9DAB6C)
            }else if(equations!.getPorcent() > 80 && equations!.getPorcent() <= 90){
                intenso += 1
                back.backgroundColor = UIColorFromHex(rgbValue: 0xBF9A48)
            }else if(equations!.getPorcent() > 90){
                muyintenso += 1
                back.backgroundColor = UIColorFromHex(rgbValue: 0xB03762)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "es_MX")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: date)
            
            datosHeartRate[dateString] = Double(equations!.getHeartRate())
            datosCalories[dateString] = Double(equations!.getCalories())
            datosPercentage[dateString] = Double(equations!.getPorcent())
            
            /*if bpmmaximo > 100{
                flagmax = true
                bpmmaximo = bpm
            }*/
        }
        
        timerLabel.text = timeString(time: TimeInterval(seconds))
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    @objc func timeSegue(){
        if !isTimerRunning{
            performSegue(withIdentifier: "segueTime", sender: nil)
        }
    }
    
    @objc func actividadSegue(){
        performSegue(withIdentifier: "actividadSegue", sender: nil)
    }
    
    @objc func playpauseButton(){
        
        if isTimerRunning{
            //regresar a playicon
            playIcon.image = UIImage(named: "play")
            stopTimer()
        }else{
            //cambiar a pauseIcon
            if firstStart{
                firstStart = false
                let fechaInicio = Date()
                startTimeDate = fechaInicio
                contTime = 0

                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "es_MX")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.string(from: fechaInicio)
                
                sesion?.created_at = date
                
                inactivityTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(inactivityCheck), userInfo: nil, repeats: true)
            }
            
            runTimer()
        }
    }
    
    @objc func stopButton(){

        if self.firstStart{
            self.dismiss(animated: true, completion: {
                self.blemanager?.desconectarPeriferico()
            })
        }else{
            print("Segundos al momentos: \(seconds)")
            //stopTimer()
            
            let alert = UIAlertController(title: "Atención", message: "¿Deseas terminar la sesión y regresar?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sí, ya terminé", style: .default, handler: { (action) in

                self.stopTimer()
                self.showFinalMessage()
            }))
            
            alert.addAction(UIAlertAction(title: "No, aún no termino", style: .cancel, handler: { (action) in
                //self.runTimer()
            }))
            present(alert, animated: true)

        }
    }
    
//==================== enviar y siguiente paso ===============================
    func showFinalMessage(){
        print("Segundos al momentos: \(seconds)")
        stopTimer()
        inactivityTimer?.invalidate()
        
        let alert = UIAlertController(title: "", message: "Tu sesión de entrenamiento ha terminado...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ver resumen", style: .default, handler: { (action) in
            self.nextStep = .resumen
            self.cargarSaveData()
            
        }))
        alert.addAction(UIAlertAction(title: "Compartir", style: .default, handler: { (action) in
            self.nextStep = .share
            self.cargarSaveData()
            
        }))
        
        present(alert, animated: true)
    }
    
//==================== 10 minutso mas ===============================
    func showPlusMessage(){
        print("Segundos al momentos: \(seconds)")
        stopTimer()
        
        let alert = UIAlertController(title: "", message: "Tu sesión de entrenamiento ha terminado...", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ver resumen", style: .default, handler: { (action) in
            self.nextStep = .resumen
            self.cargarSaveData()
        }))
        alert.addAction(UIAlertAction(title: "Compartir", style: .default, handler: { (action) in
            self.nextStep = .share
            self.cargarSaveData()
        }))
        alert.addAction(UIAlertAction(title: "Agregar 10 minutos", style: .cancel, handler: { (action) in
            self.seconds = 10 * 60
            self.mode = ModoContador.abajo
            self.runTimer()
        }))
        present(alert, animated: true)
    }
    
//==================== guadra datos y lanzar WS ===============================
    func cargarSaveData(){

        blemanager?.desconectarPeriferico()
        flagDisconnectedSensor = true
        //self.centralManager?.cancelPeripheralConnection(self.rookmotionSensor)
        //usleep(3000000) //will sleep for 1 second

        //empiezo a guardar valores...
        //obtengo el promedio de todos....
        var heartProm = 0.0
        datosHeartRate.forEach({ (arg0) in
            
            let (key, value) = arg0
            heartProm += value
        })
        self.sesion?.heartRate = Int(heartProm)/datosHeartRate.count
        
        //calorias
        var caloProm = 0.0
        datosCalories.forEach({ (arg0) in
            
            let (key, value) = arg0
            caloProm += value
        })
        self.sesion?.calories = Double(Int(caloProm)/datosCalories.count)
        
        //Percentage esfuerzo
        var porcProm = 0.0
        datosPercentage.forEach({ (arg0) in
            
            let (key, value) = arg0
            porcProm += value
        })
        self.sesion?.percentage = Int(porcProm)/datosPercentage.count
        
        //cargar demas informacion faltante
        self.sesion?.duration = self.contTime //- 1
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_MX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateTemp = startTimeDate!.addingTimeInterval(TimeInterval(contTime - 1))
        let date = dateFormatter.string(from: dateTemp)
        self.sesion?.final_at = date
        
        self.zones["MuyIntenso"] = self.muyintenso
        self.zones["Intenso"] = self.intenso
        self.zones["Moderado"] = self.moderado
        self.zones["Ligero"] = self.ligero
        self.zones["MuyLigero"] = self.muyligero
        self.graphPorcentage?.zonas = self.zones

        //guardo graficas
        self.graphHeartRate?.datos = datosHeartRate
        self.graphCalories?.datos = datosCalories
        self.graphPorcentage?.datos = datosPercentage
        
        var graficas : [String:Grafica] = [:]
        graficas["frecuencia"] = self.graphHeartRate
        graficas["calorias"] = self.graphCalories
        graficas["esfuerzo"] = self.graphPorcentage
        
        self.sesion?.graficas = graficas
        
        //antes de mostrar graficas....debemos mandar sesion en api
        self.showLoading(titulo: "Información...", mensaje: "Cargando sesión...")
        
        self.manager.sessionsAddTask(sesion: self.sesion!, mac: "", completion: { (respuesta) in
            
            DispatchQueue.main.async {
                self.loadingSesiones?.dismiss(animated: true, completion: {
                    switch respuesta.resp {
                    case "ok":
                        //mostramos graficas...
                        self.manager.flagSesion = true
                        self.finSesion = true
                        
                        if self.nextStep == .resumen{
                            graficasData = .finSesion

                            self.performSegue(withIdentifier: "showGraficas", sender: self.sesion)
                            
                        }else if self.nextStep == .share{
                            graficasData = .finSesion
                            self.foto()
                        }
                        break
                        
                    default:
                        showmessage(message: respuesta.mes, controller: self)
                        
                        self.manager.flagSesion = true
                        self.finSesion = true
                        
                        if self.nextStep == .resumen{
                            graficasData = .finSesion
                            
                            self.performSegue(withIdentifier: "showGraficas", sender: self.sesion)
                            
                        }else if self.nextStep == .share{
                            graficasData = .finSesion
                            self.foto()
                        }
                        
                        break
                    }
                }
            )}
        })
    }
    
//==================== camera ===============================
    @objc func abrirAlertaFoto(){
        
        //stopTimer()
        graficasData = .sesionActiva
        foto()
    }
    
    func foto(){
        let alerta = UIAlertController(title: "Elige tu foto", message: "", preferredStyle: .actionSheet)
        alerta.addAction(UIAlertAction(title: "Toma foto", style: .default, handler: { (alert) in
            self.cameraButton()
            //self.stopTimer()
        }))
        alerta.addAction(UIAlertAction(title: "Elegir de la galería", style: .default, handler: { (alert) in
            self.galeriaButton()
            //self.stopTimer()
        }))
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { (alert) in
            //self.runTimer()
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
            //self.imagePhoto = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            //let cropRect = info[UIImagePickerController.InfoKey.cropRect] as! CGRect// CGRectValue
            
            //let cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];

            /*if (cropRect.origin.y < 0) {
                self.imagePhoto = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            } else {
                self.imagePhoto = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            }*/
            self.imagePhoto = info[UIImagePickerController.InfoKey.originalImage] as? UIImage

            if self.imagePhoto != nil{
                let dateFormatter = DateFormatter()
                let date = Date()
                dateFormatter.dateFormat = "MMMM dd"
                let fianlDate = dateFormatter.string(from: date)
                let heartRatetext = "\(self.heartRateLabel.text!) lpm"
                let esfi = self.porcentLabel.text!
                let firetext = "\(self.fireLabel.text!) cal"
                let timeLabeltext = "\(self.timerLabel.text!)"
                
                let photoData = Photoshare(calories: firetext, heart: heartRatetext, esfuerzo: esfi, fecha: fianlDate, duration: timeLabeltext, fotoback: self.imagePhoto!)
                
                self.performSegue(withIdentifier: "photoShare", sender: photoData)
            }
        })
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

/*
 ble methods
 //////////////////////////////////////////////////////////////////////////////////
 */
    func showButtons(){
        playIcon.isHidden = false
        stopIcon.isHidden = false
        cameraIcon.isHidden = false
        
        loading.isHidden = true
    }
    

    /*func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    }*/
    /*func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        flagDisconnected = false
        rookmotionSensor.delegate = self
    }*/
    
    /*func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //when connect to device
        //showmessage(message: "Conectado", controller: self)
        //showButtons()
        flagDisconnected = false
        rookmotionSensor.delegate = self
        rookmotionSensor.discoverServices(
            [heartRateServiceCBUUID,batteryServiceCBUUID]
        )
    }*/
    
    /*func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("descbubirndo again")
        
        print(peripheral.name!)
        print(rookmotionSensor.name!)
        if peripheral.name == rookmotionSensor.name{
            print("conectando en diddiscover")
            rookmotionSensor = peripheral
            rookmotionSensor.delegate = self
            //self.centralManager?.stopScan()
            //self.centralManager!.connect(peripheral, options: nil)
        }
    }*/
    
    @objc func re_startSessionFunc(_ notification: NSNotification){
        blemanager?.banderaReconectar = false
        rookmotionSensor.discoverServices(
            [heartRateServiceCBUUID,batteryServiceCBUUID]
        )
        
    }

    @objc func periperalNoti(_ notification: NSNotification){
        print("en sesion activa denuevo")
        if (notification.userInfo?["peripheral"] as? CBPeripheral) != nil {
            // do something with your image
            if blemanager!.banderaReconectar{
            let peripheral = notification.userInfo?["peripheral"] as! CBPeripheral

            print(rookmotionSensor.name!)
            if peripheral.name == rookmotionSensor.name{
                print("conectando en diddiscover")

                flagDisconnected = false

                rookmotionSensor = peripheral
                rookmotionSensor.delegate = self
                
                
                blemanager!.conectarPeriferico(peripheral: peripheral)

                //self.centralManager?.stopScan()
                //self.centralManager!.connect(peripheral, options: nil)
            }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
            
            /*
             org.bluetooth.service.heart_rateOx180D
             <CBService: 0x28056e0c0, isPrimary = YES, UUID = Heart Rate>
             <CBService: 0x28056dc80, isPrimary = YES, UUID = Battery>
             <CBService: 0x28056da40, isPrimary = YES, UUID = Device Information>
             */
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        // look for services in the device connected
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            print("char value")
            /*let vale = peripheral.readValue(for: characteristic)
            if characteristic != nil{
                print(vale)
                
                let mac_address = vale.hexEncodedString().uppercased()
                //{
                let macAddress = mac_address!.separate(every: 2, with: ":")
                    print("MAC_ADDRESS: \(macAddress)")
                //}
            }*/
            //FE:FF:9F:14:77:B9
        }
        icoConnect.isHidden = true
        showButtons()
    }
    
    /*func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        print("desconectando callback....")
        //rookmotionSensor = rockmotion.peri
        //rookmotionSensor.delegate = self
        
        //central.cancelPeripheralConnection(peripheral)
        //icoConnect.isHidden = false
        //centralManager!.connect(rookmotionSensor, options: nil)
    }*/

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        //print(characteristic)
        
        switch characteristic.uuid {
            //case bodySensorLocationCharacteristicCBUUID:
        case batteryMeasurementCharacteristicCBUUID:
            let bpm = battery(from: characteristic)
            onBatteryReceived(bpm)
            break
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
            break
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    //helper method to read the data
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
    //helper method to read the batteru
    private func battery(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        return Int(byteArray[0])
    }
    
    func onHeartRateReceived(_ bpm:Int){
        //empezamos a guardar la info del heart y actualizamos todo...2:49
        datoBmp = bpm
        print("frecuencia: \(datoBmp)")
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func onBatteryReceived(_ bpm:Int){
        
        if bpm < 20 {
            imageBattery.isHidden = false
            imageBattery.image = #imageLiteral(resourceName: "redbat")
        }
        else if bpm < 40 {
            imageBattery.isHidden = false
            imageBattery.image = #imageLiteral(resourceName: "orangebat")
        }else{
            imageBattery.isHidden = true
        }
        
        //imageBattery.isHidden = false
        //imageBattery.image = #imageLiteral(resourceName: "redbat")
        //showmessage(message: "Bateria \(bpm)", controller: self)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        //FE:FF:9F:14:77:B9
        //337CDE11-9C12-FD5B-5759-CFFC78AAFCC6
        /*
        print(error)
        print("....")
        print(characteristic)
        print(characteristic.hashValue)
        //print(characteristic.uuid)
        print("---")
        print(peripheral)
        
        let cadena = "10778493696".description.data(using: .utf8) //characteristic.hash
        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(cadena!.count * 2)

        for byte in cadena! {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.insert(hexDigits[index2], at: 0)
            hexChars.insert(hexDigits[index1], at: 0)
        }
        
        let mac_address = String(utf16CodeUnits: hexChars, count: hexChars.count).uppercased()
        let macAddress = mac_address.separate(every: 2, with: ":")
        print("MAC_ADDRESS: \(macAddress)")
        */
        /*let mac_address = peripheral..hexEncodedString().uppercased()
        //{
        let macAddress = mac_address!.separate(every: 2, with: ":")
            print("MAC_ADDRESS: \(macAddress)")
        //}*/
    }
    
    /*func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print(central.state.rawValue)
        
        if (central.state == .poweredOn){
            print("ble on...session")
            //self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
            rookmotionSensor = rockmotion.peri
            rookmotionSensor.delegate = self
            rookmotionSensor.discoverServices(
                [heartRateServiceCBUUID,batteryServiceCBUUID]
            )
        }
        else {
            // do something like alert the user that ble is not on
            print("BLE off")
        }
    }*/
    
/*
¿¿¿===========================================================
 */
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
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "photoShare"{
            let vc = segue.destination as! PhotoViewController
            vc.sesion = sender as? Photoshare            
        }
        
        if segue.identifier == "showGraficas"{
            let vc = segue.destination as! ResumeMainViewController
            vc.sesionRock = sender as? Sesion
        }
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
