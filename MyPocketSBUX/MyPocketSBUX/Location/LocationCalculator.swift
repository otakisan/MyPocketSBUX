//
//  LocationCalculator.swift
//  MyPocketSBUX
//
//  Created by takashi on 2016/01/03.
//  Copyright © 2016年 Takashi Ikeda. All rights reserved.
//

import UIKit
import MapKit

class LocationCalculator: NSObject {
    
    static let instance = LocationCalculator()
    
    //------------------------------------------------------------------------------
    // 二点間の距離を計算する（ｍ）※メルカトル？での直線距離
    //------------------------------------------------------------------------------
    func locationDistance(loc1 : CLLocationCoordinate2D, loc2 : CLLocationCoordinate2D) -> Double {
        
        // 2点の緯度の平均
        let latAvg : Double = (( loc1.latitude + ((loc2.latitude - loc1.latitude)/2) ) / 180) * M_PI
        
        // 2点の緯度差
        let latDifference : Double = (( loc1.latitude - loc2.latitude ) / 180) * M_PI
        
        // 2点の経度差
        let lonDifference : Double = (( loc1.longitude - loc2.longitude ) / 180) * M_PI
        let curRadiusTemp : Double = 1 - 0.00669438 * pow(sin(latAvg), 2)
        
        // 子午線曲率半径
        let meridianCurvatureRadius : Double = 6335439.327 / sqrt(pow(curRadiusTemp, 3))
        
        // 卯酉線曲率半径
        let primeVerticalCircleCurvatureRadius : Double = 6378137 / sqrt(curRadiusTemp)
        
        // 2点間の距離
        var distance : Double = pow(meridianCurvatureRadius * latDifference, 2)
            + pow(primeVerticalCircleCurvatureRadius * cos(latAvg) * lonDifference, 2)
        distance = sqrt(distance)
        
        // Intで丸める場合
        //let distanceInt : Int = Int(round(distance))
        
        return distance
    }
    
    func locationDistanceRoute(fromCoordinate : CLLocationCoordinate2D, toCoordinate : CLLocationCoordinate2D, completionHandler : (Double?, NSError?) -> Void) {
        
        // CLLocationCoordinate2D から MKPlacemark を生成
        let fromPlacemark = MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil)
        let toPlacemark = MKPlacemark(coordinate: toCoordinate, addressDictionary: nil)
        
        // MKPlacemark から MKMapItem を生成
        let fromItem = MKMapItem(placemark: fromPlacemark)
        let toItem = MKMapItem(placemark: toPlacemark)
        
        // MKMapItem をセットして MKDirectionsRequest を生成
        let request = MKDirectionsRequest()
        request.source = fromItem;
        request.destination = toItem;
        request.requestsAlternateRoutes = true
        
        // MKDirectionsRequest から MKDirections を生成
        let directions = MKDirections(request: request)
        
        // 経路検索を実行
        // TODO: 前回のdirections.calculatingがfalseでないとならないが、
        // 暫定的にそのまま突っ込み、呼び出し元で対応する。
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            var distanceValue : Double?
            if error == nil, let directionsResponse = response where directionsResponse.routes.count > 0 {
                let route = directionsResponse.routes.first!
                distanceValue = route.distance
            }
            
            completionHandler(distanceValue, error)
        }
    }
    
    func locationDistanceRouteSync(fromCoordinate : CLLocationCoordinate2D, toCoordinate : CLLocationCoordinate2D) -> (distance : Double?, error : NSError?) {
        let semaphoreCount = 0
        let semaphore = dispatch_semaphore_create(semaphoreCount)
        let timeoutInSeconds = 10.0
        let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(timeoutInSeconds * Double(NSEC_PER_SEC)))
        
        var distanceResult : Double?
        var errorResult : NSError?
        self.locationDistanceRoute(fromCoordinate, toCoordinate: toCoordinate) { (distance, error) -> Void in
            errorResult = error
            if error == nil {
                distanceResult = distance
            }
            
            dispatch_semaphore_signal(semaphore)
        }
        
        // TODO: おそらくdirections.calculatingであると、完了ハンドラがコールされずタイムアウトとなる
        if dispatch_semaphore_wait(semaphore, timeout) != 0 {
            print("locationDistanceRouteSync timeout")
        }
        
        return (distance : distanceResult, error : errorResult)
    }

}
