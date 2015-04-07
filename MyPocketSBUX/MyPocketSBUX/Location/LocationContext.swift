//
//  LocationContext.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreLocation

class LocationContext: NSObject, CLLocationManagerDelegate {

    struct Singleton {
        static var currentLocation : LocationContext?
    }
    
    class var current : LocationContext {
        if Singleton.currentLocation == nil {
            Singleton.currentLocation = LocationContext()
            Singleton.currentLocation?.initialize()
        }
        
        return Singleton.currentLocation!
    }
    
    var locationManager = CLLocationManager()
    var coordinate : CLLocationCoordinate2D?
    
    func initialize(){
        locationManager.delegate = self
        //位置情報取得の可否。バックグラウンドで実行中の場合にもアプリが位置情報を利用することを許可する
        locationManager.requestWhenInUseAuthorization()
        //位置情報の精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //位置情報取得間隔(m)
        locationManager.distanceFilter = 100
        
        locationManager.startUpdatingLocation()
    }
    
    /** 位置情報取得成功時 */
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        self.coordinate = newLocation.coordinate
    }
    
    /** 位置情報取得失敗時 */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        //NSLog("Error")
    }

}
