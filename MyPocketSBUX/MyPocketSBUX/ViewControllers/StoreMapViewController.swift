//
//  StoreMapViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import MapKit

class StoreMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var storeMap: MKMapView!
    
    var centerCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.634616, 139.714205)
    var annotations : [(coordinate : (latitude : Double, longitude : Double), title : String, subStitle : String)] = []
    
    func initializeMap(){
        self.storeMap.delegate = self

        // 緯度・軽度を設定
        storeMap?.setCenterCoordinate(self.centerCoordinate, animated:true)
        
        // 縮尺を設定
        var region : MKCoordinateRegion = self.storeMap!.region
        region.center = self.centerCoordinate
        region.span.latitudeDelta = 0.002
        region.span.longitudeDelta = 0.002
        
        self.storeMap!.setRegion(region, animated:true)
        
        // 表示タイプを航空写真と地図のハイブリッドに設定
        self.storeMap!.mapType = MKMapType.Standard
        
        // ピンを追加
        self.addAnnotations()
    }
    
    func addAnnotations(){
        for annotationInfo in self.annotations {
            var annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(annotationInfo.coordinate.latitude, annotationInfo.coordinate.longitude)
            annotation.title = annotationInfo.title
            annotation.subtitle = annotationInfo.subStitle
            self.storeMap.addAnnotation(annotation)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
