//
//  SendCommentOnTastingLogViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/13.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class SendCommentOnTastingLogViewController: UIViewController, UITextFieldDelegate {

    var delegate : SendCommentOnTastingLogViewDelegate?
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBAction func touchUpInsideSendButton(sender: UIButton) {
        self.sendComment()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.commentTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        self.delegate = parent as? SendCommentOnTastingLogViewDelegate
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        self.sendComment()
        
        return true
    }
    
    func sendComment() {
        if let tastingLogId = self.delegate?.idOfTastingLog(), let comment = self.commentTextField.text {
            ParseUtility.instance.commentOnTastingLogInBackgroundWithBlock(tastingLogId, comment: comment, block: { (isSuccess, error) -> Void in
                print("succeeded to send comment. \(comment)")
                self.delegate?.didSendComment(comment)
            })
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

protocol SendCommentOnTastingLogViewDelegate {
    func didSendComment(comment : String)
    func idOfTastingLog() -> Int
}