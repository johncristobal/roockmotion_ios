//
//  TokenViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/18/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit

class TokenViewController: UIViewController {

    @IBOutlet var tokenTest: UITextField!
    @IBOutlet var backArrow: UIImageView!
    @IBOutlet var sendButton: UIButton!
    
    var resp: Respuesta?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tokenTest.underlined()
        sendButton.roundCorner()
        addToolBar(textField: tokenTest)

        backArrow.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backWindow))
        backArrow.addGestureRecognizer(gesture)
    }
    
    @objc func backWindow(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendAgainAction(_ sender: Any) {
    }
    
    @IBAction func sendFinalAction(_ sender: Any) {

        if tokenTest.text == ""{
            showmessage(message: "Coloca el token de validación que llego a tu correo", controller: self)
        }else{
            let id = (resp?.id)!
            let token = tokenTest.text
            let alertaloadingtoken = UIAlertController(title: nil, message: "Sincronizando...", preferredStyle: .alert)
            
            alertaloadingtoken.view.tintColor = UIColor.black
            //CGRect(x: 1, y: 5, width: self.view.frame.size.width - 20, height: 120))
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating();
            
            alertaloadingtoken.view.addSubview(loadingIndicator)
            present(alertaloadingtoken, animated: true, completion: nil)
            
            let manager = DataManager.shared
            manager.validateToken(idUsuario: id, codigo: token!) { (response) in
                DispatchQueue.main.async {
                    alertaloadingtoken.dismiss(animated: true, completion: {
                        
                        //temp
                        //UserDefaults.standard.set("1", forKey: "sesion")
                        //self.performSegue(withIdentifier: "tutorial", sender: response.id)
                        
                        switch response.resp{
                        case "error":
                            self.showAlerta(message: "Error al sincronizarte. Contacta a roockmotion para mayor informaciòn")
                            break
                        case "error | errors":
                            self.showAlerta(message: response.mes)
                            break
                        case "ok":
                            let refreshAlert = UIAlertController(title: "", message: response.mes, preferredStyle: UIAlertController.Style.alert)
                            
                            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in

                                UserDefaults.standard.set("1", forKey: "sesion")
                                let userDefaults = UserDefaults.standard
                                manager.user?.tok = response.id
                                let encodedData: Data =  NSKeyedArchiver.archivedData(withRootObject: manager.user)
                                userDefaults.set(encodedData, forKey: "user")
                                userDefaults.set("1", forKey: "sesion")                            
                                userDefaults.synchronize()
                                
                                self.performSegue(withIdentifier: "tutorial", sender: response.id)
                                
                            }))
                            self.present(refreshAlert, animated: true)
                            break
                        default:
                            let refreshAlert = UIAlertController(title: "Atención.", message: response.mes, preferredStyle: UIAlertController.Style.alert)
                            
                            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                                
                            }))
                            
                            self.present(refreshAlert, animated: true)
                            
                            break
                        }
                    })
                }
            }
        }
    }
    
/*********************** launch polizas***********************/
    func showAlerta(message: String){
        let refreshAlert = UIAlertController(title: "Atención.", message: message, preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true)
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
