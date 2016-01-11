//
//  ActivitySwipeBetweenViewControllers.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/21.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class ActivitySwipeBetweenViewControllers: SwipeBetweenViewControllers, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.viewControllerArray = [
            storyboard.instantiateViewControllerWithIdentifier("FollowingActivityTableViewController"),
            storyboard.instantiateViewControllerWithIdentifier("ToYouActivityTableViewController")
        ]
        
        self.buttonText = ["Following".localized(), "You".localized()]
                
        // TODO: 画面を消すための操作として何を提供するのが適切か
        // 暫定的に、スクリーンエッジのスワイプとするが、下記だとナビゲーションバーのところでないと効かない
        let screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self,  action: "edgePanGesture:")
        screenEdgeRecognizer.edges = .Left
        self.view.addGestureRecognizer(screenEdgeRecognizer)
        
        self.navigationItem.title = "Activity".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Ended {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
