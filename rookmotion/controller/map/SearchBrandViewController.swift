//
//  SearchBrandViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/9/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit

class SearchBrandViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var searchText: UITextField!
    @IBOutlet var tableViewBranch: UITableView!
    var arrayBranch: [Branch]? = []
    var filtered: [Branch]? = []
    var searchActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let manager = DataManager.shared
        arrayBranch = manager.arrayBranch
        tableViewBranch.reloadData()
        
        searchText.addTarget(self, action: #selector(textFieldDidChange(_:)),
                            for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        
        let text = textField.text?.uppercased()
        //let textmin = textField.text!
        filtered = arrayBranch?.filter({ (branch) -> Bool in
            let tmp: NSString = branch.name.uppercased() as NSString
            let tmpDes: NSString = branch.address.uppercased() as NSString
            
            //let tmp = branch.name
            //tmp.contains(text)
            //branch.name.range(of: StringProtocol(text!))
            //let pro = StringProtocol.init(text)
            let range = (tmp.range(of: "\(text!)"))
            //let range2 = (tmp.range(of: "\(textmin)"))
            let range3 = (tmpDes.range(of: "\(text!)"))
            //let range4 = (tmpDes.range(of: "\(textmin)"))
            
            if range.location != NSNotFound {
                return true
            }/*else if range2.location != NSNotFound {
                return true
            }*/else if range3.location != NSNotFound {
                return true
            }/*else if range4.location != NSNotFound {
                return true
            }*/else{
                return false
            }
        })
        
        if(filtered!.count == 0){
            searchActive = false
        } else {
            searchActive = true
        }
        
        tableViewBranch.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive{
            return filtered!.count
        }else{
            return arrayBranch!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaBranch") as! BranchTableViewCell
        if searchActive{
            cell.nameText.text = filtered![indexPath.row].name
            cell.addressText.text = filtered![indexPath.row].address
        }else{
            cell.nameText.text = arrayBranch![indexPath.row].name
            cell.addressText.text = arrayBranch![indexPath.row].address
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //when clic en row...open view with details
        performSegue(withIdentifier: "detailsBranch", sender: arrayBranch![indexPath.row])
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchText {
            view.endEditing(true)
            return true
        }else{
            return true
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsBranch"{
            let vc = segue.destination as! DetailsBranchViewController
            vc.branch = sender as? Branch
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
