//
//  TextViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    
    var delegate: TextViewControllerDelegate?

    @IBOutlet weak var textView: UITextView!
    @IBAction func touchUpInsideOkButton(sender: UIButton) {
        self.delegate?.didOkTextView(self.textView.text)
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func touchUpInsideCancelButton(sender: UIButton) {
        self.delegate?.didCancelTextView(self.textView.text)
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

protocol TextViewControllerDelegate {
    func didOkTextView(text: String)
    func didCancelTextView(text: String)
}