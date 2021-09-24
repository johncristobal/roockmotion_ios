//
//  DashboardViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/19/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import CoreData

class DashboardViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var cameraImage: UIImageView!
    @IBOutlet var sessionImage: UIImageView!
    @IBOutlet weak var tableViewSesiones: UITableView!
    
    @IBOutlet weak var labelLoadingSessions: UILabel!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var nameLabelUser: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var searchImage: UIImageView!
    @IBOutlet var periodLabel: UILabel!
    
    @IBOutlet var actualRewards: UILabel!
    @IBOutlet var periodRewards: UILabel!
    @IBOutlet var levelRewards: UIImageView!
    @IBOutlet var updownRewards: UILabel!
    //@IBOutlet var sliderRewards: UISlider!
    @IBOutlet var sliderRewards: CustomSlider!
    
    @IBOutlet var actualLost: UILabel!
    @IBOutlet var periodLost: UILabel!
    @IBOutlet var levelLost: UIImageView!
    @IBOutlet var updownLost: UILabel!
    //@IBOutlet var sliderLost: UISlider!
    @IBOutlet var sliderLost: CustomSlider!
    
    @IBOutlet var actualFreq: UILabel!
    @IBOutlet var periodFreq: UILabel!
    @IBOutlet var levelFreq: UIImageView!
    @IBOutlet var updownFreq: UILabel!
    //@IBOutlet var sliderLost: UISlider!
    @IBOutlet var sliderFreq: CustomSlider!
    
    @IBOutlet var actualSesi: UILabel!
    @IBOutlet var periodSesi: UILabel!
    @IBOutlet var levelSesi: UIImageView!
    @IBOutlet var updownSesi: UILabel!
    //@IBOutlet var sliderLost: UISlider!
    @IBOutlet var sliderSesi: CustomSlider!
    
    @IBOutlet var actualPeso: UILabel!
    @IBOutlet var periodPeso: UILabel!
    @IBOutlet var levelPeso: UIImageView!
    @IBOutlet var updownPeso: UILabel!
    //@IBOutlet var sliderLost: UISlider!
    @IBOutlet var sliderPeso: CustomSlider!
    @IBOutlet weak var heightTable: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    var imagePicker: UIImagePickerController!
    var imagenFoto: UIImage?
    var flagFoto = false
    
    var user: User?
    
    var next_page = 1
    var opcionPeriodo = Periodo.mes
    var arraySesiones: [Sesion]? = []
    var manager = DataManager.shared
    var loadingSesiones : UIAlertController?
    
    var tipo = 1
    
    let changePeriodoName = Notification.Name("changePeriodo")
    let backServiceName = Notification.Name("backServiceName")
    let changeNameProfile = Notification.Name("changeNamePerfil")
    let updateDataSessiones = Notification.Name("updateDataSessiones")

    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    var updateTimer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setMenu()
        
        let gestureCamera = UITapGestureRecognizer(target: self, action: #selector(cameraButton))
        cameraImage.isUserInteractionEnabled = true
        cameraImage.addGestureRecognizer(gestureCamera)
        
        let gestureSesion = UITapGestureRecognizer(target: self, action: #selector(sesionButton))
        sessionImage.isUserInteractionEnabled = true
        sessionImage.addGestureRecognizer(gestureSesion)
                
        let gesturePerfil = UITapGestureRecognizer(target: self, action: #selector(takePhotoPerfil))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(gesturePerfil)
        
        let gestureMap = UITapGestureRecognizer(target: self, action: #selector(showMapa))
        searchImage.isUserInteractionEnabled = true
        searchImage.addGestureRecognizer(gestureMap)
        
        manager = DataManager.shared
        user = manager.user
        
        let split = user?.name.components(separatedBy: " ")
        if split!.count > 0{
            if split?.count == 1{
                nameLabelUser.text = split![0]
            }else if split!.count > 1{
                nameLabelUser.text = "\(split![0])"
            }
        }else{
            nameLabelUser.text = user?.name
        }
        profileImage.image = user?.image
        profileImage.roundCornerImage()

        NotificationCenter.default.addObserver(self, selector: #selector(changePeriodo(_:)), name: changePeriodoName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeName(_:)), name: changeNameProfile, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(callService), name: backServiceName, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateTableData), name: updateDataSessiones, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name:  UIApplication.didBecomeActiveNotification, object: nil)

        callService()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("dahsboard")

        if flagFoto{
            flagFoto = false
            //let sesion = Sesion(name: "nombre", time: timeString(time: TimeInterval(0)), image: imagenFoto!)
            //performSegue(withIdentifier: "results", sender: sesion)
        }
        print(manager.flagSesion)
        if manager.flagSesion{
            manager.flagSesion = false
            cargarDatos()
        }
    }
    
    @objc func changeName(_ notification: NSNotification){
        self.user = manager.user
        let split = user?.name.components(separatedBy: " ")
        if split!.count > 0{
            if split?.count == 1{
                nameLabelUser.text = split![0]
            }else if split!.count > 1{
                nameLabelUser.text = "\(split![0])"
            }
        }else{
            nameLabelUser.text = user?.name
        }
        
        if self.user!.peso > 999{
            self.periodPeso.text = "\((self.user!.peso/1000).description)k"
        }else{
            self.periodPeso.text = self.user!.peso.description
        }
    }
    
    @objc func changePeriodo(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary? {
            if let id = dict["periodo"] as? Periodo{
                switch id{
                case .semana:
                    opcionPeriodo = .semana
                    periodLabel.text = "SEMANA ANTERIOR"
                    cargarDatos()
                    break
                case .mes:
                    opcionPeriodo = .mes
                    periodLabel.text = "MES ANTERIOR"
                    cargarDatos()
                    break
                case .semestre:
                    opcionPeriodo = .semestre
                    periodLabel.text = "SEMESTRE ANTERIOR"
                    cargarDatos()
                    break
                case .anio:
                    opcionPeriodo = .anio
                    periodLabel.text = "AÑO ANTERIOR"
                    cargarDatos()
                    break
                }
            }
        }
    }
    
    func setMenu(){
        
        if self.revealViewController() != nil {
            
            self.revealViewController()?.rightViewRevealWidth = self.view.frame.width// - 16
            menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func cargarDatos(){
        //cargar datos de dash
        showLoading(titulo: "Información", mensaje: "Listando sesiones...")
        self.labelLoadingSessions.alpha = 0.6
        self.labelLoadingSessions.text = "Cargando sesiones..."

        self.arraySesiones?.removeAll()
        self.tableViewSesiones.reloadData()

        self.user = manager.user
        
        manager.sessionsResume(user: self.user!, perido: opcionPeriodo.rawValue) { (resp) in
            
            switch resp.resp {
            case "ok":
                let lastSession = self.manager.lastSession
                let actualSession = self.manager.actualSession

                self.getDataSesiones()
                
                DispatchQueue.main.async {
                    //self.loadingSesiones?.dismiss(animated: true, completion: {
                        
                    // Actualizamos labels de dashbaord
                    if lastSession!.RookPoints > 999{
                        self.actualRewards.text = String(format: "%.0f k", (lastSession!.RookPoints/1000))
                        //self.actualRewards.text = "\((lastSession!.RookPoints/1000).description)k"
                    }else{
                        //self.actualRewards.text = lastSession?.RookPoints.description
                        self.actualRewards.text = String(format: "%.0f", (lastSession!.RookPoints))
                    }
                    if actualSession!.RookPoints > 999{
                        self.periodRewards.text = String(format: "%.0f k", (actualSession!.RookPoints/1000))
                        //self.periodRewards.text = "\((actualSession!.RookPoints/1000).description)k"
                    }else{
                        self.periodRewards.text = String(format: "%.0f", (actualSession!.RookPoints))
                        //self.periodRewards.text = actualSession?.RookPoints.description
                    }
                    
                    if lastSession!.calorias > 999{
                        self.actualLost.text = "\((lastSession!.calorias/1000).description)k"
                    }else{
                        self.actualLost.text = lastSession?.calorias.description
                    }
                    if actualSession!.calorias > 999{
                        self.periodLost.text = "\((actualSession!.calorias/1000).description)k"
                    }else{
                        self.periodLost.text = actualSession?.calorias.description
                    }
                    
                    if lastSession!.frecuencia > 999{
                        self.actualFreq.text = "\((lastSession!.frecuencia/1000).description)k"
                    }else{
                        self.actualFreq.text = lastSession?.frecuencia.description
                    }
                    if actualSession!.frecuencia > 999{
                        self.periodFreq.text = "\((actualSession!.frecuencia/1000).description)k"
                    }else{
                        self.periodFreq.text = actualSession?.frecuencia.description
                    }
                    
                    if lastSession!.sesiones > 999{
                        self.actualSesi.text = "\((lastSession!.sesiones/1000).description)k"
                    }else{
                        self.actualSesi.text = lastSession?.sesiones.description
                    }
                    if actualSession!.sesiones > 999{
                        self.periodSesi.text = "\((actualSession!.sesiones/1000).description)k"
                    }else{
                        self.periodSesi.text = actualSession?.sesiones.description
                    }
                    
                    if lastSession!.peso > 999{
                        self.actualPeso.text = "\((lastSession!.peso/1000).description)k"
                    }else{
                        self.actualPeso.text = lastSession?.peso.description
                    }
                    if actualSession!.peso > 999{
                        self.periodPeso.text = "\((actualSession!.peso/1000).description)k"
                    }else{
                        self.periodPeso.text = actualSession?.peso.description
                    }
                    
                        //self.actualLost.text = anterior?.calorias.description
                        //self.periodLost.text = actual?.calorias.description
                        
                        //self.actualFreq.text = anterior?.frecuencia.description
                        //self.periodFreq.text = actual?.frecuencia.description
                        
                        //self.actualSesi.text = anterior?.sesiones.description
                        //self.periodSesi.text = actual?.sesiones.description
                        
                        //self.actualPeso.text = anterior?.peso.description
                        //self.periodPeso.text = actual?.peso.description
                        
                        // Actualizamos triangulitos
                        var resultado = 0.0
                        /* Rewards */
                        if actualSession!.RookPoints > lastSession!.RookPoints{
                            resultado = Double(actualSession!.RookPoints  - lastSession!.RookPoints)
                            if(resultado < 1000){
                                let resTemp = Int(resultado / 1)
                                self.updownRewards.text = resTemp.description
                            }else{
                                let resTemp = Int(resultado / 1000)
                                self.updownRewards.text = "\(resTemp.description)k"
                            }
                            self.levelRewards.image = #imageLiteral(resourceName: "greentri")
                            
                        }else{
                           resultado = Double(lastSession!.rewards  - actualSession!.rewards)
                            if(resultado < 1000){
                               let resTemp = Int(resultado / 1)
                               self.updownRewards.text = resTemp.description
                            }else{
                                let resTemp = Int(resultado / 1000)
                                self.updownRewards.text = "\(resTemp.description)k"
                            }
                            self.levelRewards.image = #imageLiteral(resourceName: "redtri")
                        }
                        
                        /* Calorias */
                        if actualSession!.calorias > lastSession!.calorias{
                            resultado = Double(actualSession!.calorias  - lastSession!.calorias)
                            if(resultado < 1000){
                                let resTemp = Int(resultado / 1)
                                self.updownLost.text = resTemp.description
                            }else{
                                let resTemp = Int(resultado / 1000)
                                self.updownLost.text = "\(resTemp.description)k"
                            }
                            self.levelLost.image = #imageLiteral(resourceName: "greentri")
                            
                        }else{
                            resultado = Double(lastSession!.calorias  - actualSession!.calorias)
                            if(resultado < 1000){
                                let resTemp = Int(resultado / 1)
                                self.updownLost.text = resTemp.description
                            }else{
                                let resTemp = Int(resultado / 1000)
                                self.updownLost.text = "\(resTemp.description)k"
                            }
                            self.levelLost.image = #imageLiteral(resourceName: "redtri")
                        }
                        
                        /* Frecuencia */
                        if actualSession!.frecuencia > lastSession!.frecuencia{
                            resultado = Double(actualSession!.frecuencia  - lastSession!.frecuencia)
                            if(resultado < 1000){
                                let resTemp = Int(resultado / 1)
                                self.updownFreq.text = resTemp.description
                            }else{
                                let resTemp = Int(resultado / 1000)
                                self.updownFreq.text = "\(resTemp.description)k"
                            }
                            self.levelFreq.image = #imageLiteral(resourceName: "greentri")
                            
                        }else{
                            resultado = Double(lastSession!.frecuencia  - actualSession!.frecuencia)
                            if(resultado < 1000){
                                let resTemp = Int(resultado / 1)
                                self.updownFreq.text = resTemp.description
                            }else{
                                let resTemp = Int(resultado / 1000)
                                self.updownFreq.text = "\(resTemp.description)k"
                            }
                            self.levelFreq.image = #imageLiteral(resourceName: "redtri")
                        }
                        
                        /* SAesiones */
                        if actualSession!.sesiones > lastSession!.sesiones{
                            resultado = Double(actualSession!.sesiones  - lastSession!.sesiones)
                            if(resultado < 1000){
                                let resTemp = Int(resultado / 1)
                                self.updownSesi.text = resTemp.description
                            }else{
                                let resTemp = Int(resultado / 1000)
                                self.updownSesi.text = "\(resTemp.description)k"
                            }
                            self.levelSesi.image = #imageLiteral(resourceName: "greentri")
                            
                        }else{
                            resultado = Double(lastSession!.sesiones  - actualSession!.sesiones)
                            if(resultado < 1000){
                                let resTemp = Int(resultado / 1)
                                self.updownSesi.text = resTemp.description
                            }else{
                                let resTemp = Int(resultado / 1000)
                                self.updownSesi.text = "\(resTemp.description)k"
                            }
                            self.levelSesi.image = #imageLiteral(resourceName: "redtri")
                        }
                        
                        /* Peso */
                        if actualSession!.peso > lastSession!.peso{
                            resultado = Double(actualSession!.peso  - lastSession!.peso)
                            if(resultado < 1000){
                                self.updownPeso.text = resultado.description
                            }else{
                                let resTemp = resultado / 1000
                                self.updownPeso.text = "\(resTemp.description)k"
                            }
                            self.levelPeso.image = #imageLiteral(resourceName: "greentri")
                            
                        }else{
                            resultado = Double(lastSession!.peso  - actualSession!.peso)
                            if(resultado < 1000){
                                self.updownPeso.text = resultado.description
                            }else{
                                let resTemp = resultado / 1000
                                self.updownPeso.text = "\(resTemp.description)k"
                            }
                            self.levelPeso.image = #imageLiteral(resourceName: "redtri")
                        }
                        
                        // Actualizamos progress
                        self.sliderRewards.setValue(Float(self.getPorcent(valor1: Double(actualSession!.RookPoints), valor2: Double(lastSession!.RookPoints))), animated: true)
                        
                        self.sliderLost.setValue(Float(self.getPorcent(valor1: Double(actualSession!.calorias), valor2: Double(lastSession!.calorias))), animated: true)
                        
                        self.sliderFreq.setValue(Float(self.getPorcent(valor1: Double(actualSession!.frecuencia), valor2: Double(lastSession!.frecuencia))), animated: true)
                        
                        self.sliderSesi.setValue(Float(self.getPorcent(valor1: Double(actualSession!.sesiones), valor2: Double(lastSession!.sesiones))), animated: true)
                        
                        self.sliderPeso.setValue(Float(self.getPorcent(valor1: Double(actualSession!.peso), valor2: Double(lastSession!.peso))), animated: true)
                    //})
                }
                break
            default:
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                            showmessage(message: resp.mes, controller: self)
                        }
                    )}
                break;
            }
        }
        //cargar sesiones
    }
    
    override func viewDidLayoutSubviews() {
        self.tableViewSesiones.frame = CGRect(x: self.tableViewSesiones.frame.origin.x, y: self.tableViewSesiones.frame.origin.y, width: self.tableViewSesiones.frame.size.width, height: self.tableViewSesiones.contentSize.height)
        
        self.heightTable.constant = self.tableViewSesiones.contentSize.height
        //use the value of constant as required.

        self.tableViewSesiones.reloadData()
    }
    
    func getDataSesiones(){

        self.user = manager.user

        manager.sessionsList(user: self.user!, perido: opcionPeriodo.rawValue, page: next_page) { (resp) in
            switch resp.resp {
            case "ok":
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        
                        self.arraySesiones = self.manager.arraySessions
                        print("sesiones: \(self.arraySesiones?.count)")
                        
                        self.tableViewSesiones.rowHeight = UITableView.automaticDimension
                        self.tableViewSesiones.estimatedRowHeight = 140.0
                        DispatchQueue.main.async {

                            self.tableViewSesiones.frame = CGRect(x: self.tableViewSesiones.frame.origin.x, y: self.tableViewSesiones.frame.origin.y, width: self.tableViewSesiones.frame.size.width, height: self.tableViewSesiones.contentSize.height)
                            
                            self.heightTable.constant = self.tableViewSesiones.contentSize.height
                            //use the value of constant as required.

                            self.heightTable.constant = CGFloat((self.arraySesiones!.count) * 140)
                            self.tableViewSesiones.reloadData()
                            self.tableViewSesiones.invalidateIntrinsicContentSize()
                        
                        var contentRect = CGRect.zero
                        for view in self.contentView.subviews {
                            contentRect = contentRect.union(view.frame)
                        }
                        self.contentView.frame.size = contentRect.size
                        self.scrollView.contentSize = contentRect.size
                        
                        /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.scrollView.contentSize = self.contentView.subviews.reduce(CGRect(), { $0.union($1.frame) }).size
                            self.view.updateConstraintsIfNeeded()
                            self.tableViewSesiones.reloadData()

                        }*/
                        }
                        print("uploades data table")
                    }
                )}
                break
            default:
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        showmessage(message: resp.mes, controller: self)
                        }
                    )}
                break;
            }
        }
    }
    
    func getPorcent(valor1: Double, valor2: Double) -> Double{
        if(valor1 > valor2){
            if(valor2 > 0) {
                let porcentaje = (valor2 * 100) / valor1
                let temp = (50 - (100 - porcentaje)) / 100.0
                return temp
            }else{
                return 0
            }
        }else{
            if(valor2 > valor1){
                if(valor1 > 0) {
                    let porcentaje = (valor1 * 100) / valor2
                    let temp = (50 + (100 - porcentaje)) / 100.0
                    return temp
                }else{
                    return 1;
                }
            }else{
                return 0.5;
            }
        }
    }

    
    @objc func sesionButton(){
        //open camera to take photo
        if perfilCompleto(){
            performSegue(withIdentifier: "blueconnect", sender: nil)
        }else{
            let alert = UIAlertController(title: "", message: "Es necesario completar la información de tu perfil para iniciar sesiones de entrenamiento.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Completar perfil", style: .default, handler: { (alert) in
                
                self.performSegue(withIdentifier: "perfilSegueFull", sender: nil)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { (alert) in
                
            }))

            present(alert, animated: true)
            
            //alert * Es necesario completar la información de tu perfil para iniciar sesiones de entrenamiento
        }
    }
    
    func perfilCompleto() -> Bool {
        let user = manager.user
        
        if user?.pseudonym == ""{
            return false
        }
        if user?.birthday == ""{
            return false
        }
        if user?.phone == ""{
            return false
        }
        if user?.sexo == ""{
            return false
        }
        if user?.peso == 0.0{
            return false
        }
        if user?.estatura == 0{
            return false
        }
        
        return true
    }

//MARK: - Captura de foto...
    @objc func takePhotoPerfil(){
        //open camera to take photo perfil
        print("seleccionar si foto o camara" )
        abrirAlertaFoto()
    }
    
    @objc func showMapa(){
        //open camera to take photo perfil
        print("showmapa" )
        performSegue(withIdentifier: "mapSegue", sender: nil)
    }
    
    func abrirAlertaFoto(){
        let alerta = UIAlertController(title: "Actualiza tu imagen de perfil...", message: "", preferredStyle: .actionSheet)
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
            //flagFoto = true
            if self.imagenFoto != nil{
                self.profileImage.image = self.imagenFoto
                self.sendFotoServer()
            }
        })
    }
    
    func sendFotoServer(){
        
        user?.image = self.imagenFoto!

        //guardamos la foto del usuario y lo almacenamos en userdefaults
        guardarUsuario()
        deleteData()
        saveCoreUser(user: user!)
        
        showLoading(titulo: "Establecer foto", mensaje: "Enviando información...")
        manager.UserPhotoCameraUp(imagen: self.imagenFoto!) { (resp) in
            
            DispatchQueue.main.async {
                self.loadingSesiones?.dismiss(animated: true, completion: {
                    switch resp.resp{
                    case "ok":
                        self.showAlert(titulo: "Gracias", mensaje: resp.mes)
                        break
                    default:
                        showmessage(message: resp.mes, controller: self)
                        break
                    }
                }
            )}
        }
    }
    
    func guardarUsuario(){
        /*let userDefaults = UserDefaults.standard
        let encodedData: Data =  NSKeyedArchiver.archivedData(withRootObject: self.user)
        userDefaults.set(encodedData, forKey: "user")
        userDefaults.synchronize()*/
    }
    
    func deleteData(){
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
                    //let datjson = data.value(forKeyPath: "json") as? String
                    //let id = data.value(forKeyPath: "id") as? String
                    do {
                       try managedContext.delete(data)
                    } catch let error as NSError {
                       print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }else{
                print("no hay datos back...memnu user")
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveCoreUser(user: User){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "UserData", in: managedContext)!
        let sesinojson = NSManagedObject(entity: entity, insertInto: managedContext)
        
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
        
        let dataImage = user.image.jpegData(compressionQuality: 1.0)
        sesinojson.setValue(dataImage, forKeyPath: "image")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
/*================== Tabla sesiopnes ========================================= */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySesiones!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaSesion") as! DashSessionTableViewCell
        
        let sesionTemp = arraySesiones![indexPath.row]
        
        cell.trainingLabel.text = sesionTemp.labelTraining
        let calorias = sesionTemp.calories
        cell.calLabel.text = "\(calorias) kcal"
        /*
        if calorias > 999{
            let tempCalorias = Int(calorias / 1000)
            cell.calLabel.text = "\(tempCalorias) kcal"
        }else{
            cell.calLabel.text = "\(calorias) kcal"
        }
        */
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_MX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: sesionTemp.created_at)
        dateFormatter.dateFormat = "MMMM dd"
        let fianlDate = dateFormatter.string(from: date!)

        cell.dateLabel.text = fianlDate
        
        switch tipo {
        case 1:
            cell.backImage.image = #imageLiteral(resourceName: "tipo1")
            tipo += 1
            break
        case 2:
            cell.backImage.image = #imageLiteral(resourceName: "tipo2")
            tipo += 1
            break
        case 3:
            cell.backImage.image = #imageLiteral(resourceName: "tipo3")
            tipo = 1
            break
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sesionTemp = arraySesiones![indexPath.row]
        let createdat = sesionTemp.created_at
        graficasData = .dashBoard
        
        performSegue(withIdentifier: "sesionDataResumen", sender: createdat)
    }

//MARK: -Update data table
    @objc func updateTableData(){
        self.arraySesiones = self.manager.arraySessions
        self.labelLoadingSessions.alpha = 1.0
        self.labelLoadingSessions.text = "Sesiones"
        
        self.tableViewSesiones.rowHeight = UITableView.automaticDimension
        self.tableViewSesiones.estimatedRowHeight = 140.0

        DispatchQueue.main.async {

            self.tableViewSesiones.frame = CGRect(x: self.tableViewSesiones.frame.origin.x, y: self.tableViewSesiones.frame.origin.y, width: self.tableViewSesiones.frame.size.width, height: self.tableViewSesiones.contentSize.height)
            
            self.heightTable.constant = self.tableViewSesiones.contentSize.height
            //use the value of constant as required.

            self.heightTable.constant = CGFloat((self.arraySesiones!.count) * 140)
            self.tableViewSesiones.reloadData()
            self.tableViewSesiones.invalidateIntrinsicContentSize()
                
            var contentRect = CGRect.zero
            for view in self.contentView.subviews {
                contentRect = contentRect.union(view.frame)
            }
            self.contentView.frame.size = contentRect.size
            self.scrollView.contentSize = contentRect.size
            
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.scrollView.contentSize = self.contentView.subviews.reduce(CGRect(), { $0.union($1.frame) }).size
                self.view.updateConstraintsIfNeeded()
                self.tableViewSesiones.reloadData()

            }*/
        }
    }
/*
   ====================== back services ====================================
 */
    @objc func callService() {
        /*sender.isSelected = !sender.isSelected
         if sender.isSelected {
         resetCalculation()
         updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self,
         selector: #selector(calculateNextNumber), userInfo: nil, repeats: true)
         // register background task
         registerBackgroundTask()
         } else {
         updateTimer?.invalidate()
         updateTimer = nil
         // end background task
         if backgroundTask != UIBackgroundTaskInvalid {
         endBackgroundTask()
         }
         }*/
        
        updateTimer = Timer.scheduledTimer(
            timeInterval: 10,
            target: self,
            selector: #selector(checkJsonSendData),
            userInfo: nil,
            repeats: true)
        
        // register background task
        registerBackgroundTask()
    }
    
    @objc func checkJsonSendData() {
        print("enviando back")
        if isConnectedToNetwork(){
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Notwifidata")
            
            do {
                let dataSesion = try managedContext.fetch(fetchRequest)
                
                if dataSesion.count != 0 {
                    print("si hay datos back \(dataSesion.count)")
                    for data in dataSesion {
                        let datjson = data.value(forKeyPath: "json") as? String
                        //let id = data.value(forKeyPath: "id") as? String

                        self.manager.sessionsAddTaskBack(json: datjson!, completion: { (respuesta) in
                            
                            DispatchQueue.main.async {
                                //self.loadingSesiones?.dismiss(animated: true, completion: {
                                switch respuesta.resp {
                                case "ok":
                                    //eliminamos este json de la base...
                                    do {
                                        try managedContext.delete(data)
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                    break
                                default:
                                    
                                    do {
                                        try managedContext.delete(data)
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                    break
                                }
                                //})
                            }
                        })
                    }
                }else{
                    print("no hay datos back...adios")
                    // no hay datos, terminanos backservice
                    updateTimer?.invalidate()
                    updateTimer = nil
                    // end background task
                    if backgroundTask != UIBackgroundTaskIdentifier.invalid {
                        endBackgroundTask()
                    }
                }                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        
        /*let result = current.adding(previous)
        
        let bigNumber = NSDecimalNumber(mantissa: 1, exponent: 40, isNegative: false)
        if result.compare(bigNumber) == .orderedAscending {
            previous = current
            current = result
            position += 1
        } else {
            // This is just too much.... Start over.
            resetCalculation()
        }
        
        let resultsMessage = "Position \(position) = \(current)"
        //hola.text = resultsMessageç
        switch UIApplication.shared.applicationState {
        case .active:
            hola.text = resultsMessage
        case .background:
            print("App is backgrounded. Next number = \(resultsMessage)")
            print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        case .inactive:
            break
        }*/
    }
    
    func resetCalculation() {
        //previous = NSDecimalNumber.one
        //current = NSDecimalNumber.one
        //position = 1
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            //backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: "1000") { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
    
    @objc func reinstateBackgroundTask() {
        if updateTimer != nil && (backgroundTask == UIBackgroundTaskIdentifier.invalid) {
            registerBackgroundTask()
        }
    }
    
/*
     =====================Buttons action=====================================
 */
    
    @IBAction func periodoAction(_ sender: Any) {
        performSegue(withIdentifier: "periodoSegue", sender: nil)
    }
    
    @IBAction func pesoGraficaAction(_ sender: Any) {
        performSegue(withIdentifier: "pesograph", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if segue.identifier == "results"{
            let vc = segue.destination as! PhotoViewController
            vc.sesion = sender as? Sesion
        }*/
        
        if segue.identifier == "sesionDataResumen"{
            let vc = segue.destination as! ResumeMainViewController
            vc.idcreated = sender as? String
        }
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
    
    func showAlert(titulo: String, mensaje: String){
        let alertaTemp = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)

        alertaTemp.addAction(UIAlertAction(title: "ok", style: .default, handler: { (alert) in
            
        }))
        
        self.present(alertaTemp, animated: true, completion: nil)
    }
}
