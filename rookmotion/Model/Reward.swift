//
//  Reward.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/3/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation

struct Reward {
    var id: Int
    var label: String
    var reward: String
    
    init(
        id:Int,
        label:String,
        reward: String
        ) {
        self.id = id
        self.label = label
        self.reward = reward
    }
}
