//
//  DispositivosViewController.swift
//  rockmotion
//
//  Created by i7 on 9/5/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import SafariServices

class DevicesMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sellDevices: UITableView!
    @IBOutlet weak var myDevices: UITableView!
    
    var sellArrayDevices : [Devices]? = []
    var myArrayDevices : [Devices]? = []
    var loadingSesiones : UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //let gesture = UIGestureRecognizer(target: self, action: #selector(backWindowAction))
        //backWindow.isUserInteractionEnabled = true
        //backWindow.addGestureRecognizer(gesture)
        
        let device1 = Devices(id: -1, name: "RookMotion Sensor Brazo", price: "1,699", mac: "", brand: "", active: true)
        let device2 = Devices(id: -1, name: "RookMotion Sensor Pecho", price: "1,499", mac: "", brand: "", active: true)
        
        sellArrayDevices?.append(device1)
        sellArrayDevices?.append(device2)
    }

    override func viewDidAppear(_ animated: Bool) {
        getMyDevices()
    }
    
    
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func getMyDevices(){
        showLoading(titulo: "Información", mensaje: "Listando sesiones...")

        let manager = DataManager.shared
        manager.sensorsList { (resp) in
            switch resp.resp {
            case "ok":
                
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        self.myArrayDevices = manager.arrayMyDevices
                        self.myDevices.reloadData()
                    }
                    )}
                break
                
            default:
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        showmessage(message: resp.mes, controller: self)
                    }
                    )}
                break
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == sellDevices{
            return sellArrayDevices!.count
        }
        if tableView == myDevices{
            return myArrayDevices!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == sellDevices{
            let cell = tableView.dequeueReusableCell(withIdentifier: "celdaVenta") as! DevicesSellTableViewCell

            cell.nameDevice.text = sellArrayDevices![indexPath.row].name
            cell.priceDevice.text = "$ \(sellArrayDevices![indexPath.row].price)"
            cell.priceDevice.roundCornerRed()

            return cell
        }
        if tableView == myDevices{
            let cell = tableView.dequeueReusableCell(withIdentifier: "celdaMios") as! DevicesSelfTableViewCell
            
            cell.nameDevice.text = myArrayDevices![indexPath.row].name
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "") as! DevicesSellTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == sellDevices{
            
            let item = sellArrayDevices![indexPath.row].name
            if item.contains("Brazo"){
                //https://rookmotion.com/producto/sensor-de-brazo.html
                if let liga = URL(string: "https://rookmotion.com/producto/sensor-de-brazo.html") {
                    let svc = SFSafariViewController(url: liga)
                    present(svc, animated: true, completion: nil)
                }
            }else if item.contains("Pecho"){
                //https://rookmotion.com/producto/sendor-de-pecho.html
                if let liga = URL(string: "https://rookmotion.com/producto/sendor-de-pecho.html") {
                    let svc = SFSafariViewController(url: liga)
                    present(svc, animated: true, completion: nil)
                }
            }else{
                if let liga = URL(string: "https://rookmotion.com/productos.html") {
                    let svc = SFSafariViewController(url: liga)
                    present(svc, animated: true, completion: nil)
                }
            }
        }
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
