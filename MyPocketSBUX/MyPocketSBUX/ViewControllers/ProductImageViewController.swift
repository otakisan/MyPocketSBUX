//
//  ProductImageViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/10.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class ProductImageViewController: UIViewController {
    
    var imageName = ""

    @IBOutlet weak var productImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initializeImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeImage() {
        self.productImageView.image = UIImage(named: self.imageName)
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
