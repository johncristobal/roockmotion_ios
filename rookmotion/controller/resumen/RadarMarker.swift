//
//  RadarMarker.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/27/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import Foundation
import Charts

public class RadarMarkerView: MarkerView {
    @IBOutlet var label: UILabel!
    @IBOutlet var labelDato: UILabel!
    @IBOutlet var circleGraph: UIView!
    
    public override func awakeFromNib() {
        self.offset.x = -self.frame.size.width / 2.0
        self.offset.y = -self.frame.size.height + 10.0
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        print("dato y: \(entry.y)")
        print("dato x: \(entry.x)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_MX")
        if graficaTipo == "resumen"{
            dateFormatter.dateFormat = "HH:mm:ss" //"yyyy-MM-dd HH:mm:ss"
        }else if graficaTipo == "peso"{
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss" //"yyyy-MM-dd HH:mm:ss"
        }
        let date = Date(timeIntervalSince1970: entry.x)
        let string = dateFormatter.string(from: date)
        
        circleGraph.roundCornerGraph()
        circleGraph.backgroundColor = colorBack
        label.text = string //String.init(format: "%d %%", Int(round(entry.x)))
        labelDato.text = String.init(format: "\(stringLabel) %d", Int(round(entry.y)))
        layoutIfNeeded()
    }
}
