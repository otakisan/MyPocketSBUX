//
//  SBUXWKWebViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/03/28.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import WebKit

class SBUXWKWebViewController: UIViewController, WKNavigationDelegate {

    //  デバイスのCGRectを取得
    var deviceBound : CGRect = UIScreen.mainScreen().bounds
    
    var relativePath = ""
    var webkitview : WKWebView = WKWebView()
    var activityIndicatorView : UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeWebView()
    }
    
    func initializeWebView(){
        self.webkitview.frame = CGRectMake(0, 0/*60 上に余白が欲しいとき*/, deviceBound.size.width, deviceBound.size.height - 60)
        self.view.addSubview(self.webkitview)
        self.webkitview.navigationDelegate = self
        
        if var url = NSURL(string:"http://www.starbucks.co.jp/\(self.relativePath)"){
            self.showActivityIndicator()
            var req = NSURLRequest(URL:url)
            self.webkitview.loadRequest(req)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showActivityIndicator() {
        
        if self.activityIndicatorView == nil {
            var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.hidesWhenStopped = true
//            var indicatorSize = activityIndicator.frame.size
//            var viewSize = self.view.frame.size
//            var left = (viewSize.width - indicatorSize.width) / 2
//            var top = (viewSize.height - indicatorSize.height) / 2
//            activityIndicator.frame = CGRectMake(left, top, indicatorSize.width, indicatorSize.height)
            activityIndicator.center = self.view.center
            self.view.addSubview(activityIndicator)
            
            self.activityIndicatorView = activityIndicator
        }
        
        self.activityIndicatorView?.startAnimating()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!){
        self.activityIndicatorView?.stopAnimating()
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
