//
//  BLEManager.swift
//  RookMotion
//
//  Created by i7 on 03/11/19.
//  Copyright © 2019 RookMotion. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager: CBCentralManagerDelegate, CBPeripheralDelegate {
   
    var hash: Int = 0
    
    var superclass: AnyClass?
    let periperalNoti = Notification.Name("periferico")
    let startSession = Notification.Name("startSession")
    let re_startSession = Notification.Name("re_startSession")

    var description: String = ""
    static let sharedBle = BLEManager()
    var centralManager: CBCentralManager?
    var rookmotionSensor: CBPeripheral?
    let serviceUUIDs:[CBUUID] = [CBUUID(string: "180D")] //0x180D

    var banderaReconectar = false
    
    private init(){
        
    }
    
    func startConnecting(){
        self.centralManager = CBCentralManager.init(delegate: self, queue: nil)
        self.centralManager?.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            print("ble on...scanning devices manager")
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
        
        let imageDataDict:[String: CBPeripheral] = ["peripheral": peripheral]
        NotificationCenter.default.post(name: periperalNoti, object: nil, userInfo: imageDataDict)
    }
    
    func conectarPeriferico(peripheral: CBPeripheral){
        print("conectar")
        centralManager!.stopScan()
        centralManager!.connect(peripheral, options: nil)
    }
    
    func reconectar(peripheral: CBPeripheral){
        print("re---conectar")
        centralManager!.stopScan()
        centralManager!.connect(peripheral, options: nil)
    }
    
    func detenerBusqueda(){
        centralManager!.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("conectado desde peri")
        if banderaReconectar{
            banderaReconectar = false
            NotificationCenter.default.post(name: re_startSession, object: nil)

        }else{
            NotificationCenter.default.post(name: startSession, object: nil)
        }
    }
    
    func desconectarPeriferico(){
        centralManager?.cancelPeripheralConnection(self.rookmotionSensor!)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("desconectaando desde devices...")
    }

    func isEqual(_ object: Any?) -> Bool {
        return true
   }
   
   
   func `self`() -> Self {
       return self
   }
   
   func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        let data: Unmanaged<AnyObject>? = nil
        return data
   }
   
   func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
       let data: Unmanaged<AnyObject>? = nil
       return data
   }
   
   func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
       let data: Unmanaged<AnyObject>? = nil
       return data
   }
   
   func isProxy() -> Bool {
       return true
   }
   
   func isKind(of aClass: AnyClass) -> Bool {
       return true
   }
   
   func isMember(of aClass: AnyClass) -> Bool {
       return true
   }
   
   func conforms(to aProtocol: Protocol) -> Bool {
       return true
   }
   
   func responds(to aSelector: Selector!) -> Bool {
       return true
   }

}
