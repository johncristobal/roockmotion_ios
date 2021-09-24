//
//  DetailsBranchViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 9/9/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class DetailsBranchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GMSMapViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var sendButton: UIButton!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var descriptionText: UILabel!
    @IBOutlet var nameText: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    var branch: Branch?
    var images: [String] = [] 
    
    var manager = DataManager.shared

    @IBOutlet weak var collectionImages: UICollectionView!
    var mapViewM : GMSMapView? = nil
    var loadingSesiones : UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sendButton.roundCorner()
        nameText.text = branch?.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("didappear details branch")
        getInfoBranch()
    }
    
    func getInfoBranch(){

        showLoading(titulo: "Información", mensaje: "Cargando detalles...")
        
        let manager = DataManager.shared
        manager.BranchInfo(branch: branch!) { (resp) in
            
                switch resp.resp{
                case "ok":
                    self.branch = manager.branchTemp
                    self.images = self.branch!.images
                    self.pageControl.numberOfPages = self.branch!.images.count
                    self.collectionImages.reloadData()
                    
                    //self.descriptionText.text = self.branch?.descriptionB
                    self.descriptionText.attributedText = self.branch?.descriptionB.htmlToAttributedString
                    
                    if self.branch?.link == 0{
                        self.sendButton.setTitle("Activar", for: .normal)
                    }else{
                        self.sendButton.setTitle("Desactivar", for: .normal)
                    }
                    self.loadMapa()
                    
                    DispatchQueue.main.async {
                        self.loadingSesiones?.dismiss(animated: true, completion: {
                            
                        })
                    }

                    break
                default:
                    DispatchQueue.main.async {
                        self.loadingSesiones?.dismiss(animated: true, completion: {
                            showmessage(message: resp.mes, controller: self)
                        })
                    }
                    break
                }
        }
    }
    
    func loadMapa(){
        let camera = GMSCameraPosition.camera(withLatitude: branch!.latitude, longitude: branch!.longitude, zoom: 12.0)
        mapView.camera = camera
        //mapViewM = GMSMapView.map(withFrame: mapView.frame, camera: camera)
        //mapViewM?.center = self.mapView.center
        //mapViewM?.isMyLocationEnabled = true
        //mapViewM?.settings.myLocationButton = true

        let position = CLLocationCoordinate2DMake(branch!.latitude,branch!.longitude)
        let marker = GMSMarker(position: position)
        marker.title = branch!.address
        marker.map = mapView
        
        mapView?.delegate = self
        //self.mapView.addSubview(mapViewM!)
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "celdaFoto", for: indexPath) as! ImagesMapCollectionViewCell
     
        let urlImage = images[indexPath.row]
        let url = NSURL(string: urlImage)
        let data = NSData(contentsOf: url! as URL)
        cell.pictureImage.image = UIImage(data: data! as Data)
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.pageControl.currentPage = indexPath.row
    }

    
    @IBAction func activarAction(_ sender: Any) {
        
        if perfilCompleto(){
            showLoading(titulo: "Información", mensaje: "Enviando...")
            let manager = DataManager.shared
            manager.BranchInfoActive(branch: branch!, option: (self.branch?.link.description)!) { (resp) in
                DispatchQueue.main.async {
                    self.loadingSesiones?.dismiss(animated: true, completion: {
                        
                        switch resp.resp{
                        case "ok":
                            
                            if self.branch?.link == 0{
                                self.branch?.link = 1
                                self.sendButton.setTitle("Desactivar", for: .normal)
                            }else{
                                self.branch?.link = 0
                                self.sendButton.setTitle("Activar", for: .normal)
                            }
                            
                            let alerta = UIAlertController(title: "¡Hecho!", message: resp.mes, preferredStyle: .alert)
                            alerta.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alerta, animated: true)
                            
                            break
                        default:
                            showmessage(message: resp.mes, controller: self)
                            break
                        }
                    })
                }
            }
        }else{
            let alert = UIAlertController(title: "", message: "Es necesario completar la información de tu perfil para iniciar sesiones de entrenamiento.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Completar perfil", style: .default, handler: { (alert) in
                
                self.performSegue(withIdentifier: "perfilSegueFull", sender: nil)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { (alert) in
                
            }))

            present(alert, animated: true)
            
            //alert * Es necesario completar la información de tu perfil para iniciar sesiones de entrenamiento
        }
        
        
    }
    
    func perfilCompleto() -> Bool {
        let user = manager.user
        
        if user?.pseudonym == ""{
            return false
        }
        if user?.birthday == ""{
            return false
        }
        if user?.phone == ""{
            return false
        }
        if user?.sexo == ""{
            return false
        }
        if user?.peso == 0.0{
            return false
        }
        if user?.estatura == 0{
            return false
        }
        
        return true
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
