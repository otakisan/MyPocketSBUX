//
//  TastingLogImageViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TastingLogImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var tastingLogScrollView: UIScrollView!
    @IBOutlet weak var tastingLogImageView: UIImageView!
    
    var tastingLogId = 0
    var imageData : NSData?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initialize() {
        self.tastingLogScrollView.delegate = self
        self.tastingLogScrollView.minimumZoomScale = 1
        self.tastingLogScrollView.maximumZoomScale = 8
        self.tastingLogScrollView.scrollEnabled = true
        self.tastingLogScrollView.showsHorizontalScrollIndicator = true
        self.tastingLogScrollView.showsVerticalScrollIndicator = true
        
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"doubleTap:")
        doubleTapGesture.numberOfTapsRequired = 2
        self.tastingLogImageView.userInteractionEnabled = true
        self.tastingLogImageView.addGestureRecognizer(doubleTapGesture)
        
        self.addCancelButtonIfNeeded()
        self.refreshImage()
    }
    
    // ピンチイン・ピンチアウト
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.tastingLogImageView
    }
    
    // ダブルタップ
    func doubleTap(gesture: UITapGestureRecognizer) -> Void {
        
        print(self.tastingLogScrollView.zoomScale)
        if ( self.tastingLogScrollView.zoomScale < self.tastingLogScrollView.maximumZoomScale ) {
            
            let newScale:CGFloat = self.tastingLogScrollView.zoomScale * 3
            let zoomRect:CGRect = self.zoomRectForScale(newScale, center: gesture.locationInView(gesture.view))
            self.tastingLogScrollView.zoomToRect(zoomRect, animated: true)
            
        } else {
            self.tastingLogScrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    // 領域
    func zoomRectForScale(scale:CGFloat, center: CGPoint) -> CGRect{
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.tastingLogScrollView.frame.size.height / scale
        zoomRect.size.width = self.tastingLogScrollView.frame.size.width / scale
        
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        
        return zoomRect
    }
    
    func refreshImage() {
        if let image = self.imageData {
            self.tastingLogImageView.image = UIImage(data: image)
        } else if self.tastingLogId > 0 {
            TastingLogManager.instance.fetchFullSizeImage(self.tastingLogId) { (isSuccess, imageData) -> Void in
                if isSuccess, let image = imageData {
                    self.tastingLogImageView.image = UIImage(data: image)
                }
            }
        }
    }

    func addCancelButtonIfNeeded(){
        if let rootVc = self.navigationController?.viewControllers.first {
            if rootVc == self {
                
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "didRuntimeCancelButton:")
            }
        }
    }
    
    func didRuntimeCancelButton(sender: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: {})
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
