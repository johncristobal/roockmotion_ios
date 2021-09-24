//
//  MapaViewController.swift
//  rockmotion
//
//  Created by i7 on 9/8/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet var mapaGoogle: UIView!
    var mapView : GMSMapView? = nil
    let location: CLLocationManager = CLLocationManager()
    var lastlocation : CLLocation? = nil
    var mapReady = false
    var flagLocation = true
    var loadingSesiones : UIAlertController?
    var arrayBranch: [Branch]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setLocation()
    }
    
    func setLocation(){
        location.delegate = self
        location.requestWhenInUseAuthorization()
        location.startUpdatingLocation()
        location.desiredAccuracy = kCLLocationAccuracyBest
        location.distanceFilter = 2

        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 14.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView!.center = self.view.center
        mapView!.isMyLocationEnabled = true
        mapView!.settings.myLocationButton = true
        mapView?.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loca = locations.last {
            
            lastlocation = loca
            
            if flagLocation {
                flagLocation = false
                
                print("ubicacion")
                                
                let camera = GMSCameraPosition.camera(withLatitude: loca.coordinate.latitude, longitude: loca.coordinate.longitude, zoom: 15.0)
                mapView = GMSMapView.map(withFrame: mapaGoogle.frame, camera: camera)
                mapView?.isMyLocationEnabled = true
                mapView?.settings.myLocationButton = true
                //mapView?.padding = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 20)
                mapView?.delegate = self
                
                self.mapaGoogle.addSubview(mapView!)
                mapReady = true
                
                localiza()
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let data = marker.userData as! Branch
        performSegue(withIdentifier: "detailsBranch", sender: data)
    }
    
    func localiza(){
        showLoading(titulo: "Información", mensaje: "Listando gimnasios...")

        //get location from lastlocation
        let manager = DataManager.shared
        manager.BranchGeoListTask(location: lastlocation!){ (resp) in 
            switch resp.resp {
            case "ok":
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        self.arrayBranch = manager.arrayBranch
                        for item in self.arrayBranch!{
                            let position = CLLocationCoordinate2DMake(item.latitude,item.longitude)
                            let marker = GMSMarker(position: position)
                            marker.title = item.name
                            marker.snippet = item.address
                            marker.icon = #imageLiteral(resourceName: "rookmotionmini")
                            marker.userData = item
                            marker.map = self.mapView
                        }
                    }
                    )}
                break
            default:
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        showmessage(message: resp.mes, controller: self)
                    }
                    )}
                break;
            }
        }
        
    }
    
    @IBAction func searchAction(_ sender: Any) {
        performSegue(withIdentifier: "openListMap", sender: nil)
    }
    
    @IBAction func backWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsBranch"{
            let vc = segue.destination as! DetailsBranchViewController
            vc.branch = sender as? Branch
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
