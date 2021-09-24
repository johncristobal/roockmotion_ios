//
//  UserPerfilViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/20/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import CoreData

class UserProfileViewController: UIViewController {

    @IBOutlet var nameView: UIView!
    @IBOutlet var nameText: UITextField!
    @IBOutlet var nameCheck: UIImageView!
    var flagName = false
    
    @IBOutlet var aliasView: UIView!
    @IBOutlet var aliasText: UITextField!
    @IBOutlet var aliasCheck: UIImageView!
    var flagAlias = false
    
    @IBOutlet var mailView: UIView!
    @IBOutlet var mailText: UITextField!
    @IBOutlet var mailCheck: UIImageView!
    var flagMail = false
    
    @IBOutlet var sexView: UIView!
    @IBOutlet var sexCombo: UISegmentedControl!
    @IBOutlet var sexCheck: UIImageView!
    
    @IBOutlet var phoneView: UIView!
    @IBOutlet var phoneText: UITextField!
    @IBOutlet var phoneCheck: UIImageView!
    var flagPhone = false

    @IBOutlet var dateView: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateCheck: UIImageView!
    
    @IBOutlet var weightView: UIView!
    @IBOutlet var weightText: UITextField!
    @IBOutlet var weightCheck: UIImageView!
    var flagWeight = false
    
    @IBOutlet var heightView: UIView!
    @IBOutlet var heightText: UITextField!
    @IBOutlet var heightCheck: UIImageView!
    var flagHeight = false
    
    @IBOutlet var heartRateView: UIView!
    @IBOutlet var heartRateText: UITextField!
    @IBOutlet var heartRateCheck: UIImageView!
    var flagLpm = false
    
    var user: User?
    let changeNameProfile = Notification.Name("changeNamePerfil")
    var loadingSesiones : UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameText.underlined()
        aliasText.underlined()
        weightText.underlined()
        mailText.underlined()
        phoneText.underlined()
        heightText.underlined()
        heartRateText.underlined()
        
        //addToolBar(textField: nameText)
        //addToolBar(textField: aliasText)
        addToolBar(textField: weightText)
        //addToolBar(textField: mailText)
        addToolBar(textField: phoneText)
        addToolBar(textField: heightText)
        addToolBar(textField: heartRateText)
        
        let manager = DataManager.shared
        user = manager.user
        
        nameText.text = user?.name
        aliasText.text = user?.pseudonym
        mailText.text = user?.email
        phoneText.text = user?.phone
        weightText.text = user?.peso.description
        heightText.text = user?.estatura.description
        heartRateText.text = user?.frecuenciabasal.description
        
        if user?.sexo == "h"{
            sexCombo.selectedSegmentIndex = 0
        }else{
            sexCombo.selectedSegmentIndex = 1
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var date: Date?
        if user!.birthday == ""{
            date = dateFormatter.date (from: "1970-01-01")
        }else{
            date = dateFormatter.date (from: user!.birthday)
        }
        //let cadenasFecha = user?.birthday.split(separator: "-")
        //let anio = cadenasFecha![0]
        //print(anio)
        
        datePicker.setDate(date!, animated: false)
        
        nameText.addTarget(self, action: #selector(textFieldDidChangeName(_:)), for: .editingChanged) 
        aliasText.addTarget(self, action: #selector(textFieldDidChangeAlias(_:)), for: .editingChanged)
        mailText.addTarget(self, action: #selector(textFieldDidChangeMail(_:)), for: .editingChanged)
        phoneText.addTarget(self, action: #selector(textFieldDidChangeCelular(_:)), for: .editingChanged)
        weightText.addTarget(self, action: #selector(textFieldDidChangePeso(_:)), for: .editingChanged)
        heightText.addTarget(self, action: #selector(textFieldDidChangeAltura(_:)), for: .editingChanged)
        heartRateText.addTarget(self, action: #selector(textFieldDidChangeLpm(_:)), for: .editingChanged)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    @objc func textFieldDidChangeName(_ textField: UITextField){
        let searchTerm = textField.text!
        if !validarTexto(searchTerm: searchTerm){
            nameCheck.isHidden = false
            nameCheck.image = #imageLiteral(resourceName: "error")
            flagName = false
        }else{
            nameCheck.isHidden = false
            nameCheck.image = #imageLiteral(resourceName: "check")
            flagName = true
        }
    }
    
    @objc func textFieldDidChangeAlias(_ textField: UITextField){
        let searchTerm = textField.text!
        if !validarTexto(searchTerm: searchTerm){
            aliasCheck.isHidden = false
            aliasCheck.image = #imageLiteral(resourceName: "error")
            flagAlias = false
        }else{
            aliasCheck.isHidden = false
            aliasCheck.image = #imageLiteral(resourceName: "check")
            flagAlias = true
        }
    }
    
    @objc func textFieldDidChangeCelular(_ textField: UITextField){
        let searchTerm = textField.text!
        if !validarCelular(text: searchTerm){
            phoneCheck.isHidden = false
            phoneCheck.image = #imageLiteral(resourceName: "error")
            flagPhone = false
        }else {
            phoneCheck.isHidden = false
            phoneCheck.image = #imageLiteral(resourceName: "check")
            flagPhone = true
        }
    }
    
    @objc func textFieldDidChangePeso(_ textField: UITextField){
        let searchTerm = textField.text!
        if !validarPesoLpm(text: searchTerm){
            weightCheck.isHidden = false
            weightCheck.image = #imageLiteral(resourceName: "error")
            flagWeight = false
        }else {
            weightCheck.isHidden = false
            weightCheck.image = #imageLiteral(resourceName: "check")
            flagWeight = true
        }
    }
    
    @objc func textFieldDidChangeAltura(_ textField: UITextField){
        let searchTerm = textField.text!
        if !validarAltura(text: searchTerm){
            heightCheck.isHidden = false
            heightCheck.image = #imageLiteral(resourceName: "error")
            flagHeight = false
        }else {
            heightCheck.isHidden = false
            heightCheck.image = #imageLiteral(resourceName: "check")
            flagHeight = true
        }
    }
    
    @objc func textFieldDidChangeLpm(_ textField: UITextField){
        let searchTerm = textField.text!
        if !validarPesoLpm(text: searchTerm){
            heartRateCheck.isHidden = false
            heartRateCheck.image = #imageLiteral(resourceName: "error")
            flagLpm = false
        }else {
            heartRateCheck.isHidden = false
            heartRateCheck.image = #imageLiteral(resourceName: "check")
            flagLpm = true
        }
    }
    
    @objc func textFieldDidChangeMail(_ textField: UITextField) {
        
        let searchTerm = textField.text!
        if validarMail(text: searchTerm){
            mailCheck.isHidden = false
            mailCheck.image = #imageLiteral(resourceName: "check")
            flagMail = true
        }else{
            mailCheck.isHidden = false
            mailCheck.image = #imageLiteral(resourceName: "error")
            flagMail = false
        }
    }
    
    func validarTexto(searchTerm: String) -> Bool{
        if searchTerm == ""{
            return false
        }else{
            return true
        }
    }

    func validarMail(text: String) -> Bool{
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
    
    func validarCelular(text: String) -> Bool{
        if text == ""{
            return false
        }else if text.count < 9 || text.count > 14{
            return false
        }else{
            return true
        }
    }
    
    func validarPesoLpm(text: String) -> Bool{
        //let valueDouble = Double(text.description)!
        if text == ""{
            return false
        }else if ((Double(text.description)!) < 30){
            return false
        }else{
            return true
        }
    }
    
    func validarAltura(text: String) -> Bool{
        //let valueDouble = Double(text.description)!

        if text == ""{
            return false
        }else if ((Double(text.description)!) < 0){
            return false
        }else{
            return true
        }
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveData(_ sender: Any) {
        
        if validarTexto(searchTerm: nameText.text!){
            if validarMail(text: mailText.text!){
                if validarTexto(searchTerm: aliasText.text!){
                    if validarCelular(text: phoneText.text!){
                        if validarPesoLpm(text: weightText.text!){
                            if validarAltura(text: heightText.text!){
                                if validarPesoLpm(text: heartRateText.text!){
                                    guardarDatosYMandarWS()
                                }else{
                                    //para todos...poner flecha rojita y foco en el text...
                                    heartRateText.becomeFirstResponder()
                                    heartRateCheck.isHidden = false
                                    heartRateCheck.image = #imageLiteral(resourceName: "error")
                                    flagLpm = false
                                }
                            }else{
                                heightText.becomeFirstResponder()
                                heightCheck.isHidden = false
                                heightCheck.image = #imageLiteral(resourceName: "error")
                                flagHeight = false
                            }
                        }else{
                            weightText.becomeFirstResponder()
                            weightCheck.isHidden = false
                            weightCheck.image = #imageLiteral(resourceName: "error")
                            flagWeight = false
                        }
                    }else{
                        phoneText.becomeFirstResponder()
                        phoneCheck.isHidden = false
                        phoneCheck.image = #imageLiteral(resourceName: "error")
                        flagPhone = false
                    }
                }else{
                    aliasText.becomeFirstResponder()
                    aliasCheck.isHidden = false
                    aliasCheck.image = #imageLiteral(resourceName: "error")
                    flagAlias = false
                }
            }else{
                mailText.becomeFirstResponder()
                mailCheck.isHidden = false
                mailCheck.image = #imageLiteral(resourceName: "error")
                flagMail = false
            }
        }else{
            nameText.becomeFirstResponder()
            nameCheck.isHidden = false
            nameCheck.image = #imageLiteral(resourceName: "error")
            flagName = false
        }
    }
    
    func guardarDatosYMandarWS(){
        user?.name = nameText.text!
        user?.email = mailText.text!
        user?.pseudonym = aliasText.text!
        user?.phone = phoneText.text!
        
        user?.peso = Double(weightText.text!) as! Double
        user?.estatura = Int(heightText.text!) as! Int
        user?.frecuenciabasal = Int(heartRateText.text!) as! Int
        
        if sexCombo.selectedSegmentIndex == 0{
            user?.sexo = "h"
        }else{
            user?.sexo = "m"
        }
        
        //pasar el datepicker a date y luego a string yyyy-MM-dd
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        user?.birthday = dateFormatter.string(from: datePicker.date)
        
        /*let userDefaults = UserDefaults.standard
        let encodedData: Data =  NSKeyedArchiver.archivedData(withRootObject: self.user)
        userDefaults.set(encodedData, forKey: "user")
        userDefaults.synchronize()*/
        deleteData()
        saveCoreUser(user: user!)
        let manager = DataManager.shared
        manager.user = user //= manager.user
        
        NotificationCenter.default.post(name: changeNameProfile, object: nil)
        //.addObserver(self, selector: #selector(changeName(_:)), name: changeNamePerfil, object: nil)

        showLoading(titulo: "Información", mensaje: "Guardando información...")

        manager.usersUpdate(user: user!) { (respuesta) in
            DispatchQueue.main.async {
            self.loadingSesiones?.dismiss(animated: true, completion: {
                switch respuesta.resp {
                case "ok":
                    let alert = UIAlertController(title: "¡Hecho!", message: respuesta.mes, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    break
                default:
                    showmessage(message: respuesta.mes, controller: self)
                    break
                }
            })
            }
            
        }
        

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
    
    @IBAction func sexoChanged(_ sender: Any) {
        sexCheck.isHidden = false
        sexCheck.image = #imageLiteral(resourceName: "check")
        //flagSexo = true
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        dateCheck.isHidden = false
        dateCheck.image = #imageLiteral(resourceName: "check")
        //flagFecha = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameText {
            view.endEditing(true)
            return true
        }else if textField == aliasText {
            view.endEditing(true)
            return true
        }else if textField == mailText {
            view.endEditing(true)
            return true
        }else{
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == heightText{
            //cuando el codigo postal pierda foco, validamos el dato
            //sin loading ni dnada...asi lo lanzamos
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 3
        }else{
            return true
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
