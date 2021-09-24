//
//  SesionViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/12/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import SafariServices
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class SesionViewController: UIViewController,GIDSignInDelegate {

    @IBOutlet var sesionButton: UIButton!
    @IBOutlet var backArrow: UIImageView!
    @IBOutlet var nameText: UITextField!
    @IBOutlet var namePaloma: UIImageView!
    @IBOutlet var faceButton: UIButton!
    @IBOutlet var googleButton: UIButton!

    @IBOutlet var passText: UITextField!
    @IBOutlet var passPaloma: UIImageView!
    
    var flagMail = false
    var flagPass = false
    
    var flagSesion = false
    var loadingSesiones : UIAlertController?
    var user: User = User(id:-1, name: "", fullname: "", email: "", image: UIImage(named: "paloma")!, pass: "", edad: 1, sexo: "h", peso: 0.0, estatura: 0,  frecuenciabasal: 60, birthday:"1970-01-01", pseudonym:"", phone:"", tok:"", full: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameText.underlined()
        passText.underlined()
        
        sesionButton.roundCorner()
        faceButton.roundCorner()
        googleButton.roundCorner()

        //addToolBar(textField: nameText)
        //addToolBar(textField: passText)
        
        backArrow.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backWindow))
        backArrow.addGestureRecognizer(gesture)
        
        nameText.delegate = self
        passText.delegate = self
        
        nameText.addTarget(self, action: #selector(textFieldDidChangeName(_:)), for: .editingChanged)
        passText.addTarget(self, action: #selector(textFieldDidChangePass(_:)), for: .editingChanged)
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self

    }
    
    @IBAction func faceLoginAction(_ sender: Any) {
        
        //let loginManager = LoginManager()
         let loginManager = LoginManager()
         loginManager.logIn(permissions: ["email","public_profile"], from: self) { (loginResult, error) in
             
             if error != nil{
                 print("algo salio mal...")
                let alert = UIAlertController(title: "", message: "Error al iniciar sesión, intente más tarde...", preferredStyle: .alert)
                self.present(alert, animated: true)
                
                print(error!)
                
             }
             else if loginResult!.isCancelled{
                 print("User cancelled login.")
             }
             else{
                 let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, phone, picture.width(480).height(480)"])
                 graphRequest.start(completionHandler: { (connection, result, error) in
                     if error != nil {
                         print("Error",error!.localizedDescription)
                     }
                     else{
                         print(result!)
                         let field = result! as? [String:Any]
                         let name = field!["name"] as? String
                         let id = Int((field!["id"] as? String)!)
                         let email = field!["email"] as? String
                         let token = AccessToken.current!.tokenString
                         //field!["email"] as? String
                         
                         //print(name!)
                         //print(email!)
                         print(token)
                         
                         if let imageURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                             print(imageURL)
                             let url = URL(string: imageURL)
                             let data = NSData(contentsOf: url!)
                             let image = UIImage(data: data! as Data)
                             
                             self.user = User(id: id!, name: name!, fullname: "", email: email!, image: image!, pass: "", edad: 1, sexo: "h", peso: 0.0, estatura: 0, frecuenciabasal: 60, birthday:"1970-01-01", pseudonym:"", phone:"", tok:token, full: 0)
                         }else{
                             self.user = User(id: id!, name: name!, fullname: "", email: email!, image: UIImage(named: "iconsubir_imagen")!, pass: "", edad: 1, sexo: "h", peso: 0.0, estatura: 0,  frecuenciabasal: 60, birthday:"1970-01-01", pseudonym:"", phone:"", tok:token, full: 0)
                         }
                         
                         self.flagSesion = true
                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                             
                             let datamanager = DataManager.shared
                             datamanager.usersloginSocial(user: self.user, social: "1") { (respuesta) in
                                 print(respuesta.mes)
                                 
                                 DispatchQueue.main.async {
                                     //self.loadingSesiones?.dismiss(animated: true, completion: {
                                         switch respuesta.resp{
                                         case "ok":
                                             self.performSegue(withIdentifier: "dashboard", sender: nil)
                                             break
                                             
                                         default:
                                             showmessage(message: respuesta.mes, controller: self)
                                             break
                                         }
                                     }
                                     //)}
                             }
                             //self.performSegue(withIdentifier: "perfil", sender: self.user)
                         })
                     }
                 })
                 
                 /*connection.add(request, completion: {
                  (response, result) in
                  print("Facebook graph Result:", result)
                  let json = JSON(result)
                  print("Facebook graph Result:", json)
                  let email = json["email"].string
                  print(email)
                  //successBlock(true, json, accessToken.authenticationToken ,id)
                  })
                  
                  connection.start()*/
                 
                 //let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                 //print(crdential)
             }

         }
         
         /*loginManager.logIn(permissions: ["email","public_profile"], from: self) { (loginResult) in
             
         }*/
        print("facebook")
    }
    
    // ============================= google login =====================
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = 0//Int(user.userID)                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            if user.profile.hasImage{
                let dimension = round(100 * UIScreen.main.scale)
                let url = user.profile.imageURL(withDimension: UInt(dimension))
                let data = NSData(contentsOf: url!)
                let image = UIImage(data: data! as Data)
                self.user = User(id: userId, name: givenName!, fullname: fullName!, email: email!, image: image!, pass: "", edad: 1, sexo: "h", peso: 0.0, estatura: 0,  frecuenciabasal: 60, birthday:"1970-01-01", pseudonym:"", phone:"", tok:idToken!, full: 0)
            }else{
                self.user = User(id: userId, name: givenName!, fullname: fullName!, email: email!, image: UIImage(named: "iconsubir_imagen")!, pass: "", edad: 1, sexo: "h", peso: 0.0, estatura: 0,  frecuenciabasal: 60, birthday:"1970-01-01", pseudonym:"", phone:"", tok:idToken!, full: 0)
            }
            
            self.flagSesion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                
                let datamanager = DataManager.shared
                datamanager.usersloginSocial(user: self.user, social: "2") { (respuesta) in
                    print(respuesta.mes)
                    
                    DispatchQueue.main.async {
                        //self.loadingSesiones?.dismiss(animated: true, completion: {
                            switch respuesta.resp{
                            case "ok":
                                self.performSegue(withIdentifier: "dashboard", sender: nil)
                                break
                                
                            default:
                                showmessage(message: respuesta.mes, controller: self)
                                break
                            }
                        }
                        //)}
                }
                //self.performSegue(withIdentifier: "perfil", sender: self.user)
            })
            
            /*flagSesion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.performSegue(withIdentifier: "perfil", sender: self.user)
            })            */
        }
    }
    
    @IBAction func googleAction(_ sender: Any) {
        //performSegue(withIdentifier: "perfil", sender: nil)
        GIDSignIn.sharedInstance().signIn()
    }

    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        //myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func textFieldDidChangeName(_ textField: UITextField) {

        let searchTerm = textField.text!
        //let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        let match = emailPredicate.evaluate(with: searchTerm)
        
        //let range = NSRange(location: 0, length: searchTerm.utf16.count)
        //if regex.firstMatch(in: searchTerm, options: [], range: range) == nil {
        if !match {
            //print("could not handle special characters")
            //let runningNumber = String(searchTerm.dropLast())
            textField.text = searchTerm
            namePaloma.isHidden = false
            namePaloma.image = #imageLiteral(resourceName: "error")
            flagMail = false
        }else if searchTerm == ""{
            namePaloma.isHidden = false
            namePaloma.image = #imageLiteral(resourceName: "error")
            flagMail = false
        }else{
            namePaloma.isHidden = false
            namePaloma.image = #imageLiteral(resourceName: "check")
            flagMail = true
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
        }else{
            passPaloma.isHidden = false
            passPaloma.image = #imageLiteral(resourceName: "check")
            flagPass = true
        }
    }
    
    @objc func backWindow(){
        dismiss(animated: true, completion: nil)
    }
    
    func sendDataAction(){
        if flagPass && flagMail{

            showLoading(titulo: "Información...", mensaje: "Recuperando información...")
            
            let datamanager = DataManager.shared
            datamanager.userslogin(email: nameText.text!, password: passText.text!) { (respuesta) in
                print(respuesta.mes)
                
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        switch respuesta.resp{
                        case "ok":
                            self.performSegue(withIdentifier: "dashboard", sender: nil)
                            break
                            
                        default:
                            showmessage(message: respuesta.mes, controller: self)
                            break
                        }
                    }
                )}
            }
        }else{
            showmessage(message: "Verifica tus datos para continuar...",controller: self)
        }
    }
    
    @IBAction func sesionAction(_ sender: Any) {
        
        sendDataAction()
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
    
    @IBAction func passForgetAction(_ sender: Any) {
        //rookmotion.com/recuperar.html
        if let url = URL(string: "https://rookmotion.com/recuperar.html") {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameText {
            view.endEditing(true)
            return true
        }else if textField == passText {
            view.endEditing(true)
            sendDataAction()
            return true
        }else{
            return true
        }
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
