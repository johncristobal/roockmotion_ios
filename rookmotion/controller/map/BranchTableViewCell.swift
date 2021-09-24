//
//  BranchTableViewCell.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/9/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit

class BranchTableViewCell: UITableViewCell {

    @IBOutlet var nameText: UILabel!    
    @IBOutlet var addressText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }

}
