//
//  PesoGraphViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 8/22/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import Charts

class WeightGraphViewController: UIViewController,ChartViewDelegate {

    @IBOutlet var labelWeight: UILabel!
    @IBOutlet var graphView: LineChartView!
    
    let manager = DataManager.shared
    var loadingSesiones : UIAlertController?
    var weightData : [String:Double] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphView.delegate = self
        graphView.chartDescription?.enabled = false
        graphView.dragEnabled = true
        graphView.setScaleEnabled(true)
        graphView.pinchZoomEnabled = false
        graphView.setViewPortOffsets(left: 30, top: 10, right: 30, bottom: 50)
        
        graphView.backgroundColor = .black

        graphView.leftAxis.enabled = true
        graphView.leftAxis.drawAxisLineEnabled = true
        graphView.leftAxis.drawGridLinesEnabled = true
        graphView.leftAxis.gridColor = UIColor.black
        
        let leftAxis = graphView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelTextColor = .white
        
        //leftAxis.labelCount = 8
        leftAxis.axisMaximum = 150.0
        leftAxis.axisMinimum = 40.0
        leftAxis.labelPosition = .outsideChart
        //leftAxis.spaceTop = 0.15
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = false
        
        let xAxis = graphView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelTextColor = .white
        xAxis.drawAxisLineEnabled = false
        //xAxis.granularity = 3600
        xAxis.valueFormatter = DateValueFormatterPeso()
        xAxis.labelCount = 4
        xAxis.labelRotationAngle = 65.0
            
        graphView.rightAxis.enabled = false
        graphView.rightAxis.drawGridLinesEnabled = false
        graphView.rightAxis.drawAxisLineEnabled = false
        graphView.rightAxis.gridColor = UIColor.clear
        
        graphView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        graphView.xAxis.drawGridLinesEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        showLoading(titulo: "Información", mensaje: "Recuperando datos...")
        manager.weightData { (respuesta) in
            switch respuesta.resp {
            case "ok":
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        self.weightData = self.manager.weightData
                        self.setDataCount(0, range: 0)
                    }
                )}
                break
            default:
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        showmessage(message: respuesta.mes, controller: self)
                    }
                )}
                
                break
            }
        }
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let data = LineChartData()
        
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
        
        /*
        let hourSeconds: TimeInterval = 3600
        let from = pesoDataDpos.first!.value * hourSeconds
        let to = pesoDataDpos.last!.value * hourSeconds
        
        let values = stride(from: from, to: to, by: hourSeconds).map { (x) -> ChartDataEntry in
            let y = arc4random_uniform(range) + 50
            return ChartDataEntry(x: x, y: Double(y))
        }*/
        
        let weightDataDpos = weightData.sorted(by : <)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let entryData = weightDataDpos.map { (arg0) -> ChartDataEntry in
            
            let (key, value) = arg0
            let valueFinal = (value)
            let date = dateFormatter.date(from: key)
            let nowDouble = date!.timeIntervalSince1970
            return ChartDataEntry(x: nowDouble, y: Double(valueFinal), icon: #imageLiteral(resourceName: "sliderselectorxxhdpi"))
        }
        
        let set1 = LineChartDataSet(entries: entryData, label: "Peso")
        
        //pintar circulitos en grafica
        set1.drawCirclesEnabled = true
        set1.circleColors = [(UIColor(red: 133.0/255.0, green: 169.0/255.0, blue: 215.0/255.0, alpha: 1.0))]
        set1.circleRadius = 3.0
        //set1.axisDependency = .left

        //draw icon in every point
        set1.drawIconsEnabled = false
        set1.fillColor = (UIColor(red: 133.0/255.0, green: 169.0/255.0, blue: 215.0/255.0, alpha: 1.0))
        //dash entre lineas de la grafica
        //set1.lineDashLengths = [5, 2.5]
        //set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(UIColor(red: 133.0/255.0, green: 169.0/255.0, blue: 215.0/255.0, alpha: 1.0))
        set1.setCircleColor(UIColor(red: 133.0/255.0, green: 169.0/255.0, blue: 215.0/255.0, alpha: 1.0))
        set1.lineWidth = 2
        
        //le pone el radio a los circulitos de cada punto
        //set1.circleRadius = 9
        //como una clase de cirulo central
        //set1.drawCircleHoleEnabled = true
        
        set1.valueFont = .systemFont(ofSize: 9)
        
        //toogle Y values
        set1.drawValuesEnabled = false
        
        //rounded graph
        //set1.mode = .cubicBezier
        
        
        //set1.formLineDashLengths = [5, 2.5]
        //set1.formLineWidth = 1
        //set1.formSize = 15
        
        /*let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
         ChartColorTemplates.colorFromString("#ffff0000").cgColor]
         let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
         
         set1.fillAlpha = 1
         set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
         set1.drawFilledEnabled = true*/
        
        //dataSets.append(set1)
        //dataSets.append(set2)
        
        data.addDataSet(set1)
        graphView.data = data
    }
    
    func showLoading(titulo: String, mensaje: String){
        loadingSesiones = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        loadingSesiones!.view.tintColor = UIColor.black
        //CGRect(x: 1, y: 5, width: self.view.frame.size.width - 20, height: 120))
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        loadingSesiones!.view.addSubview(loadingIndicator)
        self.present(loadingSesiones!, animated: true, completion: nil)
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let marker = RadarMarkerView.viewFromXib()!
        let actualWeight = entry.y
        labelWeight.text = "\(actualWeight) Kg."
        stringLabel = "Peso: "
        colorBack = UIColor(red: 133.0/255.0, green: 169.0/255.0, blue: 215.0/255.0, alpha: 1.0)
        graficaTipo = "peso"
        chartView.marker = marker
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
