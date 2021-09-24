//
//  ActividadViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 7/12/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import CoreBluetooth

class ActivityListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableview: UITableView!
    var device: Blue?
    var activities: [Actividad] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let manager = DataManager.shared
        manager.trainingList { (resp) in
            switch resp.resp{
            case "ok":
                self.activities = manager.activities!
                self.tableview.reloadData()
                break
                
            default: break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellact")! as UITableViewCell
        
        let peripheral = activities[indexPath.row].label
        cell.textLabel?.text = peripheral
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let activity = activities[indexPath.row]
        UserDefaults.standard.set(activity.label, forKey: "ejercicio")
        UserDefaults.standard.set(activity.id, forKey: "idejercicio")
        
        dismiss(animated: true, completion: nil)
        //device?.text = actividad
        //performSegue(withIdentifier: "playSessionSegue", sender: device)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "playSessionSegue" {
            let vc = segue.destination as! SesionRookViewController            
            vc.rockmotion = sender as! Blue
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
