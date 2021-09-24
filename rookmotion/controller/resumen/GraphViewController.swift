//
//  GraficaViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/24/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import Charts
import CoreData
import SwiftyJSON

enum Option {
    case toggleValues
    case toggleIcons
    case toggleHighlight
    case animateX
    case animateY
    case animateXY
    case saveToGallery
    case togglePinchZoom
    case toggleAutoScaleMinMax
    case toggleData
    case toggleBarBorders
    // CandleChart
    case toggleShadowColorSameAsCandle
    case toggleShowCandleBar
    // CombinedChart
    case toggleLineValues
    case toggleBarValues
    case removeDataSet
    // CubicLineSampleFillFormatter
    case toggleFilled
    case toggleCircles
    case toggleCubic
    case toggleHorizontalCubic
    case toggleStepped
    // HalfPieChartController
    case toggleXValues
    case togglePercent
    case toggleHole
    case spin
    case drawCenter
    // RadarChart
    case toggleXLabels
    case toggleYLabels
    case toggleRotate
    case toggleHighlightCircle
    
    var label: String {
        switch self {
        case .toggleValues: return "Toggle Y-Values"
        case .toggleIcons: return "Toggle Icons"
        case .toggleHighlight: return "Toggle Highlight"
        case .animateX: return "Animate X"
        case .animateY: return "Animate Y"
        case .animateXY: return "Animate XY"
        case .saveToGallery: return "Save to Camera Roll"
        case .togglePinchZoom: return "Toggle PinchZoom"
        case .toggleAutoScaleMinMax: return "Toggle auto scale min/max"
        case .toggleData: return "Toggle Data"
        case .toggleBarBorders: return "Toggle Bar Borders"
        // CandleChart
        case .toggleShadowColorSameAsCandle: return "Toggle shadow same color"
        case .toggleShowCandleBar: return "Toggle show candle bar"
        // CombinedChart
        case .toggleLineValues: return "Toggle Line Values"
        case .toggleBarValues: return "Toggle Bar Values"
        case .removeDataSet: return "Remove Random Set"
        // CubicLineSampleFillFormatter
        case .toggleFilled: return "Toggle Filled"
        case .toggleCircles: return "Toggle Circles"
        case .toggleCubic: return "Toggle Cubic"
        case .toggleHorizontalCubic: return "Toggle Horizontal Cubic"
        case .toggleStepped: return "Toggle Stepped"
        // HalfPieChartController
        case .toggleXValues: return "Toggle X-Values"
        case .togglePercent: return "Toggle Percent"
        case .toggleHole: return "Toggle Hole"
        case .spin: return "Spin"
        case .drawCenter: return "Draw CenterText"
        // RadarChart
        case .toggleXLabels: return "Toggle X-Labels"
        case .toggleYLabels: return "Toggle Y-Labels"
        case .toggleRotate: return "Toggle Rotate"
        case .toggleHighlightCircle: return "Toggle highlight circle"
        }
    }
}

class GraphViewController: UIViewController,ChartViewDelegate {
    
    @IBOutlet var labelTempGrafica: UILabel!
    @IBOutlet var viewScrollTemp: UIView!
    @IBOutlet var barchartEsfuerzo: LineChartView!
    @IBOutlet var barchartFrecuencia: LineChartView!
    @IBOutlet var barchartCalorias: LineChartView!
    var options: [Option]!
    var flagFirst = true
    var loadingSesiones: UIAlertController?
    
    var shouldHideData: Bool = false
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var heartLabel: UILabel!
    @IBOutlet var fireLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("didload grafica")
        
        
        //self.setup(barLineChartView: barchartEsfuerzo)
        //barchartEsfuerzo.drawBarShadowEnabled = false
        //barchartEsfuerzo.drawValueAboveBarEnabled = false
        
        //barchartEsfuerzo.maxVisibleCount = 60
        
        /*let xAxis = barchartEsfuerzo.xAxis
         xAxis.labelPosition = .bottom
         xAxis.labelFont = .systemFont(ofSize: 10)
         xAxis.granularity = 1
         xAxis.labelCount = 7
         //xAxis.valueFormatter = DayAxisValueFormatter(chart: barchartEsfuerzo)
         
         let leftAxisFormatter = NumberFormatter()
         leftAxisFormatter.minimumFractionDigits = 0
         leftAxisFormatter.maximumFractionDigits = 1
         leftAxisFormatter.negativeSuffix = " $"
         leftAxisFormatter.positiveSuffix = " $"
         
         let leftAxis = barchartEsfuerzo.leftAxis
         leftAxis.labelFont = .systemFont(ofSize: 10)
         leftAxis.labelCount = 8
         leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
         leftAxis.labelPosition = .outsideChart
         leftAxis.spaceTop = 0.15
         leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
         
         let rightAxis = barchartEsfuerzo.rightAxis
         rightAxis.enabled = true
         rightAxis.labelFont = .systemFont(ofSize: 10)
         rightAxis.labelCount = 8
         rightAxis.valueFormatter = leftAxis.valueFormatter
         rightAxis.spaceTop = 0.15
         rightAxis.axisMinimum = 0
         
         let l = barchartEsfuerzo.legend
         l.horizontalAlignment = .left
         l.verticalAlignment = .bottom
         l.orientation = .horizontal
         l.drawInside = false
         l.form = .circle
         l.formSize = 9
         l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
         l.xEntrySpace = 4
         */
        //        chartView.legend = l
        
        /*let marker = MarkerView(
         color: UIColor.black,
         font: .systemFont(ofSize: 12),
         textColor: .white,
         insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
         xAxisValueFormatter: xAxis)
         
         marker.chartView = barchartEsfuerzo
         marker.minimumSize = CGSize(width: 80, height: 40)
         barchartEsfuerzo.marker = marker*/
        
        //sliderX.value = 12
        //sliderY.value = 50
        //slidersValueChanged(nil)
        //updateChartData()
        
       /* if flagGraficaFirst{
            flagGraficaFirst = false
            viewScrollTemp.isHidden = true
            labelTempGrafica.isHidden = true
        }else{
            viewScrollTemp.isHidden = false
            labelTempGrafica.isHidden = false
        }*/
        
        cargarGraficas()
        cargarDataDB()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //nothing...
        /*if flagGraficaFirst{
            flagGraficaFirst = false
            viewScrollTemp.isHidden = true
            labelTempGrafica.isHidden = true
        }else{
            viewScrollTemp.isHidden = false
            labelTempGrafica.isHidden = false
        }*/
    }
    
    func cargarGraficas(){
        /*
         * Grafica Esfuerzo
         */
        barchartEsfuerzo.delegate = self
        barchartEsfuerzo.chartDescription?.enabled = false
        barchartEsfuerzo.dragEnabled = true
        barchartEsfuerzo.setScaleEnabled(true)
        barchartEsfuerzo.pinchZoomEnabled = false
        barchartEsfuerzo.setViewPortOffsets(left: 35, top: 10, right: 20, bottom: 50)
        barchartEsfuerzo.backgroundColor = .black
        
        barchartEsfuerzo.leftAxis.enabled = true
        barchartEsfuerzo.leftAxis.drawAxisLineEnabled = true
        barchartEsfuerzo.leftAxis.drawGridLinesEnabled = true
        barchartEsfuerzo.leftAxis.gridColor = UIColor.black
        barchartEsfuerzo.zoom(scaleX: 5.0, scaleY: 1.0, x: 1.0, y: 1.0)

        let leftAxisbarchartEsfuerzo = barchartEsfuerzo.leftAxis
        leftAxisbarchartEsfuerzo.labelFont = .systemFont(ofSize: 10)
        leftAxisbarchartEsfuerzo.labelTextColor = UIColor.white
        leftAxisbarchartEsfuerzo.labelCount = 8
        leftAxisbarchartEsfuerzo.axisMaximum = maxPorc// (valuesPorc?.last!.y)!
        leftAxisbarchartEsfuerzo.axisMinimum = minPorc //(valuesPorc?.first!.y)!
        leftAxisbarchartEsfuerzo.labelPosition = .outsideChart
        leftAxisbarchartEsfuerzo.spaceTop = 0.15
        leftAxisbarchartEsfuerzo.drawGridLinesEnabled = true
        leftAxisbarchartEsfuerzo.granularityEnabled = false
        
        let xAxisbarchartEsfuerzo = barchartEsfuerzo.xAxis
        xAxisbarchartEsfuerzo.labelFont = .systemFont(ofSize: 10)
        xAxisbarchartEsfuerzo.labelTextColor = .white
        xAxisbarchartEsfuerzo.drawAxisLineEnabled = false
        //xAxis.granularity = 3600
        xAxisbarchartEsfuerzo.valueFormatter = DateValueFormatter()
        xAxisbarchartEsfuerzo.labelCount = 5
        xAxisbarchartEsfuerzo.labelRotationAngle = 65.0
        
        barchartEsfuerzo.rightAxis.enabled = false
        barchartEsfuerzo.rightAxis.drawGridLinesEnabled = false
        barchartEsfuerzo.rightAxis.drawAxisLineEnabled = false
        barchartEsfuerzo.rightAxis.gridColor = UIColor.clear
        
        barchartEsfuerzo.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barchartEsfuerzo.xAxis.drawGridLinesEnabled = false
        
        self.options = [.toggleValues,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleData,
                        .toggleBarBorders]
        
        /*
         * Grafica frecuancia
         */
        barchartFrecuencia.delegate = self
        barchartFrecuencia.chartDescription?.enabled = false
        barchartFrecuencia.dragEnabled = true
        barchartFrecuencia.setScaleEnabled(true)
        barchartFrecuencia.pinchZoomEnabled = false
        barchartFrecuencia.setViewPortOffsets(left: 30, top: 10, right: 20, bottom: 50)
        barchartFrecuencia.backgroundColor = .black
        
        barchartFrecuencia.leftAxis.enabled = true
        barchartFrecuencia.leftAxis.drawAxisLineEnabled = true
        barchartFrecuencia.leftAxis.drawGridLinesEnabled = true
        barchartFrecuencia.leftAxis.gridColor = UIColor.black
        barchartFrecuencia.zoom(scaleX: 5.0, scaleY: 1.0, x: 1.0, y: 1.0)

        let leftAxis = barchartFrecuencia.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelTextColor = UIColor.white
        leftAxis.labelCount = 8
        leftAxis.axisMaximum = maxCalo //(valuesHeart?.last!.y)!
        leftAxis.axisMinimum = minCalo //(valuesHeart?.first!.y)!
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.35
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = false
        
        let xAxis = barchartFrecuencia.xAxis
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelTextColor = .white
        xAxis.drawAxisLineEnabled = false
        //xAxis.granularity = 3600
        xAxis.valueFormatter = DateValueFormatter()
        xAxis.labelCount = 5
        xAxis.labelRotationAngle = 65.0

        barchartFrecuencia.rightAxis.enabled = false
        barchartFrecuencia.rightAxis.drawGridLinesEnabled = false
        barchartFrecuencia.rightAxis.drawAxisLineEnabled = false
        barchartFrecuencia.rightAxis.gridColor = UIColor.clear
        
        barchartFrecuencia.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barchartFrecuencia.xAxis.drawGridLinesEnabled = false
        
        self.options = [.toggleValues,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleData,
                        .toggleBarBorders]
        
        
        /*
         * Grafica calorias
         */
        barchartCalorias.delegate = self
        barchartCalorias.chartDescription?.enabled = false
        barchartCalorias.dragEnabled = true
        barchartCalorias.setScaleEnabled(true)
        barchartCalorias.pinchZoomEnabled = false
        barchartCalorias.setViewPortOffsets(left: 30, top: 10, right: 20, bottom: 50)
        barchartCalorias.backgroundColor = .black
        
        barchartCalorias.leftAxis.enabled = true
        barchartCalorias.leftAxis.drawAxisLineEnabled = true
        barchartCalorias.leftAxis.drawGridLinesEnabled = true
        barchartCalorias.leftAxis.gridColor = UIColor.black
        barchartCalorias.zoom(scaleX: 5.0, scaleY: 1.0, x: 1.0, y: 1.0)

        let leftAxisbarchartCalorias = barchartCalorias.leftAxis
        leftAxisbarchartCalorias.labelFont = .systemFont(ofSize: 10)
        leftAxisbarchartCalorias.labelTextColor = UIColor.white
        leftAxisbarchartCalorias.labelCount = 8
        leftAxisbarchartCalorias.axisMaximum = maxHeart //(valuesCalo?.last!.y)!
        leftAxisbarchartCalorias.axisMinimum = minHeart //(valuesCalo?.first!.y)!
        leftAxisbarchartCalorias.labelPosition = .outsideChart
        leftAxisbarchartCalorias.spaceTop = 0.35
        leftAxisbarchartCalorias.drawGridLinesEnabled = true
        leftAxisbarchartCalorias.granularityEnabled = false
        
        let xAxisbarchartCalorias = barchartCalorias.xAxis
        xAxisbarchartCalorias.labelFont = .systemFont(ofSize: 10)
        xAxisbarchartCalorias.labelTextColor = .white
        xAxisbarchartCalorias.drawAxisLineEnabled = false
        //xAxis.granularity = 3600
        xAxisbarchartCalorias.labelCount = 5
        xAxisbarchartCalorias.valueFormatter = DateValueFormatter()
        xAxisbarchartCalorias.labelRotationAngle = 65.0

        barchartCalorias.rightAxis.enabled = false
        barchartCalorias.rightAxis.drawGridLinesEnabled = false
        barchartCalorias.rightAxis.drawAxisLineEnabled = false
        barchartCalorias.rightAxis.gridColor = UIColor.clear
        
        barchartCalorias.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barchartCalorias.xAxis.drawGridLinesEnabled = false
        
        self.options = [.toggleValues,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleData,
                        .toggleBarBorders]
        
    }
    
    func cargarDataDB(){
        
        if graficasData!.rawValue == 3{ //sesionActiva
            let sesion = sesionRockAll!
            //Sesion(name: "", time: "", image: #imageLiteral(resourceName: "fire"), created_at: created_at, final_at: final, duration: duration!, type_session_id: type_sessions_id!, final_user_id: final_user_id!, type_training_id: type_training_id!, sensors_id: sensors_id!, training: training, labelTraining: label, typeSession: type_session, esfuerzo: Int(esfuerzoMain!), frecuencia: Int(frecuenciaMain!), calorias: caloriasMain!, graficas: [:], rewards: [:])
            
            //load data from sesion
            let durationSesion = sesion.duration
            //var interval: TimeInterval = durationSesion
            //let ms = Int((durationSesion % 1) * 1000)
            let seconds = durationSesion % 60
            let minutes = (durationSesion / 60) % 60
            let hours = (durationSesion / 3600)
            
            let lastDuration = NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
            
            timeLabel.text = "\(lastDuration)"
            
            heartLabel.text = "\(sesion.heartRate) lpm"
            if sesion.calories > 999 {
                fireLabel.text = "\(sesion.calories / 1000) kcal"
            }else{
                fireLabel.text = "\(sesion.calories) cal"
            }
            
            self.setDataCount(Int(10) + 1, range: UInt32(20))            
            
        }else if graficasData!.rawValue == 2{   //dashboard
        
            let idcreated = UserDefaults.standard.string(forKey: "idcreated")
            
            /*
             Recuperamos el json de la base y pintamos datos
             */
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let predicate = NSPredicate(format: "id = %@", idcreated!)
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sesionjson")
            fetchRequest.predicate = predicate
            
            do {
                let dataSesion = try managedContext.fetch(fetchRequest)
                for data in dataSesion {
                    let datjson = data.value(forKeyPath: "json") as? String
                    let jsonString = datjson?.toJSON()
                    
                    let dataT = JSON(jsonString)
                    //print(dataT)
                    
                    let data = JSON(dataT["data"])
                    
                    //let sesion = getSesion()
                    //from json, get data to load here
                    let created_at = data["created_at"].description
                    let final = data["final"].description
                    let duration = data["duration"].int
                    let type_sessions_id = data["type_sessions_id"].int
                    let final_user_id = data["final_user_id"].int
                    let type_training_id = data["type_training_id"].int
                    let sensors_id = data["sensors_id"].int
                    let training = data["training"].description
                    let label = data["label"].description
                    let type_session = data["type_session"].description
                    let esfuerzoMain = data["esfuerzo"].double
                    let frecuenciaMain = data["frecuencia"].double
                    let caloriasMain = Double(data["calorias"].int!) * 1.0
                    
                    //graficas
                    let sesion = Sesion(name: "", time: "", image: #imageLiteral(resourceName: "fire"), created_at: created_at, final_at: final, duration: duration!, type_session_id: type_sessions_id!, final_user_id: final_user_id!, type_training_id: type_training_id!, sensors_id: sensors_id!, training: training, labelTraining: label, typeSession: type_session, percentage: Int(esfuerzoMain!), heartRate: Int(frecuenciaMain!), calories: caloriasMain, graficas: [:], rewards: [:])
                    
                    //sesion.graficas["esfuerzo"] = graficaFinalesfuerzo
                    //sesion.graficas["frecuencia"] = graficaFinalfrecuencia
                    //sesion.graficas["calorias"] = graficaFinalCalorias
                    
                    //load data from sesion
                    let durationSesion = sesion.duration
                    //var interval: TimeInterval = durationSesion
                    //let ms = Int((durationSesion % 1) * 1000)
                    let seconds = durationSesion % 60
                    let minutes = (durationSesion / 60) % 60
                    let hours = (durationSesion / 3600)
                    
                    let lastDuration = NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
                    
                    timeLabel.text = "\(lastDuration)"
                    
                    heartLabel.text = "\(sesion.heartRate) lpm"
                    if sesion.calories > 999 {
                        fireLabel.text = "\(sesion.calories / 1000) kcal"
                    }else{
                        fireLabel.text = "\(sesion.calories) cal"
                    }
                    
                    self.setDataCount(Int(10) + 1, range: UInt32(20))
                    break
                }
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func updateChartData() {
        if self.shouldHideData {
            barchartEsfuerzo.data = nil
            return
        }
        
        //self.setDataCount(Int(10) + 1, range: UInt32(20))
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        //let graphPoint = chartView.getMarkerPosition(highlight: highlight)
        let marker = RadarMarkerView.viewFromXib()!
        graficaTipo = "resumen"

        if chartView == barchartCalorias{
            stringLabel = "Calorías: "
            colorBack = .yellow
        }else if chartView == barchartFrecuencia{
            stringLabel = "Frecuencia: "
            colorBack = .red
        }else if chartView == barchartEsfuerzo{
            stringLabel = "Esfuerzo: "
            colorBack = .blue
        }
        /*let set = chartView.data?.dataSets
         for set in chartView.data!.dataSets as! [LineChartDataSet] {
         set.drawCirclesEnabled = false //!set.drawCirclesEnabled
         }*/
        
        //let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),font: .systemFont(ofSize: 18),textColor: .white,insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        chartView.marker = marker
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        
        /*valuesHeart = datosHeart.map { (arg0) -> ChartDataEntry in
         let (key, value) = arg0
         return ChartDataEntry(x: Double(key), y: Double(value), icon: #imageLiteral(resourceName: "fire"))
         }*/
        
        /*let values = (0..<count).map { (i) -> ChartDataEntry in
         let val = Double(arc4random_uniform(range) + 3)
         return ChartDataEntry(x: Double(i), y: val, icon: #imageLiteral(resourceName: "fire"))
         }*/
        /*valuesFrec = datosCalorias.map { (arg0) -> ChartDataEntry in
         let (key, value) = arg0
         return ChartDataEntry(x: Double(key), y: Double(value), icon: #imageLiteral(resourceName: "fire"))
         }*/
        
        //let set1 = LineChartDataSet(entries: valuesPorc, label: "Esfuerzo")
        //let set2 = LineChartDataSet(entries: valuesCalo, label: "Frecuencia")
        //let set3 = LineChartDataSet(entries: valuesHeart, label: "Calorias")

        //pintar circulitos en grafica
        set1!.drawCirclesEnabled = false
        set2!.drawCirclesEnabled = false
        set3!.drawCirclesEnabled = false
        
        //draw icon in every point
        set1!.drawIconsEnabled = false
        set2!.drawIconsEnabled = false
        set3!.drawIconsEnabled = false
        
        //dash entre lineas de la grafica
        //set1.lineDashLengths = [5, 2.5]
        //set1.highlightLineDashLengths = [5, 2.5]
        set1!.setColor(.blue)
        set1!.setCircleColor(.gray)
        set1!.lineWidth = 1
        //le pone el radio a los circulitos de cada punto
        set1!.circleRadius = 3
        //como una clase de cirulo central
        set1!.drawCircleHoleEnabled = false
        set1!.valueFont = .systemFont(ofSize: 9)
        //toogle Y values
        set1!.drawValuesEnabled = false
        //rounded graph
        set1!.mode = .cubicBezier
        
        set2!.setColor(.red)
        set2!.setCircleColor(.gray)
        set2!.lineWidth = 1
        //le pone el radio a los circulitos de cada punto
        set2!.circleRadius = 3
        //como una clase de cirulo central
        set2!.drawCircleHoleEnabled = false
        set2!.valueFont = .systemFont(ofSize: 9)
        //toogle Y values
        set2!.drawValuesEnabled = false
        //rounded graph
        set2!.mode = .cubicBezier
        //set1.formLineDashLengths = [5, 2.5]
        //set1.formLineWidth = 1
        //set1.formSize = 15
        
        //dash entre lineas de la grafica
        //set1.lineDashLengths = [5, 2.5]
        //set1.highlightLineDashLengths = [5, 2.5]
        set3!.setColor(.yellow)
        set3!.setCircleColor(.gray)
        set3!.lineWidth = 1
        //le pone el radio a los circulitos de cada punto
        set3!.circleRadius = 3
        //como una clase de cirulo central
        set3!.drawCircleHoleEnabled = false
        set3!.valueFont = .systemFont(ofSize: 9)
        //toogle Y values
        set3!.drawValuesEnabled = false
        //rounded graph
        set3!.mode = .cubicBezier
        
        /*let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
         ChartColorTemplates.colorFromString("#ffff0000").cgColor]
         let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
         
         set1.fillAlpha = 1
         set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
         set1.drawFilledEnabled = true*/
        
        //dataSets.append(set1)
        //dataSets.append(set2)
        let datap = LineChartData()
        datap.addDataSet(set1)
        self.barchartEsfuerzo.data = datap
        
        let data = LineChartData()
        data.addDataSet(set2)
        self.barchartFrecuencia.data = data

        let dataC = LineChartData()
        dataC.addDataSet(set3)
        self.barchartCalorias.data = dataC
    }
}
