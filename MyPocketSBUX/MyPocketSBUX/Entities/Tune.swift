//
//  Tune.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/09.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class Tune: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var wrapperType: String
    @NSManaged var kind: String
    @NSManaged var artistId: String
    @NSManaged var collectionId: String
    @NSManaged var trackId: String
    @NSManaged var artistName: String
    @NSManaged var collectionName: String
    @NSManaged var trackName: String
    @NSManaged var collectionCensoredName: String
    @NSManaged var trackCensoredName: String
    @NSManaged var artistViewUrl: String
    @NSManaged var collectionViewUrl: String
    @NSManaged var trackViewUrl: String
    @NSManaged var previewUrl: String
    @NSManaged var artworkUrl30: String
    @NSManaged var artworkUrl60: String
    @NSManaged var artworkUrl100: String
    @NSManaged var collectionPrice: NSDecimalNumber
    @NSManaged var trackPrice: NSDecimalNumber
    @NSManaged var releaseDate: NSDate
    @NSManaged var collectionExplicitness: String
    @NSManaged var trackExplicitness: String
    @NSManaged var discCount: NSNumber
    @NSManaged var discNumber: NSNumber
    @NSManaged var trackCount: NSNumber
    @NSManaged var trackNumber: NSNumber
    @NSManaged var trackTimeMillis: NSNumber
    @NSManaged var country: String
    @NSManaged var currency: String
    @NSManaged var primaryGenreName: String
    @NSManaged var radioStationUrl: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate

}
