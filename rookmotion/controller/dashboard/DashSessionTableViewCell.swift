//
//  SesionesDashTableViewCell.swift
//  rockmotion
//
//  Created by i7 on 8/31/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit

class DashSessionTableViewCell: UITableViewCell {

    @IBOutlet weak var viewAll: UIView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var trainingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }

}
