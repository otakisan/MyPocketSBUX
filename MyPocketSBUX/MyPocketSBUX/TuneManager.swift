//
//  TuneManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/07.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import AVFoundation

class TuneManager: NSObject {
    static let instance = TuneManager()
    
    func tunes() -> [TuneItem] {
        
        var tuneItems : [TuneItem] = []
        let tunes : [Tune] = Tunes.instance().getAllOrderBy([("id", true)])
        for tune in tunes {
            tuneItems += [TuneItem(entity: tune)]
        }
        
        return tuneItems
    }
    
    func play(tuneUrl: String) -> AVAudioPlayer? {
        var av: AVAudioPlayer?
        if let url = NSURL(string: tuneUrl) {
            let data = NSData(contentsOfURL: url)
            av = try? AVAudioPlayer(data: data!)
            av?.play()
        }
        
        return av
    }
    
    func searchKeyword(tuneItem: TuneItem) -> String {
        let separatorChars = ", "
        let artistName = tuneItem.entity.artistName.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: separatorChars))
        let trackName = tuneItem.entity.trackName.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: separatorChars))
        
        let keywords = (artistName + trackName)
        
        return keywords.joinWithSeparator("+")
    }
}

class TuneItem {
    
    init(entity: Tune) {
        self.entity = entity
    }
    
    var entity : Tune!
}
