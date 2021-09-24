//
//  SocialLoginViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/12/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
//import FacebookCore
//import FacebookLogin
import Alamofire
import SwiftyJSON
import GoogleSignIn

class SocialLoginViewController: UIViewController,GIDSignInDelegate {

    @IBOutlet var faceButton: UIButton!
    @IBOutlet var googleButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var backArrow: UIImageView!
    
    var user: User = User(id:-1, name: "", fullname: "", email: "", image: UIImage(named: "paloma")!, pass: "", edad: 1, sexo: "h", peso: 0.0, estatura: 0,  frecuenciabasal: 60, birthday:"1970-01-01", pseudonym:"", phone:"", tok:"", full: 0)
    
    var flagSesion = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        faceButton.roundCorner()
        googleButton.roundCorner()
        emailButton.roundCorner()
        
        backArrow.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backWindow))
        backArrow.addGestureRecognizer(gesture)

        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("here again")
    }
    
    @objc func backWindow(){
        dismiss(animated: true, completion: nil)
    }
    
// ============================= faceboook login =====================
    @IBAction func faceAction(_ sender: Any) {
        
        //let loginManager = LoginManager()
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email","public_profile"], from: self) { (loginResult, error) in
            
            if error != nil{
                print("algo salio mal...")
                 print(error)
            }
            else if loginResult!.isCancelled{
                print("User cancelled login.")
            }
            else{
                let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(480).height(480)"])
                graphRequest.start(completionHandler: { (connection, result, error) in
                    if error != nil {
                        print("Error",error!.localizedDescription)
                        showmessage(message: "Tuvimos un problema, intente más tarde.", controller: self)
                    }
                    else{
                        print(result!)
                        let field = result! as? [String:Any]
                        let name = field!["name"] as? String
                        let id = Int((field!["id"] as? String)!)
                        let email = field!["email"] as? String
                        var dataEmail = ""
                        if let finalEmail = email{
                            dataEmail = finalEmail
                        }
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
                            
                            self.user = User(id: id!, name: name!, fullname: "", email: dataEmail, image: image!, pass: "", edad: 1, sexo: "h", peso: 0.0, estatura: 0, frecuenciabasal: 60, birthday:"1970-01-01", pseudonym:"", phone:"", tok:token, full: 0)
                        }else{
                            self.user = User(id: id!, name: name!, fullname: "", email: dataEmail, image: UIImage(named: "iconsubir_imagen")!, pass: "", edad: 1, sexo: "h", peso: 0.0, estatura: 0,  frecuenciabasal: 60, birthday:"1970-01-01", pseudonym:"", phone:"", tok:token, full: 0)
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
    
    @IBAction func emailAction(_ sender: Any) {

        user = User(id: -1, name: "", fullname: "", email: "", image: UIImage(named: "iconsubir_imagen")!, pass: "", edad: 1, sexo: "h", peso: 0.0, estatura: 0,  frecuenciabasal: 60, birthday:"1970-01-01", pseudonym:"", phone:"", tok:"", full: 0)
        performSegue(withIdentifier: "perfil", sender: self.user)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "perfil"{
            let vc = segue.destination as? ProfileViewController
            vc!.user = sender as! User
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
