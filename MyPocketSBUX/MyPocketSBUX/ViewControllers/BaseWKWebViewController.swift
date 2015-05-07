//
//  BaseWKWebViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import WebKit

class BaseWKWebViewController: UIViewController, WKNavigationDelegate {

    var deviceBound : CGRect = UIScreen.mainScreen().bounds
    
    var baseURL = ""
    var relativePath = ""
    var absoluteURL = ""
    
    var webkitview : WKWebView = WKWebView()
    var activityIndicatorView : UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeWebView()
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
    
    func urlString() -> String {
        return self.absoluteURL == "" ? "http://\(self.baseURL)/\(self.relativePath)" : self.absoluteURL
    }
    
    func initializeWebView(){
        self.webkitview.frame = CGRectMake(0, 0/*60 上に余白が欲しいとき*/, deviceBound.size.width, deviceBound.size.height - 60)
        self.view.addSubview(self.webkitview)
        self.webkitview.navigationDelegate = self
        
        if var url = NSURL(string:self.urlString()){
            self.showActivityIndicator()
            var req = NSURLRequest(URL:url)
            self.webkitview.loadRequest(req)
        }
    }
    
    func showActivityIndicator() {
        
        if self.activityIndicatorView == nil {
            var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.center = self.view.center
            self.view.addSubview(activityIndicator)
            
            self.activityIndicatorView = activityIndicator
        }
        
        self.activityIndicatorView?.startAnimating()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!){
        self.activityIndicatorView?.stopAnimating()
    }

}
