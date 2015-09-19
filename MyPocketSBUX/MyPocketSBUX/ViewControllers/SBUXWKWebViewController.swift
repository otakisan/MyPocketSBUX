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

    // Constants for Storyboard/ViewControllers
    struct StoryboardConstants {
        static let storyboardName = "Main"
        static let viewControllerIdentifier = "SBUXWKWebViewController"
    }

    //  デバイスのCGRectを取得
    var deviceBound : CGRect = UIScreen.mainScreen().bounds
    
    var relativePath = ""
    var webkitview : WKWebView = WKWebView()
    var activityIndicatorView : UIActivityIndicatorView?

    class func forRelativePath(relativePath: String) -> SBUXWKWebViewController {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardConstants.viewControllerIdentifier) as! SBUXWKWebViewController
        
        viewController.relativePath = relativePath
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeWebView()
    }
    
    func initializeWebView(){
        self.webkitview.frame = CGRectMake(0, 0/*60 上に余白が欲しいとき*/, deviceBound.size.width, deviceBound.size.height - 60)
        self.view.addSubview(self.webkitview)
        self.webkitview.navigationDelegate = self
        
        if let url = NSURL(string: self.fullPath()){
            self.showActivityIndicator()
            let req = NSURLRequest(URL:url)
            self.webkitview.loadRequest(req)
        }
    }
    
    func fullPath() -> String {
        
        let rootRelativePath = ((self.relativePath == "" || self.relativePath.substringToIndex(self.relativePath.startIndex.successor()) != "/") ? "/" : "") + self.relativePath
        return "http://www.starbucks.co.jp\(rootRelativePath)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showActivityIndicator() {
        
        if self.activityIndicatorView == nil {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
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
