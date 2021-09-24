//
//  DevicesViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/13/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var peripherals = Array<CBPeripheral>()
    var peripheralsMatch = Array<CBPeripheral>()
    var rockmotionPeripheral: CBPeripheral!
    var centralManager: CBCentralManager?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableViewMyDevices: UITableView!
    
    var myArrayBLEDevices : [Devices]? = []
    var myArrayBLEDevicesName : [String]? = []
    var loadingSesiones : UIAlertController?
    let serviceUUIDs:[CBUUID] = [CBUUID(string: "180D")] //0x180D
    
    var tempStringDevicesBLE: [String] = []
    private let refreshControl = UIRefreshControl()
    
    var blemanager: BLEManager?
    let periperalNoti = Notification.Name("periferico")
    let startSession = Notification.Name("startSession")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.centralManager = CBCentralManager.init(delegate: self, queue: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(periperalNoti(_:)), name: periperalNoti, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startSession(_:)), name: startSession, object: nil)

        blemanager = BLEManager.sharedBle
        UIApplication.shared.isIdleTimerDisabled = true

    }

    override func viewDidAppear(_ animated: Bool) {
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        
        getMyDevices()
        
        //performSegue(withIdentifier: "playSesion", sender: nil)
    }
    
    @objc func refreshWeatherData(_ sender: Any){
        print("buscando refresh...")
        self.refreshControl.endRefreshing()
        //self.centralManager!.scanForPeripherals(withServices: serviceUUIDs, options: nil)
    }
    
    func getMyDevices(){
        showLoading(titulo: "Información", mensaje: "Recuperando dispositivos usuario..")
        let manager = DataManager.shared
        manager.sensorsList { (resp) in
            switch resp.resp {
            case "ok":
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        self.myArrayBLEDevices = manager.arrayMyDevices
                        self.tableViewMyDevices.reloadData()
                        
                        //guardamos una lista de nombres...
                        for item in self.myArrayBLEDevices!{
                            self.myArrayBLEDevicesName?.append(item.name)
                        }
                        
                        //central manager bluetooth
                        self.blemanager?.startConnecting()

                        //self.centralManager = CBCentralManager.init(delegate: self, queue: nil)
                        //self.centralManager?.delegate = self
                        //self.centralManager!.scanForPeripherals(withServices: serviceUUIDs, options: nil)

                        /*let listaConnected = self.centralManager?.retrieveConnectedPeripherals(withServices: self.serviceUUIDs)
                        print(listaConnected)
                        //let listaConnected = self.centralManager?.retrievePeripherals(withIdentifiers: self.serviceUUIDs)

                        listaConnected?.forEach({ (peripheral) in
                            if !self.tempStringDevicesBLE.contains(peripheral.name!){
                                
                                //antes de mostrarlo en esta lista, checamos si esta en la otra...
                                let indice = self.getIndice(peri: peripheral.name!)
                                if  indice != -1{
                                //if (myArrayBLEDevicesName?.contains(peripheral.name!))!{
                                    //let index = myArrayBLEDevicesName?.firstIndex(of: peripheral.name!)
                                    self.myArrayBLEDevices![indice].active = true
                                    self.tableViewMyDevices.reloadData()

                                    //a ver y si los vamos guardando...
                                    self.peripheralsMatch.append(peripheral)
                                    
                                }else{
                                    self.tempStringDevicesBLE.append(peripheral.name!)
                                    self.peripherals.append(peripheral)
                                    self.tableView.reloadData()
                                }
                            }
                        })*/
                    }
                )}
                break
                
            default:
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        showmessage(message: resp.mes, controller: self)
                        
                        //central manager bluetooth
                        //self.centralManager = CBCentralManager(delegate: self, queue: nil)
                        }
                    )}
                break
            }
        }
    }
    
/*
 BLE methods
 /////////////////////////////////////////////////////////////////////////
*/
    @objc func periperalNoti(_ notification: NSNotification){
        print("notificatino devics")
        if (notification.userInfo?["peripheral"] as? CBPeripheral) != nil {
            // do something with your image
            let peripheral = notification.userInfo?["peripheral"] as! CBPeripheral
            print(peripheral.name!)
            if peripheral.name != nil {
                if peripheral.name != "" {
                    //para quie no se repita la lista, porque al buscar salen muchas veces...
                    if !tempStringDevicesBLE.contains(peripheral.name!) {
                        
                        //antes de mostrarlo en esta lista, checamos si esta en la otra...
                        let indice = getIndice(peri: peripheral.name!)
                        if  indice != -1 {
                        //if (myArrayBLEDevicesName?.contains(peripheral.name!))!{
                            //let index = myArrayBLEDevicesName?.firstIndex(of: peripheral.name!)
                            myArrayBLEDevices![indice].active = true
                            self.tableViewMyDevices.reloadData()

                            //a ver y si los vamos guardando...
                            peripheralsMatch.append(peripheral)
                            
                        }else{
                            tempStringDevicesBLE.append(peripheral.name!)
                            peripherals.append(peripheral)
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    /*func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state{
        case .poweredOn:
            print("ble on...scanning devices")
            self.centralManager!.scanForPeripherals(withServices: serviceUUIDs, options: nil)
            break
        case .poweredOff:
            print("off")
            break
        case .resetting:
            print("resset")
            break
        case .unauthorized:
            print("unauht")
            break
        case .unknown:
            print("unk")
            break
        case .unsupported:
            print("unsippp")
            break
        default: break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name)
        
        // look for devices and append to tableview
        if peripheral.name != nil {
            if peripheral.name != "" {
                //para quie no se repita la lista, porque al buscar salen muchas veces...
                if !tempStringDevicesBLE.contains(peripheral.name!) {
                    
                    //antes de mostrarlo en esta lista, checamos si esta en la otra...
                    let indice = getIndice(peri: peripheral.name!)
                    if  indice != -1 {
                    //if (myArrayBLEDevicesName?.contains(peripheral.name!))!{
                        //let index = myArrayBLEDevicesName?.firstIndex(of: peripheral.name!)
                        myArrayBLEDevices![indice].active = true
                        self.tableViewMyDevices.reloadData()

                        //a ver y si los vamos guardando...
                        peripheralsMatch.append(peripheral)
                        
                    }else{
                        tempStringDevicesBLE.append(peripheral.name!)
                        peripherals.append(peripheral)
                        tableView.reloadData()
                    }
                }
            }
        }
    }*/
    
    func getIndice(peri: String) -> Int{
        
        var indice = 0
        //corroborar que hay elementos en mi lista
        if myArrayBLEDevicesName!.count > 0{
        for item in myArrayBLEDevicesName!{
            
            //let cut = item.index(item.startIndex, offsetBy: 4)
            //let cad1 = String(item[...cut])
            let cad1 = String(item.suffix(5))
            
            //let cutPeri = peri.index(peri.startIndex, offsetBy: 4)
            //let cad2 = String(peri[...cutPeri])
            let cad2 = String(peri.suffix(5))

            //si esta, regresa indice
            if cad1 == cad2{
                return indice
            }
            
            indice += 1
        }
        
        return -1
        }else{
            return -1
        }
    }
    
    /*func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //when connect to device
        print("conectado!")
        //centralManager = nil
        let blue = Blue(peri: rockmotionPeripheral, text: "")
        performSegue(withIdentifier: "playSesion", sender: blue)
        //showmessage(message: "Conectado", controller: self)
        //showButtons()
        
        //rockmotion.peri.discoverServices(
        //    [heartRateServiceCBUUID,batteryServiceCBUUID]
        //)
    }*/
        
    @objc func startSession(_ notification: NSNotification){
        
        performSegue(withIdentifier: "playSesion", sender: nil)
    }
    
/*
Table methods
//////////////////////////////////////////////////////////////////////////////////
*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //mid dispositivos
        if tableView == tableViewMyDevices{
            let cell = tableView.dequeueReusableCell(withIdentifier: "celldevice") as! DeviceTableViewCell
            
            let peripheral = myArrayBLEDevices![indexPath.row].name
            cell.nameText.text = peripheral
            cell.imageHeart.isHidden = !myArrayBLEDevices![indexPath.row].active
            
            if !myArrayBLEDevices![indexPath.row].active{
                cell.nameText.textColor = UIColor.lightGray
            }else{
                cell.nameText.textColor = UIColor.black
            }
            
            return cell
        }
        else if tableView == self.tableView{
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "newdevices") as! DevicesNewTableViewCell
            
            let peripheral = peripherals[indexPath.row]
            cell.textLabel?.text = peripheral.name
            cell.textLabel?.textColor = UIColor.black
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellblue") as! DeviceTableViewCell
            
            let peripheral = myArrayBLEDevices![indexPath.row].name
            cell.nameText.text = peripheral
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*
         TODO: borrar esta linea de performSegue y descomentar todo lo anterior
         */
        performSegue(withIdentifier: "playSesion", sender: nil)
        
//        if tableView == tableViewMyDevices{
//
//            let name = myArrayBLEDevices![indexPath.row].name
//            let manager = DataManager.shared
//            manager.sensorId = myArrayBLEDevices![indexPath.row].id
//
//            for item in peripheralsMatch{
//                //tomas el item que es igual y lo conectas al ble
//                if getIndiceMatch(peri: item.name!, name: name) != -1 {
//
//                //if item.name?.description == name.description {
//                    //rockmotionPeripheral = item
//                    //centralManager!.connect(rockmotionPeripheral, options: nil)
//                    blemanager!.rookmotionSensor = item
//                    blemanager?.conectarPeriferico(peripheral: item)
//
//                    break
//                }
//            }
//        //tabla de abajo
//        }else if tableView == self.tableView{
//
//            let peri = peripherals[indexPath.row]
//            let manager = DataManager.shared
//
//            if isConnectedToNetwork(){
//            //antes de conectar...tenemos que mandarlo al servicio para guardarlo...
//
//            manager.sensorsAdd(name: peri.name!, mac: "") { (resp) in
//                switch resp.resp{
//                case "ok":
//                    //cponectamos al ble
//                    let id = resp.id
//                    manager.sensorId = Int(id)! //myArrayBLEDevices![indexPath.row].id
//
//                    //self.rockmotionPeripheral = peri
//                    //self.centralManager!.connect(self.rockmotionPeripheral, options: nil)
//                    self.blemanager!.rookmotionSensor = peri
//                    self.blemanager?.conectarPeriferico(peripheral: peri)
//
//                    break
//                default:
//                    showmessage(message: resp.mes, controller: self)
//                    break
//                }
//            }
//            } else {
//                manager.sensorId = 1 //myArrayBLEDevices![indexPath.row].id
//                self.blemanager!.rookmotionSensor = peri
//                self.blemanager?.conectarPeriferico(peripheral: peri)
//                //self.rockmotionPeripheral = peri
//                //self.centralManager!.connect(self.rockmotionPeripheral, options: nil)
//            }
//        }
    }
    
    func getIndiceMatch(peri: String, name:String) -> Int{
        
        var indice = 0
    
        //let cut = name.index(name.startIndex, offsetBy: 4)
        //let cad1 = String(name[...cut])
        let cad1 = String(name.suffix(5))
        
        //let cutPeri = peri.index(peri.startIndex, offsetBy: 4)
        //let cad2 = String(peri[...cutPeri])
        let cad2 = String(peri.suffix(5))

        //si esta, regresa indice
        if cad1 == cad2{
            return indice
        }else{
            return -1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if tableView == tableViewMyDevices{
            return myArrayBLEDevices!.count
         }else if tableView == self.tableView{
            return peripherals.count
        }
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    @IBAction func searchAction(_ sender: Any) {
       
        print("buscando actiuon...")
        //self.centralManager!.scanForPeripherals(withServices: serviceUUIDs, options: nil)
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /*if segue.identifier == "playSesion"{
            let vc = segue.destination as! SesionRockViewController
            vc.rockmotion = sender as! Blue
        }*/
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

//****************************------------------------------------------
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
