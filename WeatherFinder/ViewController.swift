//
//  ViewController.swift
//  WeatherFinder
//
//  Created by Prakash Kumar Rastogi on 05/09/18.
//  Copyright © 2018 Futuremind Technology Solutions. All rights reserved.
//

import UIKit
import MapKit

import Toast_Swift

class ViewController: UIViewController, LocationUpdateProtocol {

    @IBOutlet weak var weatherInfoView:UIView?
    @IBOutlet weak var weatherMessage:UITextView?
    @IBOutlet weak var cancelButton:UIButton?
    
    @IBOutlet weak var mapViewObj:MKMapView?
    
    var locManager:LocManager? = nil
    var currentLocation : CLLocation!
    
    var apiHandler:APIHandler? = nil
    
    var cacheObject:NSCache<NSString, AnyObject>?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapSettings()
        
        self.cacheObject = NSCache<NSString, AnyObject>()
        
        self.weatherInfoView?.isHidden = true
        self.weatherMessage?.text = ""
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapSettings(){
        
        if CLLocationManager.locationServicesEnabled() {
            
            let longGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action:#selector(ViewController.longpressOnMapAction(_:)))
            longGesture.delaysTouchesBegan = true
            longGesture.minimumPressDuration = 1.0
            self.mapViewObj?.addGestureRecognizer(longGesture)
            
            if self.apiHandler == nil{
                self.apiHandler = APIHandler.SharedManager
            }
            
            self.mapViewObj?.showsUserLocation = true
            self.mapViewObj?.delegate = self
            
            if self.locManager == nil{
                //NotificationCenter.default.addObserver(self, selector: Selector(("locationUpdateNotification:")), name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: nil)
                self.locManager = LocManager.SharedManager
                //self.locManager?.delegate = self as LocationUpdateProtocol
            }
            
        }
        
    }
    
    @objc func longpressOnMapAction(_ longpress:UILongPressGestureRecognizer){
        
         if longpress.state == .began {
            
            // display toast with an activity spinner
            self.view.makeToastActivity(.center)
            self.view.isUserInteractionEnabled = false
            
            let touchPoint = longpress.location(in: self.mapViewObj)
            let newCoordinates = self.mapViewObj?.convert(touchPoint, toCoordinateFrom: self.mapViewObj)
            if let newCoordinates = newCoordinates{
                self.apiHandler?.getWeatherInfoAtLocation(newCoordinates, { (responseData, error, success) in
                    
                    if success == false{
                        //Error
                        
                        // hides toast views in self.view
                        self.view.hideToastActivity()
                        self.view.isUserInteractionEnabled = true
                        
                        self.view.makeToast("Sorry we could not find Weather for selected location. Please try again")
                        
                    }else{
                        
                        let latlongString = String(format: "(%f,%f)", newCoordinates.latitude,newCoordinates.longitude)
                        
                        self.cacheObject?.setObject(responseData as AnyObject, forKey: latlongString as NSString)
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = newCoordinates
                        self.mapViewObj?.addAnnotation(annotation)
                        self.mapViewObj?.selectAnnotation(annotation, animated: true)
                        
                        // hides toast views in self.view
                        self.view.hideToastActivity()
                        self.view.isUserInteractionEnabled = true
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    // MARK: - Notifications
    
    func locationUpdateNotification(notification: NSNotification) {
        let userinfo = notification.userInfo
        self.currentLocation = userinfo!["location"] as! CLLocation
        print("Latitude : \(self.currentLocation.coordinate.latitude)")
        print("Longitude : \(self.currentLocation.coordinate.longitude)")
        
    }
    
    // MARK: - LocationUpdateProtocol
    
    func locationDidUpdateToLocation(location: CLLocation) {
        currentLocation = location
        print("Latitude : \(self.currentLocation.coordinate.latitude)")
        print("Longitude : \(self.currentLocation.coordinate.longitude)")
    }
    
    @IBAction func cancelButtonAction(_ sender : AnyObject){
        
        self.weatherInfoView?.isHidden = true
        self.weatherMessage?.text = ""
    }

}

extension ViewController : MKMapViewDelegate{
    
    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        self.weatherInfoView?.isHidden = true
        self.weatherMessage?.text = ""
        
        if let coordinate = view.annotation?.coordinate
        {
            
            let latlongString = String(format: "(%f,%f)", coordinate.latitude,coordinate.longitude)
            if let cachedVersion = self.cacheObject?.object(forKey: latlongString as NSString) {
                // use the cached version
                let weatherInfo = cachedVersion.debugDescription
                if let weatherInfo = weatherInfo{
                    print("Weather Info = %@",weatherInfo)
                    self.weatherInfoView?.isHidden = false
                    self.weatherMessage?.text = weatherInfo
                }
            }
            
        }
        
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.weatherInfoView?.isHidden = true
        self.weatherMessage?.text = ""
    }
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
        mapView.setRegion(region, animated: true)
    }
    
}
