//
//  NewsTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/03/25.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class NewsTableViewController: NewsBaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating/*UITableViewController, UIGestureRecognizerDelegate*/ {
    
//    var pressReleaseEntities : [PressRelease] = []
//    var fontSize : Float = 17.0
//    let fontSizeMax : Float = 24.0
//    var officialSiteRelativePath = ""

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
        
        //self.configTableHeaderView()
        //self.addPinchGestureRecognizer();
        
        self.initializeSearchController()
        
        self.initializeNewsData()
        
//        tableView.estimatedRowHeight = 90
//        self.tableView.rowHeight = UITableViewAutomaticDimension // カスタムセルの場合は明示的な指定が必要
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
    
//    func addPinchGestureRecognizer(){
//        // ピンチジェスチャをビューに登録
//        var pinch = UIPinchGestureRecognizer(target:self, action:"pinchGesture:")
//        pinch.delegate = self;
//        self.tableView.addGestureRecognizer(pinch)
//    }
//    
//    func pinchGesture(gesture : UIPinchGestureRecognizer) {
//        //println(gesture.scale)
//        
//        // scaleは加速度にもよるが、0〜4くらいが多い。最大でも14程度
//        self.fontSize = Float(gesture.scale) * 14
//        self.reloadData()
//    }
    
//    func configTableHeaderView(){
//        var fontSlider = UISlider()
//        fontSlider.value = fontSize / fontSizeMax
//        fontSlider.addTarget(self, action: "onChangeValueMySlider:", forControlEvents: UIControlEvents.ValueChanged)
//        self.tableView.tableHeaderView = fontSlider
//    }
//    
//    func onChangeValueMySlider(sender : UISlider){
//        self.fontSize = sender.value * fontSizeMax
//        self.reloadData()
//    }
    
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

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        // 年度ごとに分けてデータを保持するようになったら、年度の数だけセクションを分けるようにする
//        return 1
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return self.pressReleaseEntities.count
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("defaultNewsTableViewCellIdentifier", forIndexPath: indexPath) as! NewsTableViewCell
//        
//        self.configure(cell, indexPath: indexPath)
//
//        // Configure the cell...
////        if self.pressReleaseEntities.count > indexPath.row {
////            cell.titleLabel.text = self.pressReleaseEntities[indexPath.row].title
////            cell.titleLabel.numberOfLines = 0 // 複数行表示
////            cell.titleLabel.font = UIFont(name: "Arial", size: CGFloat(self.fontSize))
////            cell.titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
////            cell.issueDateLabel.text = DateUtility.localDateString(self.pressReleaseEntities[indexPath.row].issueDate)
////            cell.sizeToFit()
////        }
//
//        return cell
//    }
//
//    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath)-> NSIndexPath? {
//        if self.pressReleaseEntities.count > indexPath.row {
//            self.officialSiteRelativePath = (self.pressReleaseEntities[indexPath.row].url) ?? ""
//        }
//        return indexPath
//    }

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
//        if var officialWebViewController = segue.destinationViewController as? SBUXWKWebViewController {
//            officialWebViewController.relativePath = self.officialSiteRelativePath
//        }
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
            //            var lhs = NSExpression(forKeyPath: "title")
            //            var rhs = NSExpression(forConstantValue: searchString)
            //
            //            var finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            
            // 今回はNSDictionaryのなかに、さらにNSDictionary
            //var predicate = NSPredicate(format: "%K == %@", "edition", searchString)
            
            // タイトル
            var lhs = NSExpression(forKeyPath: "title")
            var rhs = NSExpression(forConstantValue: searchString)
            
            var finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            searchItemsPredicate.append(finalPredicate)
            
            // 店舗名
//            lhs = NSExpression(forKeyPath: "store.name")
//            rhs = NSExpression(forConstantValue: searchString)
//            
//            finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
//            searchItemsPredicate.append(finalPredicate)
            
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
            
            //
            //                // `price` field matching.
            //                lhs = NSExpression(forKeyPath: "introPrice")
            //                rhs = NSExpression(forConstantValue: targetNumber!)
            //                finalPredicate = NSComparisonPredicate( leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            //
            //                searchItemsPredicate.append(finalPredicate)
            }
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicates = NSCompoundPredicate.orPredicateWithSubpredicates(searchItemsPredicate)
            andMatchPredicates.append(orMatchPredicates)
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate.andPredicateWithSubpredicates(andMatchPredicates)
        
        // 一次元配列
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluateWithObject($0) }
        
        // 二次元配列の場合
        //for searchResult in
//        let filteredResults = searchResults.map { $0.filter { finalCompoundPredicate.evaluateWithObject($0) }}
        
        // Hand over the filtered results to our search results table.
        let resultsController = searchController.searchResultsController as! FilteredNewsTableViewController
        resultsController.pressReleaseEntities = filteredResults
        resultsController.tableView.reloadData()
        
    }

}
