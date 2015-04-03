//
//  SeminarsTableViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/03/31.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class SeminarsTableViewController: SeminarsBaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var seminarData : [[NSDictionary]]?
    var groupKeyToIndex : [String:Int] = [:]
    //var seminarEditions : [String:NSDictionary]?
    
    // Search controller to help us with filtering.
    var searchController: UISearchController!
    
    // Secondary search results table view.
    var filteredSeminarsTableController: FilteredSeminarsTableViewController!

    func initializeData(){
        
        // 性能改善するのであれば、ローカルにある分でまず表示
        // その後ウェブから取得した分を先頭に追加して表示する
        
        // 最新版を取得
        if let url  = NSURL(string: self.dataUrl()) {
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task    = session.dataTaskWithURL(url, completionHandler: {
                (data, resp, err) in
                if let dataArray = self.initializeDataArrayFromJson(data) {
                    self.seminarData = self.convertGroupedArray(dataArray)
                    self.reloadData()
                }
                //println(NSString(data: data, encoding:NSUTF8StringEncoding))
            })
            
            task.resume()
        }
    }
    
    func convertGroupedArray(dataArray : NSArray) -> [[NSDictionary]] {
        
        // グループごとに2次元配列で管理
        var results : [[NSDictionary]] = []
        
        if let dataArraySwift = dataArray as? [NSDictionary] {
            for dataObjNsDic in dataArraySwift {
                if let edition = dataObjNsDic["edition"] as? NSString {
                    if self.groupKeyToIndex[edition] == nil {
                        self.groupKeyToIndex[edition] = self.groupKeyToIndex.count
                    }
                    
                    if var appendIndex = self.groupKeyToIndex[edition] {
                        if results.count <= appendIndex {
                            results.append([])
                        }
                        
                        results[appendIndex].append(dataObjNsDic)
                    }
               }
            }
            
        }
        
        
        return results
    }
    
    func initializeDataArrayFromJson(dataJson: NSData) -> NSArray?{
        return NSJSONSerialization.JSONObjectWithData(dataJson, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray
    }
    
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    func reloadData(){
        dispatch_async_main{self.tableView.reloadData()}
    }
    
    func dataUrl() -> String {
        return "http://localhost:3000/seminars.json"
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        /*
        // Update the filtered array based on the search text.
        let searchResults = products
        
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
            
            // Name field matching.
            var lhs = NSExpression(forKeyPath: "title")
            var rhs = NSExpression(forConstantValue: searchString)
            
            var finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            
            searchItemsPredicate.append(finalPredicate)
            
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .NoStyle
            numberFormatter.formatterBehavior = .BehaviorDefault
            
            let targetNumber = numberFormatter.numberFromString(searchString)
            // `searchString` may fail to convert to a number.
            if targetNumber != nil {
                // `yearIntroduced` field matching.
                lhs = NSExpression(forKeyPath: "yearIntroduced")
                rhs = NSExpression(forConstantValue: targetNumber!)
                finalPredicate = NSComparisonPredicate( leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption)
                
                searchItemsPredicate.append(finalPredicate)
                
                // `price` field matching.
                lhs = NSExpression(forKeyPath: "introPrice")
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
        
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluateWithObject($0) }
        
        // Hand over the filtered results to our search results table.
        let resultsController = searchController.searchResultsController as ResultsTableController
        resultsController.filteredProducts = filteredResults
        resultsController.tableView.reloadData()
*/
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // サーチ後の結果
        self.filteredSeminarsTableController = FilteredSeminarsTableViewController()
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        self.filteredSeminarsTableController.tableView.delegate = self
        
        self.searchController = UISearchController(searchResultsController: self.filteredSeminarsTableController)
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

        
        self.initializeData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.seminarData?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.seminarData?[section].count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        if let tableData = self.seminarData {
            self.configureCell(cell, forSeminars: tableData, indexPath: indexPath)
            
            // エディションでセクション分けする
//            let objDic = tableData[indexPath.section][indexPath.row]
//            let storeName = (objDic["store"] as NSDictionary)["name"] as NSString
//            let capacity = objDic["capacity"] as Int
//            let status = objDic["status"] as String
//            let start_time = objDic["start_time"] as String
//            
//            if let startDateTime = DateUtility.dateFromSqliteDateString(start_time) {
//                let startDate = DateUtility.localDateString(startDateTime)
//                let startTime = DateUtility.localTimeString(startDateTime)
//                let capacityLabel = "capacity".localized()
//                let statusLabel = "status".localized()
//                let statusValue = (self.statusMappings[status] == nil ? "" : self.statusMappings[status]!).localized()
//                cell.detailTextLabel?.text = "\(startDate) \(startTime)  \(capacityLabel):\(capacity)  \(statusLabel):\(statusValue)"
//            }
//            cell.textLabel?.text = "\(storeName)"
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var label = UILabel()
        label.text = self.seminarData?[section].first?["edition"] as NSString
        label.sizeToFit()
        label.backgroundColor = UIColor.grayColor()
        
        return label
    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
