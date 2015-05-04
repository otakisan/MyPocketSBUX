//
//  MakingCoffeePageViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class MakingCoffeePageViewController: UIPageViewController/*, UIPageViewControllerDataSource*/ {
    
    var contentType : MakingCoffeeContentType = .None
    var contentDataSource : MakingCoffeePageViewControllerDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.intialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func intialize() {
        self.navigationItem.title = self.contentType.name()
        
        self.contentDataSource = MakingCoffeePageViewControllerDataSource(contentType: self.contentType, storyBoard: self.storyboard!)
        self.dataSource = self.contentDataSource
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.grayColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.blackColor()
        UIPageControl.appearance().backgroundColor = UIColor.whiteColor()
        
        // 開始ビューの設定が必須
        var startingViewController = self.contentDataSource.viewControllerAtIndex(0)!
        self.setViewControllers([startingViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        // Change the size of page view controller
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
        
        self.didMoveToParentViewController(self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return self.contentDataSource.presentationCountForPageViewController(pageViewController)
//    }
//
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        // 開始位置らしい
//        return self.contentDataSource.presentationIndexForPageViewController(pageViewController)
//    }
//    
//    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
//        return self.contentDataSource.pageViewController(pageViewController, viewControllerBeforeViewController: viewController)
//    }
//    
//    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
//        return self.contentDataSource.pageViewController(pageViewController, viewControllerAfterViewController: viewController)
//    }

}

enum MakingCoffeeContentType {
    case None
    case PourOver
    case FrenchPress
    case Espresso
    case VIA
    case Origami
    
    func name() -> String {
        var name = ""
        switch self {
        case PourOver:
            name = "Pour Over"
        case FrenchPress:
            name = "French Press"
        case Espresso:
            name = "Espresso"
        case VIA:
            name = "VIA®"
        case Origami:
            name = "Origami®"
        default:
            name = "None"
        }
        
        return name
    }
}

class MakingCoffeePageViewControllerDataSource : NSObject, UIPageViewControllerDataSource {
    
    var pageContents : [MakingCoffeeContent] = []
    var contentType : MakingCoffeeContentType
    var contentManager : MakingCoffeeContentsManager
    var storyBoard : UIStoryboard
    
    init(contentType : MakingCoffeeContentType, storyBoard: UIStoryboard){
        self.storyBoard = storyBoard
        self.contentType = contentType
        self.contentManager = MakingCoffeeContentsManager.contentsManager(self.contentType)
        self.pageContents = self.contentManager.contentsAll()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
        var index = (viewController as! MakingCoffeePageContentViewController).pageIndex
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil;
        }
        
        index--
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MakingCoffeePageContentViewController).pageIndex
        
        if (index == NSNotFound) {
            return nil
        }
        
        index++
        if (index == self.pageContents.count) {
            return nil
        }
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageContents.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        // 開始位置らしい
        return 0
    }
    
    var contentViews : [Int:MakingCoffeePageContentViewController] = [:]
    func viewControllerAtIndex(index: Int) -> MakingCoffeePageContentViewController? {
        if self.pageContents.count == 0 || index >= self.pageContents.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        // Auto Layoutのタイミングが遅く、かくつくので保持する
        var vc = self.contentViews[index]
        if vc == nil {
            var pageContentViewController = self.storyBoard.instantiateViewControllerWithIdentifier("MakingCoffeePageContentViewController") as! MakingCoffeePageContentViewController
            pageContentViewController.imageName = self.pageContents[index].imageName
            pageContentViewController.titleText = self.pageContents[index].title
            pageContentViewController.detailText = self.pageContents[index].detail
            pageContentViewController.pageIndex = index
            self.contentViews[index] = pageContentViewController
            vc = pageContentViewController
        }
        
        return vc
    }
}