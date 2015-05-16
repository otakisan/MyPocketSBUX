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
    
    private let _progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
    private let _closeBtn = UIButton.buttonWithType(.Custom) as! UIButton
    private let _goBackBtn = UIButton.buttonWithType(.Custom) as! UIButton
    private let _goForwardBtn = UIButton.buttonWithType(.Custom) as! UIButton
    private let _reloadBtn = UIButton.buttonWithType(.Custom) as! UIButton
    
    private let _baseMenuView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.initializeWebView()
        self.setupView()
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
        return (self.absoluteURL == "" ? "http://\(self.baseURL)/\(self.relativePath)" : self.absoluteURL).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
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
    
//    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!){
//        self.activityIndicatorView?.stopAnimating()
//    }

    private func setupView(){
        self.webkitview.frame = CGRectMake(0, 0/*60 上に余白が欲しいとき*/, deviceBound.size.width, deviceBound.size.height - 60)

        // progressView
        _baseMenuView.addSubview(_progressView)
        
        webkitview.navigationDelegate = self
        webkitview.allowsBackForwardNavigationGestures = true
        webkitview.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: nil)  // WEBページの読込状況取得のため、Observerに追加
        self.view.addSubview(webkitview)
        if let url = NSURL(string: self.urlString()){
            webkitview.loadRequest(NSURLRequest(URL: url))
        }
        
        _baseMenuView.backgroundColor = UIColor(red:0.9,green:0.9,blue:1.0,alpha:1.0)
        self.view.addSubview(_baseMenuView)
        
        // closeBtn
        _closeBtn.setTitle("✖️", forState: .Normal)
        _closeBtn.setImage(UIImage(named: "Close"), forState: .Normal)
        _closeBtn.addTarget(self, action: "pressBtn:", forControlEvents: .TouchUpInside)
        _baseMenuView.addSubview(_closeBtn)
        
        // goBackBtn
        _goBackBtn.setTitle("⬅️", forState: .Normal)
        _goBackBtn.enabled = false
        webkitview.addObserver(self, forKeyPath: "canGoBack", options: NSKeyValueObservingOptions.New, context: nil) // WEBページで戻ることができるか監視のため、Observerに追加
        _goBackBtn.setImage(UIImage(named: "GoBack"), forState: .Normal)
        _goBackBtn.addTarget(self, action: "pressBtn:", forControlEvents: .TouchUpInside)
        _baseMenuView.addSubview(_goBackBtn)
        
        // goForwardBtn
        _goForwardBtn.setTitle("➡️", forState: .Normal)
        _goForwardBtn.enabled = false
        webkitview.addObserver(self, forKeyPath: "canGoForward", options: NSKeyValueObservingOptions.New, context: nil) // WEBページで進むことができるか監視のため、Observerに追加
        _goForwardBtn.setImage(UIImage(named: "GoForward"), forState: .Normal)
        _goForwardBtn.addTarget(self, action: "pressBtn:", forControlEvents: .TouchUpInside)
        _baseMenuView.addSubview(_goForwardBtn)
        
        // reloadBtn
        _reloadBtn.setTitle("🔄", forState: .Normal)
        _reloadBtn.setImage(UIImage(named: "Reload"), forState: .Normal)
        _reloadBtn.addTarget(self, action: "pressBtn:", forControlEvents: .TouchUpInside)
        _baseMenuView.addSubview(_reloadBtn)
        
        setupConstraints()
    }
    
    // Observerで監視対象のプロパティに変更があったときの処理
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if object.isEqual(webkitview){
            if keyPath == "estimatedProgress"{
                _progressView.progress = Float(webkitview.estimatedProgress)
            }else if keyPath == "canGoBack"{
                _goBackBtn.enabled = webkitview.canGoBack
            }else if keyPath == "canGoForward"{
                _goForwardBtn.enabled = webkitview.canGoForward
            }
        }
    }
    
    func setupConstraints(){
        var viewConstraints = [NSLayoutConstraint]()
        
        // baseMenu
        var baseMenuViewConstraints = [NSLayoutConstraint]()
        _baseMenuView.setTranslatesAutoresizingMaskIntoConstraints(false)
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _baseMenuView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50.0))
        viewConstraints.append(NSLayoutConstraint(item: _baseMenuView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: _baseMenuView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: _baseMenuView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -50.0/*タブバー分上げる*/))
        
        // progressView
        _progressView.setTranslatesAutoresizingMaskIntoConstraints(false)
        var progressViewConstraints = [NSLayoutConstraint]()
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _progressView, attribute: .Left, relatedBy: .Equal, toItem: _baseMenuView, attribute: .Left, multiplier: 1.0, constant: 0.0))
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _progressView, attribute: .Right, relatedBy: .Equal, toItem: _baseMenuView, attribute: .Right, multiplier: 1.0, constant: 0.0))
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _progressView, attribute: .Top, relatedBy: .Equal, toItem: _baseMenuView, attribute: .Top, multiplier: 1.0, constant: 0.0))
        
        // closeBtn
        _closeBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        var closeBtnConstraints = [NSLayoutConstraint]()
        closeBtnConstraints.append(NSLayoutConstraint(item: _closeBtn, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
        closeBtnConstraints.append(NSLayoutConstraint(item: _closeBtn, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 24.0))
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _closeBtn, attribute: .CenterY, relatedBy: .Equal, toItem: _baseMenuView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _closeBtn, attribute: .Left, relatedBy: .Equal, toItem: _baseMenuView, attribute: .Left, multiplier: 1.0, constant: 10.0))
        
        // reloadBtn
        _reloadBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        var reloadBtnConstraints = [NSLayoutConstraint]()
        reloadBtnConstraints.append(NSLayoutConstraint(item: _reloadBtn, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
        reloadBtnConstraints.append(NSLayoutConstraint(item: _reloadBtn, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 24.0))
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _reloadBtn, attribute: .CenterY, relatedBy: .Equal, toItem: _baseMenuView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _reloadBtn, attribute: .Left, relatedBy: .Equal, toItem: _closeBtn, attribute: .Right, multiplier: 1.0, constant: 20.0))
        
        // goBackBtn
        _goBackBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        var goBackBtnConstraints = [NSLayoutConstraint]()
        goBackBtnConstraints.append(NSLayoutConstraint(item: _goBackBtn, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
        goBackBtnConstraints.append(NSLayoutConstraint(item: _goBackBtn, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 24.0))
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _goBackBtn, attribute: .CenterY, relatedBy: .Equal, toItem: _baseMenuView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _goBackBtn, attribute: .Left, relatedBy: .Equal, toItem: _reloadBtn, attribute: .Right, multiplier: 1.0, constant: 20.0))
        
        // goForwardBtn
        _goForwardBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        var goForwardBtnConstraints = [NSLayoutConstraint]()
        goForwardBtnConstraints.append(NSLayoutConstraint(item: _goForwardBtn, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
        goForwardBtnConstraints.append(NSLayoutConstraint(item: _goForwardBtn, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 24.0))
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _goForwardBtn, attribute: .CenterY, relatedBy: .Equal, toItem: _baseMenuView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        baseMenuViewConstraints.append(NSLayoutConstraint(item: _goForwardBtn, attribute: .Left, relatedBy: .Equal, toItem: _goBackBtn, attribute: .Right, multiplier: 1.0, constant: 20.0))
        
        // webView
        webkitview.setTranslatesAutoresizingMaskIntoConstraints(false)
        var webViewConstraints = [NSLayoutConstraint]()
        viewConstraints.append(NSLayoutConstraint(item: webkitview, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: webkitview, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: webkitview, attribute: .Bottom, relatedBy: .Equal, toItem: _baseMenuView, attribute: .Top, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: webkitview, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0.0))
        
        _closeBtn.addConstraints(closeBtnConstraints)
        _reloadBtn.addConstraints(reloadBtnConstraints)
        _goBackBtn.addConstraints(goBackBtnConstraints)
        _goForwardBtn.addConstraints(goForwardBtnConstraints)
        _baseMenuView.addConstraints(baseMenuViewConstraints)
        self.view.addConstraints(viewConstraints)
        
    }
    
    // 画面を閉じるときにObserverを削除。削除しないとアプリ落ちる
    deinit{
        webkitview.removeObserver(self, forKeyPath: "estimatedProgress", context: nil)
        webkitview.removeObserver(self, forKeyPath: "canGoBack", context: nil)
        webkitview.removeObserver(self, forKeyPath: "canGoForward", context: nil)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self._progressView.progress = 0.0
        }
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        NSLog("\(error.localizedDescription)")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self._progressView.progress = 0.0
        }
    }
    
    // ボタンを押したときの処理
    func pressBtn(sender:UIButton){
        if sender.isEqual(_closeBtn){
            if self.navigationController != nil {
                self.navigationController?.popViewControllerAnimated(true)
            }else{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }else if sender.isEqual(_goBackBtn){
            webkitview.goBack()
        }else if sender.isEqual(_goForwardBtn){
            webkitview.goForward()
        }else if sender.isEqual(_reloadBtn){
            webkitview.reload()
        }
    }

}
