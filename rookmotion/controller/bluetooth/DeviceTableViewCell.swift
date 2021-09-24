//
//  DeviceTableViewCell.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/11/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet var imageHeart: UIImageView!
    @IBOutlet var nameText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }

}
