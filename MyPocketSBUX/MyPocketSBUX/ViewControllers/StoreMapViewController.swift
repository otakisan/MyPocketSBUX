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

    struct StoryboardConstants {
        static let storyboardName = "Main"
        static let viewControllerIdentifier = "StoreMapViewController"
    }

    @IBOutlet weak var storeMap: MKMapView!
    
    var centerCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.634616, 139.714205)
    var annotations : [(coordinate : (latitude : Double, longitude : Double), title : String, subStitle : String, store : Store?)] = []
    
    class func forStoreMap(store : Store?) -> StoreMapViewController {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardConstants.viewControllerIdentifier) as! StoreMapViewController
        
        if let storeInfo = store {
            viewController.centerCoordinate = CLLocationCoordinate2DMake(Double(storeInfo.latitude), Double(storeInfo.longitude))
            viewController.annotations = [(coordinate : (latitude : Double(storeInfo.latitude), longitude : Double(storeInfo.longitude)), title : storeInfo.name, subStitle : "\(DateUtility.localTimeString(storeInfo.openingTimeWeekday)) - \(DateUtility.localTimeString(storeInfo.closingTimeWeekday))", store : storeInfo)]
        }
        
        return viewController
    }

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
        // カスタムで店舗アノテーション作成し、店舗詳細情報を保持する
        for annotationInfo in self.annotations {
            let annotation = StoreAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(annotationInfo.coordinate.latitude, annotationInfo.coordinate.longitude)
            annotation.title = annotationInfo.title
            annotation.subtitle = annotationInfo.subStitle
            annotation.store = annotationInfo.store
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

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        
        var annotationView : MKAnnotationView?
        if let annoView = mapView.dequeueReusableAnnotationViewWithIdentifier("PinAnnotationView") {
            annoView.annotation = annotation
            annotationView = annoView
        }
        else {
            let annotationViewCreated = MKPinAnnotationView(annotation: annotation, reuseIdentifier:"PinAnnotationView")
            annotationViewCreated.canShowCallout = true
            
            let button = UIButton(type: UIButtonType.DetailDisclosure)
            button.frame = CGRectMake(0, 0, 30, 30)
            annotationViewCreated.rightCalloutAccessoryView = button
            
            annotationViewCreated.pinColor = MKPinAnnotationColor.Red
            
            annotationView = annotationViewCreated
        }

        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        if let store = (view.annotation as? StoreAnnotation)?.store {
            self.pushStoreDetailViewOnCellSelected(store)
        }
    }
    
    func pushStoreDetailViewOnCellSelected(store : Store) {
        
        // Set up the detail view controller to show.
        let detailViewController = StoreDetailTableViewController.forStore(store)

        self.navigationController?.pushViewController(detailViewController, animated: true)
    }

}
