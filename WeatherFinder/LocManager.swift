//
//  LocManager.swift
//  WeatherFinder
//
//  Created by Prakash Kumar Rastogi on 05/09/18.
//  Copyright © 2018 Futuremind Technology Solutions. All rights reserved.
//

import Foundation
import MapKit

protocol LocationUpdateProtocol {
    func locationDidUpdateToLocation(location : CLLocation)
}

/// Notification on update of location. UserInfo contains CLLocation for key "location"
let kLocationDidChangeNotification = "LocationDidChangeNotification"

class LocManager: NSObject {
    
    static let SharedManager = LocManager()
    
    private var locationManager = CLLocationManager()
    
    var currentLocation : CLLocation?
    
    var delegate : LocationUpdateProtocol!
    
    private override init () {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
}

extension LocManager : CLLocationManagerDelegate{
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        currentLocation = newLocation
//        let userInfo : NSDictionary = ["location" : currentLocation!]
//        DispatchQueue.main.async() { () -> Void in
//            self.delegate.locationDidUpdateToLocation(location: self.currentLocation!)
//            NotificationCenter.defaultCenter().postNotificationName(kLocationDidChangeNotification, object: self, userInfo: userInfo as [NSObject : AnyObject])
//        }
    }
    
}
