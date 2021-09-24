//
//  MenuViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/19/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import SafariServices
import CoreData

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var mailLabel: UILabel!
    
    let options = ["Perfil","Dispositivos","Soporte","Términos y Condiciones", "Aviso de Privacidad"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user = DataManager.shared.user
        mailLabel.text = user?.email
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuCellTableViewCell
        
        cell.optionLabel.text = options[indexPath.row]
        
        return cell
    }
    
    //  https://rookmotion.com/aviso.html
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: //perfil
            performSegue(withIdentifier: "perfil", sender: nil)
        case 1: //dispositivos
            performSegue(withIdentifier: "devicesSegue", sender: nil)
            break
        case 2: //soporte
            openUrl(url: "https://rookmotion.com/preguntas.html")
            break
        case 3: //terminos
            openUrl(url: "https://rookmotion.com/terminos.html")
            break
        case 4: //aviso
            openUrl(url: "https://rookmotion.com/aviso.html")
            break
        default:
            break
        }
    }
    
    func openUrl(url: String){
        if let liga = URL(string: url) {
            let svc = SFSafariViewController(url: liga)
            present(svc, animated: true, completion: nil)
        }
    }
    
    @IBAction func cerrarSesionAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Atención", message: "¿Seguro que deseas cerrar sesión?", preferredStyle: .alert)
        let actionSi = UIAlertAction(title: "Si", style: .default) { (alert) in
            
            UserDefaults.standard.set("0", forKey: "sesion")
            
            let user = User(id: -1, name: "", fullname: "", email: "", image: UIImage(named: "iconsubir_imagen")!, pass: "", edad: 1, sexo: "h", peso: 0.0, estatura: -1,  frecuenciabasal: -1, birthday:"01-01-1997", pseudonym:"", phone:"00000000", tok:"", full: -1)
            
            /*let userDefaults = UserDefaults.standard
            let encodedData: Data =  NSKeyedArchiver.archivedData(withRootObject: user)
            userDefaults.set(encodedData, forKey: "user")
            userDefaults.synchronize()*/
            
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
                        managedContext.delete(data)
                    }
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                       print("Could not save. \(error), \(error.userInfo)")
                    }
                }else{
                    print("no hay datos back...memnu user")
                    
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            self.performSegue(withIdentifier: "adiossesion", sender: nil)
        }
        
        let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(actionSi)
        alert.addAction(actionNo)
        
        present(alert,animated: true)
        
    }
    
    @IBAction func closeWindow(_ sender: Any) {

        self.revealViewController()?.revealToggle(animated: true)
    }
    
}
