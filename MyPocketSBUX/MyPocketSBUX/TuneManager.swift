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
        return [
            TuneItem(artistId: "2989382", artistName: "Belle and Sebastian", trackId: "121961364", trackName: "Another Sunny Day", previewUrl: "http://a298.phobos.apple.com/us/r1000/094/Music2/v4/16/90/6e/16906e19-6acc-d92a-7372-0fff83e64d34/mzaf_8263831453625822478.m4a"),
            TuneItem(artistId: "2989382", artistName: "Belle and Sebastian", trackId: "391817182", trackName: "Little Lou, Ugly Jack, Prophet John", previewUrl: "http://a542.phobos.apple.com/us/r1000/087/Music2/v4/26/97/8d/26978d3e-be47-7ad2-7994-ed7bc1508675/mzaf_7249662553316926558.m4a")
        ]
    }
    
    func play(tuneUrl: String) -> AVAudioPlayer? {
        var av: AVAudioPlayer?
        if let url = NSURL(string: tuneUrl) {
            var data = NSData(contentsOfURL: url)
            av = AVAudioPlayer(data: data, error: nil)
            av?.play()
        }
        
        return av
    }
}

class TuneItem {
    init(){
        
    }
    
    init(artistId: String, artistName: String, trackId: String, trackName: String, previewUrl: String){
        self.artistName = artistName
        self.artistId = artistId
        self.trackId = trackId
        self.trackName = trackName
        self.previewUrl = previewUrl
    }
    
    var artistId = ""
    var artistName = ""
    var trackId = ""
    var trackName = ""
    var previewUrl = ""
}
