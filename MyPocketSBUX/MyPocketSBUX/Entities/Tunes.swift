//
//  Tunes.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/09.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class Tunes: DbContextBase {
    static var contextInstance : Tunes = Tunes()
    
    class func instance() -> Tunes{
        return contextInstance
    }
    
    override func entityName() -> String {
        return "Tune"
    }
    
    override func insertEntityFromJsonObject(jsonObject : NSArray) {
        
        for newData in jsonObject {
            let entity : Tune = Tunes.instance().createEntity()
            entity.id = (newData["id"] as? NSNumber) ?? 0
            
            entity.wrapperType = ((newData["wrapper_type"] as? NSString) ?? "") as String
            entity.kind = ((newData["kind"] as? NSString) ?? "") as String
            entity.artistId = ((newData["artist_id"] as? NSString) ?? "") as String
            entity.collectionId = ((newData["collection_id"] as? NSString) ?? "") as String
            entity.trackId = ((newData["track_id"] as? NSString) ?? "") as String
            entity.artistName = ((newData["artist_name"] as? NSString) ?? "") as String
            entity.collectionName = ((newData["collection_name"] as? NSString) ?? "") as String
            entity.trackName = ((newData["track_name"] as? NSString) ?? "") as String
            entity.collectionCensoredName = ((newData["collection_censored_name"] as? NSString) ?? "") as String
            entity.trackCensoredName = ((newData["track_censored_name"] as? NSString) ?? "") as String
            entity.artistViewUrl = ((newData["artist_view_url"] as? NSString) ?? "") as String
            entity.collectionViewUrl = ((newData["collection_view_url"] as? NSString) ?? "") as String
            entity.trackViewUrl = ((newData["track_view_url"] as? NSString) ?? "") as String
            entity.previewUrl = ((newData["preview_url"] as? NSString) ?? "") as String
            entity.artworkUrl30 = ((newData["artwork_url_30"] as? NSString) ?? "") as String
            entity.artworkUrl60 = ((newData["artwork_url_60"] as? NSString) ?? "") as String
            entity.artworkUrl100 = ((newData["artwork_url_100"] as? NSString) ?? "") as String
            entity.collectionPrice = (newData["collection_price"] as? NSDecimalNumber) ?? 0
            entity.trackPrice = (newData["track_price"] as? NSDecimalNumber) ?? 0
            entity.releaseDate = (newData["release_date"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.collectionExplicitness = ((newData["collection_explicitness"] as? NSString) ?? "") as String
            entity.trackExplicitness = ((newData["track_explicitness"] as? NSString) ?? "") as String
            entity.discCount = (newData["disc_count"] as? NSNumber) ?? 0
            entity.discNumber = (newData["disc_number"] as? NSNumber) ?? 0
            entity.trackCount = (newData["track_count"] as? NSNumber) ?? 0
            entity.discCount = (newData["disc_count"] as? NSNumber) ?? 0
            entity.trackNumber = (newData["track_number"] as? NSNumber) ?? 0
            entity.trackTimeMillis = (newData["track_time_millis"] as? NSNumber) ?? 0
            entity.country = ((newData["country"] as? NSString) ?? "") as String
            entity.currency = ((newData["currency"] as? NSString) ?? "") as String
            entity.primaryGenreName = ((newData["primary_genre_name"] as? NSString) ?? "") as String
            entity.radioStationUrl = ((newData["radio_station_url"] as? NSString) ?? "") as String
            
            entity.createdAt = (newData["created_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = (newData["updated_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            
            Tunes.insertEntity(entity)
        }
    }
   
}
