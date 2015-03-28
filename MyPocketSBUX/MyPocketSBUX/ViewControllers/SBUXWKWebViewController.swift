//
//  SBUXWKWebViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/03/28.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import WebKit

class SBUXWKWebViewController: UIViewController {

    var relativePath = ""
    var webkitview : WKWebView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeWebView()
    }
    
    func initializeWebView(){
        self.view = self.webkitview
        
        if var url = NSURL(string:"http://www.starbucks.co.jp/\(self.relativePath)"){
            var req = NSURLRequest(URL:url)
            self.webkitview.loadRequest(req)
        }
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
