//
//  PhotoViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/17/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet var dataLayer: UIView!
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var calLabel: UILabel!
    @IBOutlet var fragLabel: UILabel!
    @IBOutlet var percentageLabel: UILabel!
    
    var sesion: Photoshare?
    
    @IBOutlet var buttonClose: UIButton!
    @IBOutlet var buttonShare: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*let view = UIView(frame: CGRect(x: 0, y: 0, width: dataLayer.frame.width, height: dataLayer.frame.height))
        let gradient = CAGradientLayer()
        
        gradient.frame = view.bounds
        gradient.colors = [UIColor.lightGray.cgColor, UIColor.black.cgColor]
        
        dataLayer.layer.insertSublayer(gradient, at: 0)*/
        
        photoImage.image = sesion?.fotoback
        timeLabel.text = sesion?.duration
        let manager = DataManager.shared
        
        let split = manager.user?.name.components(separatedBy: " ")
        if split!.count > 0{
            if split?.count == 1{
                nameLabel.text = split![0]
            }else if split!.count > 1{
                nameLabel.text = "\(split![0])"
            }
        }else{
            nameLabel.text = manager.user?.name
        }
        dateLabel.text = sesion?.fecha
        calLabel.text = sesion?.heart
        fragLabel.text = sesion?.calories
        percentageLabel.text = sesion?.esfuerzo
    }

    @IBAction func closeWindow(_ sender: Any) {
        let reestart = Notification.Name("reestartTimer")
        let finsesion = Notification.Name("finsesion")
        dismiss(animated: true, completion: {
            if  graficasData == .sesionActiva{
                NotificationCenter.default.post(name: reestart, object: nil)
            }
            if  graficasData == .finSesion{
                NotificationCenter.default.post(name: finsesion, object: nil)
            }
        })
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
        buttonClose.isHidden = true
        buttonShare.isHidden = true
        //Create the UIImage
        //UIGraphicsBeginImageContext(view.frame.size)
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0);
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Save it to the camera roll
        //UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        let vc = UIActivityViewController(
            activityItems: ["",image],
            applicationActivities: []
        )
        
        present(vc, animated: true, completion: {
            self.buttonClose.isHidden = false
            self.buttonShare.isHidden = false
        })
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
