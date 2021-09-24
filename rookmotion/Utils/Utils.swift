//
//  Utils.swift
//  rockmotion
//
//  Created by i7 on 6/14/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import SystemConfiguration

var loading : UIAlertController?
var graficasData : FromData?

class CustomSlider : UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 4
        return newBounds
    }
}

//function to show toast
func showmessage(message: String, controller: UIViewController){
    
    controller.view.makeToast(message ,duration:2.0, position: .center)
}

func showLoading(controller: UIViewController, title: String, message: String){
    loading = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    loading!.view.tintColor = UIColor.black
    //CGRect(x: 1, y: 5, width: self.view.frame.size.width - 20, height: 120))
    let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = UIActivityIndicatorView.Style.gray
    loadingIndicator.startAnimating();
    
    loading!.view.addSubview(loadingIndicator)
    controller.present(loading!, animated: true, completion: nil)
}

enum Periodo: Int {
    case semana = 1, mes = 2, semestre = 3, anio = 4
}

enum ModoContador: Int {
    case arriba = 1, abajo = 2
}

enum Step: Int {
    case share = 1, resumen = 2
}

enum FromData: Int {
    case sesionActiva = 1, dashBoard = 2, finSesion = 3
}

func getTimeFromDuration(durationSesion: Int) -> NSString {
    let seconds = durationSesion % 60
    let minutes = (durationSesion / 60) % 60
    let hours = (durationSesion / 3600)
    let lastDuration = NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    
    return lastDuration
}

func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
        return false
    }
    
    /* Only Working for WIFI
     let isReachable = flags == .reachable
     let needsConnection = flags == .connectionRequired
     
     return isReachable && !needsConnection
     */
    
    // Working for Cellular and WIFI
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    let ret = (isReachable && !needsConnection)
    
    return ret
    
}
