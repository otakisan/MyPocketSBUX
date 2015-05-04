//
//  MakingCoffeeContentsManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class MakingCoffeeContentsManager: NSObject {
    static let pourOver = MakingCoffeeContentsManager()
    
    class func contentsManager(type : MakingCoffeeContentType) -> MakingCoffeeContentsManager {
        let manager : MakingCoffeeContentsManager
        switch type {
        case .PourOver:
            manager = PourOverMakingCoffeeContentsManager()
        default:
            manager = MakingCoffeeContentsManager()
        }
        
        return manager
    }
    
    func contentsAll() -> [MakingCoffeeContent] {
        return []
    }
}

class PourOverMakingCoffeeContentsManager : MakingCoffeeContentsManager {
    override func contentsAll() -> [MakingCoffeeContent] {
        // TODO: サーバーと連携すれば、その都度変更できる
        return [
            MakingCoffeeContent(title: "Boil the water.", detail: "You don't need to wait for the water to cool after it comes to a boil, as many baristas believe. As long as it's not at a rolling boil, the water should cool down enough by the time you're pouring it so that it won't over-extract the beans and make a bitter cup.", imageName: "boil"),
            MakingCoffeeContent(title: "Measure and grind beans.", detail: "You want medium-fine grounds, like coarse sand. The rule is 1.75 grams of coffee per 1 ounce (28 grams) of water. For a 16-ounce cup, Ms. Meister uses 30 grams of whole beans to 500 grams of water (or 4 heaping tablespoons of coffee to 2¼ cups of water).", imageName: "grind"),
            MakingCoffeeContent(title: "Prepare the filter.", detail: "Fold so it fits snugly in the cone by creasing the bottom pleat in one direction, and the perforated side pleat in the other. Once it is in the cone, wet the filter gently, then add the grounds. Place the cone on a jar or mug large enough to hold at least 20 ounces.", imageName: "filter"),
            MakingCoffeeContent(title: "Bloom your beans.", detail: "Once the water boils, gently pour in just enough water to wet the grounds. Start your timer. The grounds will rise, or bloom, as they emit carbon dioxide—this helps them absorb water. Wait 35 seconds, or until coffee begins to drip from the cone, before pouring in more water.", imageName: "pour"),
            MakingCoffeeContent(title: "Brew the coffee.", detail: "Keeping an eye on the timer, slowly and evenly pour water over the grounds to reach 2 inches from the top of the filter. Once the water subsides by 1 inch, add more. Repeat until you've added all the water—ideally, within 4 minutes. When the dripping slows, the coffee is ready.", imageName: "brew")
        ]
    }
}

class MakingCoffeeContent : NSObject {
    override init(){
        super.init()
    }
    
    init(title: String, detail: String, imageName: String){
        self.title = title
        self.detail = detail
        self.imageName = imageName
    }
    
    var title = ""
    var detail = ""
    var imageName = ""
}