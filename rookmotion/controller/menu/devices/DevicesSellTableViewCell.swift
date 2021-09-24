//
//  DispositivosVentaTableViewCell.swift
//  rockmotion
//
//  Created by i7 on 9/5/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit

class DevicesSellTableViewCell: UITableViewCell {

    @IBOutlet weak var nameDevice: UILabel!
    @IBOutlet weak var priceDevice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
