//
//  DateFormat.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/23/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation
import Charts

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        //dateFormatter.dateFormat = "dd MMM HH:mm"
        dateFormatter.dateFormat = "HH:mm:ss"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

public class DateValueFormatterPeso: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        //dateFormatter.dateFormat = "dd MMM HH:mm"
        dateFormatter.dateFormat = "dd-MM-yyyy"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
