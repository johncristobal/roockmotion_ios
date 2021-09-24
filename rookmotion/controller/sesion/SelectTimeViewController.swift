//
//  SelectTimeViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/13/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit

class SelectTimeViewController: UIViewController {

    @IBOutlet var sliderTime: UISlider!
    @IBOutlet var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftTrackImage = UIImage(named: "sliderselectorxxhdpi")
        sliderTime.setThumbImage(leftTrackImage, for: .normal)
        sliderTime.setThumbImage(leftTrackImage, for: .highlighted)
     
        
    }
    
    @IBAction func nextButton(_ sender: Any) {
        let mins = Int(sliderTime.value)
        UserDefaults.standard.set(mins, forKey: "timeSesion") //.string(forKey: "")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sliderChange(_ sender: Any) {
        timeLabel.text = "\(Int(sliderTime.value)) min"
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
