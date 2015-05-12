//
//  NewsTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/03/25.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class NewsTableViewController: NewsBaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // Search controller to help us with filtering.
    var searchController: UISearchController!
    
    // Secondary search results table view.
    var filteredNewsTableController: FilteredNewsTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.initializeSearchController()
        
        self.initializeNewsData()
    }
    
    func initializeSearchController(){
        // サーチ後の結果
        self.filteredNewsTableController = FilteredNewsTableViewController()
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        self.filteredNewsTableController.tableView.delegate = self.filteredNewsTableController
        self.filteredNewsTableController.tableView.dataSource = self.filteredNewsTableController
        self.filteredNewsTableController.navigationControllerOfOriginalViewController = self.navigationController
        
        self.searchController = UISearchController(searchResultsController: self.filteredNewsTableController)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false // default is YES
        self.searchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        self.definesPresentationContext = true
        
    }
    
    func getAllPressReleaseFromLocal() -> [PressRelease] {
        return PressReleases.getAllOrderBy([(columnName : "issueDate", ascending : false), (columnName : "pressReleaseSn", ascending : false)])
    }
    
    func insertNewPressReleaseToLocal(newPressReleaseData : NSArray) -> [PressRelease] {
        
        var results : [PressRelease] = []
        
        for newPressRelease in newPressReleaseData {
            var entity = PressReleases.createEntity()
            entity.fiscalYear = (newPressRelease["fiscal_year"] as? NSNumber) ?? 0
            entity.pressReleaseSn = (newPressRelease["press_release_sn"] as? NSNumber) ?? 0
            entity.title = ((newPressRelease["title"] as? NSString) ?? "") as String
            entity.url = ((newPressRelease["url"] as? NSString) ?? "") as String
            entity.issueDate = DateUtility.dateFromSqliteDateString(newPressRelease["issue_date"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.createdAt = DateUtility.dateFromSqliteDateTimeString(newPressRelease["created_at"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = DateUtility.dateFromSqliteDateTimeString(newPressRelease["updated_at"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            
            PressReleases.insertEntity(entity)
            results.append(entity)
        }
        
        return results
    }
    
    func initializeNewsData(){
        
        // ローカルDBのキャッシュデータを取得
        self.pressReleaseEntities = self.getAllPressReleaseFromLocal()
        
        // トップ１件のSNを取得（ゼロ件ヒットの場合はゼロにする）
        let maxSn = self.pressReleaseEntities.count > 0 ? self.pressReleaseEntities.first!.pressReleaseSn : 0
        
        // 性能改善するのであれば、ローカルにある分でまず表示
        // その後ウェブから取得した分を先頭に追加して表示する
        
        // 最新版を取得
        let nextSn = Int(maxSn) + 1
        if let url  = NSURL(string: "http://\(ResourceContext.instance.serviceHost()):3000/press_releases.json/?type=range&key=press_release_sn&from=\(nextSn)") {
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task    = session.dataTaskWithURL(url, completionHandler: {
                (data, resp, err) in
                if var newsData = self.initializeNewsArrayFromJson(data) {
                    var newPressReleaseData  : [PressRelease] = self.insertNewPressReleaseToLocal(newsData)
                    newPressReleaseData.extend(self.pressReleaseEntities)
                    self.pressReleaseEntities = newPressReleaseData
                }
                self.reloadData()
                //println(NSString(data: data, encoding:NSUTF8StringEncoding))
            })
        
            task.resume()
        }
    }
    
    func initializeNewsArrayFromJson(newsJson: NSData) -> NSArray?{
        return NSJSONSerialization.JSONObjectWithData(newsJson, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using [segue destinationViewController].
//        // Pass the selected object to the new view controller.
//    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // Update the filtered array based on the search text.
        let searchResults = self.pressReleaseEntities
        
        // サーチバーに入力されたテキストをトリム後に単語単位に分割
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        let searchItems = strippedString.componentsSeparatedByString(" ") as [String]
        
        // Build all the "AND" expressions for each value in the searchString.
        var andMatchPredicates = [NSPredicate]()
        
        for searchString in searchItems {
            // Each searchString creates an OR predicate for: name, yearIntroduced, introPrice.
            //
            // Example if searchItems contains "iphone 599 2007":
            //      name CONTAINS[c] "iphone"
            //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
            //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
            //
            var searchItemsPredicate = [NSPredicate]()
            
            // Below we use NSExpression represent expressions in our predicates.
            // NSPredicate is mmiade up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value).
            
            // 通常のオブジェクトの場合は下記
            // Name field matching.
            // タイトル
            var lhs = NSExpression(forKeyPath: "title")
            var rhs = NSExpression(forConstantValue: searchString)
            
            var finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            searchItemsPredicate.append(finalPredicate)
            
            // 数値項目の場合は下記を参考にする
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .NoStyle
            numberFormatter.formatterBehavior = .BehaviorDefault

            let targetNumber = numberFormatter.numberFromString(searchString)
            // `searchString` may fail to convert to a number.
            if targetNumber != nil {
                // `yearIntroduced` field matching.
                lhs = NSExpression(forKeyPath: "fiscalYear")
                rhs = NSExpression(forConstantValue: targetNumber!)
                finalPredicate = NSComparisonPredicate( leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption)

                searchItemsPredicate.append(finalPredicate)
            }
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicates = NSCompoundPredicate.orPredicateWithSubpredicates(searchItemsPredicate)
            andMatchPredicates.append(orMatchPredicates)
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate.andPredicateWithSubpredicates(andMatchPredicates)
        
        // サーチバーのキーワードでフィルタ
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluateWithObject($0) }
        
        // Hand over the filtered results to our search results table.
        let resultsController = searchController.searchResultsController as! FilteredNewsTableViewController
        resultsController.pressReleaseEntities = filteredResults
        resultsController.tableView.reloadData()
        
    }

}
