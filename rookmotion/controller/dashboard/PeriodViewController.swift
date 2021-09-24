//
//  PeriodoViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/23/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit

class PeriodViewController: UIViewController {

    @IBOutlet var verImageSemana: UIImageView!
    @IBOutlet var verImageMes: UIImageView!
    @IBOutlet var verImageSemestre: UIImageView!
    @IBOutlet var verImageAnio: UIImageView!
    @IBOutlet var viewAll: UIView!
    
    let changePeriodoName = Notification.Name("changePeriodo")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        
        viewAll.roundCorner()
        
        // Do any additional setup after loading the view.
        if UserDefaults.standard.value(forKey: "periodo") != nil{
            let periodo = UserDefaults.standard.integer(forKey: "periodo")
            ocultarViews(periodo: periodo)
        }else{
            ocultarViews(periodo: Periodo.mes.rawValue)
        }
    }
    
    func ocultarViews(periodo: Int){
        switch periodo {
        case 1:
            verImageSemana.isHidden = false
            verImageMes.isHidden = true
            verImageSemestre.isHidden = true
            verImageAnio.isHidden = true
            break
        case 2:
            
            verImageSemana.isHidden = true
            verImageMes.isHidden = false
            verImageSemestre.isHidden = true
            verImageAnio.isHidden = true
            break
        case 3:
            
            verImageSemana.isHidden = true
            verImageMes.isHidden = true
            verImageSemestre.isHidden = false
            verImageAnio.isHidden = true
            break
        case 4:
            
            verImageSemana.isHidden = true
            verImageMes.isHidden = true
            verImageSemestre.isHidden = true
            verImageAnio.isHidden = false
            break

        default:
            break
        }
    }
    
    @IBAction func changePeriodo(_ sender: UIButton) {
        
        dismiss(animated: true, completion: {
            switch sender.tag {
            case 0:
                UserDefaults.standard.set(Periodo.semana.rawValue, forKey: "periodo")
                NotificationCenter.default.post(name: self.changePeriodoName, object: nil, userInfo: ["periodo": Periodo.semana])
                break
            case 1:
                UserDefaults.standard.set(Periodo.mes.rawValue, forKey: "periodo")
                NotificationCenter.default.post(name: self.changePeriodoName, object: nil, userInfo: ["periodo": Periodo.mes])
                break
            case 2:
                UserDefaults.standard.set(Periodo.semestre.rawValue, forKey: "periodo")
                NotificationCenter.default.post(name: self.changePeriodoName, object: nil, userInfo: ["periodo": Periodo.semestre])
                break
            case 3:
                UserDefaults.standard.set(Periodo.anio.rawValue, forKey: "periodo")
                NotificationCenter.default.post(name: self.changePeriodoName, object: nil, userInfo: ["periodo": Periodo.anio])
                break
                
            default:
                break
            }
        })
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
