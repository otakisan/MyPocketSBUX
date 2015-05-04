//
//  MakingCoffeePageContentViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class MakingCoffeePageContentViewController: UIViewController {
    
    var pageIndex : Int = 0
    var titleText = ""
    var detailText = ""
    var imageName = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.titleText
        self.detailLabel.text = self.detailText
        self.contentImageView.image = UIImage(named: self.imageName)
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
