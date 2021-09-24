//
//  PerfilViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/12/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import SafariServices

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var viewMail: UIView!
    @IBOutlet weak var viewusername: UIView!
    @IBOutlet weak var viewPass: UIView!
    
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var nameText: UITextField!
    @IBOutlet var namePaloma: UIImageView!
    
    @IBOutlet var emailText: UITextField!
    @IBOutlet var emailPaloma: UIImageView!
    
    @IBOutlet var userText: UITextField!
    @IBOutlet var userPaloma: UIImageView!
    
    @IBOutlet var passText: UITextField!
    @IBOutlet var passPaloma: UIImageView!
    
    @IBOutlet var backArrow: UIImageView!
    
    @IBOutlet var checkboximage: CheckBox!
    
    var user: User?
    
    var flagName = false
    var flagMail = false
    var flagUser = false
    var flagPass = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //nameText.underlined()
        //emailText.underlined()
        viewName.underlined()
        viewMail.underlined()        
        viewusername.underlined()
        viewPass.underlined()
        
        registerButton.roundCorner()
        
        //addToolBar(textField: nameText)
        //addToolBar(textField: emailText)
        //addToolBar(textField: userText)
        //addToolBar(textField: passText)
        
        backArrow.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backWindow))
        backArrow.addGestureRecognizer(gesture)
        
        userText.text = user?.name
        emailText.text = user?.email
        
        nameText.addTarget(self, action: #selector(textFieldDidChangeName(_:)), for: .editingChanged)
        emailText.addTarget(self, action: #selector(textFieldDidChangeMail(_:)), for: .editingChanged)
        userText.addTarget(self, action: #selector(textFieldDidChangeUser(_:)), for: .editingChanged)
        passText.addTarget(self, action: #selector(textFieldDidChangePass(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChangeName(_ textField: UITextField){
        let searchTerm = textField.text!
        if !validarTexto(searchTerm: searchTerm){
            namePaloma.isHidden = false
            namePaloma.image = #imageLiteral(resourceName: "error")
            flagName = false
        }else{
            namePaloma.isHidden = false
            namePaloma.image = #imageLiteral(resourceName: "check")
            flagName = true
        }
    }
    
    @objc func textFieldDidChangeMail(_ textField: UITextField) {
        
        let searchTerm = textField.text!
        if validarCorreo(text: searchTerm){
            emailPaloma.isHidden = false
            emailPaloma.image = #imageLiteral(resourceName: "check")
            flagMail = true
        }else{
            emailPaloma.isHidden = false
            emailPaloma.image = #imageLiteral(resourceName: "error")
            flagMail = false
        }
    }
    
    @objc func textFieldDidChangeUser(_ textField: UITextField){
        let searchTerm = textField.text!
        if !validarTexto(searchTerm: searchTerm){
            userPaloma.isHidden = false
            userPaloma.image = #imageLiteral(resourceName: "error")
            flagUser = false
        }else if searchTerm.count <= 7 {
            passPaloma.isHidden = false
            passPaloma.image = #imageLiteral(resourceName: "error")
            flagPass = false
        }else{
            userPaloma.isHidden = false
            userPaloma.image = #imageLiteral(resourceName: "check")
            flagUser = true
        }
    }
    
    @objc func textFieldDidChangePass(_ textField: UITextField) {
        
        let searchTerm = textField.text!
        if searchTerm == ""{
            passPaloma.isHidden = false
            passPaloma.image = #imageLiteral(resourceName: "error")
            flagPass = false
        }else if searchTerm.count <= 7 {
            passPaloma.isHidden = false
            passPaloma.image = #imageLiteral(resourceName: "error")
            flagPass = false
        }else if searchTerm != userText.text! {
            passPaloma.isHidden = false
            passPaloma.image = #imageLiteral(resourceName: "error")
            flagPass = false
        }else{
            passPaloma.isHidden = false
            passPaloma.image = #imageLiteral(resourceName: "check")
            flagPass = true
        }
    }
    
    func validarTexto(searchTerm: String) -> Bool{
        if searchTerm == ""{
            return false
        }else{
            return true
        }
    }
    
    func validarCorreo(text: String) -> Bool{
        //let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        let match = emailPredicate.evaluate(with: text)
        
        //let range = NSRange(location: 0, length: searchTerm.utf16.count)
        //if regex.firstMatch(in: searchTerm, options: [], range: range) == nil {
        if !match {
            //print("could not handle special characters")
            //let runningNumber = String(searchTerm.dropLast())
            return false
        }else if text == ""{
            return false
        }else{
            return true
        }
    }
    
    @objc func backWindow(){
        dismiss(animated: true, completion: nil)
    }
    
    func sendDataAction(){
        if checkboximage.tag == 0{
            showmessage(message: "Acepta los términos y condiciones para continuar", controller: self)
        }else if flagPass && flagUser && flagMail && flagName{
            self.user?.pass = passText.text!
            self.user?.fullname = nameText.text!
            self.user?.email = emailText.text!
            self.user?.name = nameText.text!
            //con todos los datos, necesito recuperar token
            callService(user : self.user!)
        }else{
            showmessage(message: "Revisa la información que proporcionaste...", controller: self)
        }
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        sendDataAction()
    }
    
    func callService(user:User){
        
        let alertaloadingtoken = UIAlertController(title: nil, message: "Sincronizando...", preferredStyle: .alert)
        
        alertaloadingtoken.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alertaloadingtoken.view.addSubview(loadingIndicator)
        present(alertaloadingtoken, animated: true, completion: nil)
        
        let manager = DataManager.shared
        manager.getToken(user: user) { (response) in
            DispatchQueue.main.async {
                alertaloadingtoken.dismiss(animated: true, completion: {
                    //temp
                                        
                    /*let userDefaults = UserDefaults.standard
                    let encodedData: Data =  NSKeyedArchiver.archivedData(withRootObject: self.user)
                    userDefaults.set(encodedData, forKey: "user")
                    userDefaults.synchronize()
                    manager.user = user
                    self.performSegue(withIdentifier: "token", sender: response)*/

                    switch response.resp {
                    case "error | errors":
                        self.showAlerta(message: "Error al sincronizarte. Contacta a roockmotion para mayor informaciòn")
                        break
                    case "error":
                            self.showAlerta(message: response.mes)
                        break
                    case "ok":
                        let refreshAlert = UIAlertController(title: "", message: response.mes, preferredStyle: UIAlertController.Style.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in

                            manager.user = user
                            
                            let userDefaults = UserDefaults.standard
                            let encodedData: Data =  NSKeyedArchiver.archivedData(withRootObject: user)
                            userDefaults.set(encodedData, forKey: "user")
                            userDefaults.set("1", forKey: "sesion")
                            
                            userDefaults.synchronize()
                            
                            self.performSegue(withIdentifier: "token", sender: response)
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
    
    @IBAction func conditionsAction(_ sender: Any) {
        
        let tag = checkboximage.tag
        // 0 = fasle
        // 1 = true
        
        if tag == 0{
            checkboximage.tag = 1
            checkboximage.isChecked = false
        }else{
            checkboximage.tag = 0
            checkboximage.isChecked = true
        }
    }
    
    @IBAction func checkAction(_ sender: UIButton) {
        let tag = checkboximage.tag
        // 0 = fasle
        // 1 = true
        
        if tag == 0{
            checkboximage.tag = 1
            checkboximage.isChecked = false
        }else{
            checkboximage.tag = 0
            checkboximage.isChecked = true
        }
    }
    
    @IBAction func openTerminosAction(_ sender: Any) {
        if let url = URL(string: "https://rookmotion.com/terminos.html") {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameText {
            view.endEditing(true)
            return true
        }else if textField == emailText {
            view.endEditing(true)
            return true
        }else if textField == userText {
            view.endEditing(true)
            return true
        }else if textField == passText {
            view.endEditing(true)
            //sendDataAction()
            return true
        }else{
            return true
        }
    }
    
/*********************** launch polizas***********************/
    func showAlerta(message: String){
        let refreshAlert = UIAlertController(title: "Atención.", message: message, preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in

        }))
        
        if message.contains("correo"){
            refreshAlert.addAction(UIAlertAction(title: "Reestablecer contraseña", style: .default, handler: { (action: UIAlertAction!) in
                if let url = URL(string: "https://rookmotion.com/recuperar.html") {
                    let svc = SFSafariViewController(url: url)
                    self.present(svc, animated: true, completion: nil)
                }
            }))
        }
        
        present(refreshAlert, animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "token"{
            let vc = segue.destination as? TokenViewController
            vc!.resp = sender as? Respuesta
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    /*El correo electrónico  que intentas ingresar, ya fue registrado, te recomendamos recuperar tu contraseña en el siguiente link.*/
    
    /*
     El correo electrónico  que intentas ingresar, ya fue registrado, te hemos reenviado el código de activación, por favor revisa tu bandeja
     
     El correo electrónico  que intentas ingresar, ya fue registrado, te hemos reenviado el código de activación, por favor revisa tu bandeja
     */

}
