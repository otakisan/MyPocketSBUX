//
//  CommentsOnTastingLogContainerViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/13.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class CommentsOnTastingLogContainerViewController: UIViewController, SendCommentOnTastingLogViewDelegate, CommentsOnTastingLogTableViewDelegate {

    var tastingLogId : Int = 0
    var delegate : CommentsOnTastingLogContainerViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addCancelButtonIfNeeded()
        
        self.navigationItem.title = "Comments"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addCancelButtonIfNeeded(){
        if let rootVc = self.navigationController?.viewControllers.first where rootVc == self {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "didRuntimeCancelButton:")
        }
    }
    
    func didRuntimeCancelButton(sender: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: {})
    }

    func didSendComment(comment: String) {
        
        if let commentsTable = self.childViewControllers.filter( { (vc) -> Bool in
            return vc is CommentsOnTastingLogTableViewController
        }).first as? CommentsOnTastingLogTableViewController {
            commentsTable.loadObjects()
            self.delegate?.didSendComment(comment)
        }
    }
    
    func idOfTastingLog() -> Int {
        return self.tastingLogId
    }
    
    func didDeleteComment(comment : String){
        self.delegate?.didDeleteComment(comment)
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

protocol CommentsOnTastingLogContainerViewDelegate {
    func didSendComment(comment : String)
    func didDeleteComment(comment : String)
}