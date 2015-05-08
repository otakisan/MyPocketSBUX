//
//  SettingsManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/08.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class SettingsManager: NSObject {
    
    struct Defs {
        struct SiteForPlayingTunes {
            static let key = "SiteForPlayingTunes"
            static let defalut = iTunes
            static let codes = [iTunes, youTube]
            static let iTunes = "iTunes"
            static let youTube = "YouTube"
        }
    }
    
    static let instance = SettingsManager()
    lazy var settings : NSUserDefaults = self.initialize()
    
    func initialize() -> NSUserDefaults {
        NSUserDefaults.standardUserDefaults().registerDefaults([Defs.SiteForPlayingTunes.key:Defs.SiteForPlayingTunes.defalut])
        
        return NSUserDefaults.standardUserDefaults()
    }
    
    var siteForPlayingTunes : String {
        get {
            return self.settings.stringForKey(Defs.SiteForPlayingTunes.key) ?? Defs.SiteForPlayingTunes.defalut
        }
        set(newValue) {
            self.settings.setObject(newValue, forKey: Defs.SiteForPlayingTunes.key)
        }
    }
    
}
