//
//  StoresTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class StoresTableViewController: StoresBaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    struct RestorationKeys {
        static let viewControllerTitle = "ViewControllerTitleKey"
        static let searchControllerIsActive = "SearchControllerIsActiveKey"
        static let searchBarText = "SearchBarTextKey"
        static let searchBarIsFirstResponder = "SearchBarIsFirstResponderKey"
    }
    
    // State restoration values.
    struct SearchControllerRestorableState {
        var wasActive = false
        var wasFirstResponder = false
    }
    
    let distanceSegments = [
        (name : "All", distance : 0),
        (name : "1km", distance : 1),
        (name : "2km", distance : 2),
        (name : "5km", distance : 5),
        (name : "10km", distance : 10)
    ]
    var distanceSegment : UISegmentedControl!

    var storeEntities : [Store] = []
    var storesData : [[String:AnyObject]]?
    var storeAnnotations : [(coordinate : (latitude : Double, longitude : Double), title : String, subStitle : String, store : Store?)] = []

    // Search controller to help us with filtering.
    var searchController: UISearchController!
    
    // Secondary search results table view.
    var filteredStoresTableController: FilteredStoresTableViewController!
    
    var restoredState = SearchControllerRestorableState()
    var activityIndicatorView : UIActivityIndicatorView?
    
    var needToAddCancelButton = false
    
    func showActivityIndicator() {
        
        if self.activityIndicatorView == nil {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.center = self.view.center
            self.tableView.addSubview(activityIndicator)
            
            self.activityIndicatorView = activityIndicator
        }
        
        self.activityIndicatorView?.startAnimating()
    }
    
    func stopActivityIndicator() {
        self.dispatch_async_main {
            self.activityIndicatorView?.stopAnimating()
            return
        }
    }

    func initializeStoreData(){

        self.showActivityIndicator()
        
        StoreManager.instance.updateStoreLocalDb({
            // ローカルDBのキャッシュデータを取得
            self.storeEntities = self.getAllStoreFromLocal()
            self.dispatch_async_serial { self.refreshAnnotations() }
            self.storesData = self.convertGroupedArray(self.storeEntities)
            
            self.stopActivityIndicator()
            self.reloadData()
        })
    }

    func getAllStoreFromLocal() -> [Store] {
        return Stores.getAllOrderBy("allStoresFetchRequest", orderKeys: [(columnName : "prefId", ascending : true),(columnName : "name", ascending : true)])
    }
    
    func convertGroupedArray(entities : [Store]) -> [[String:AnyObject]] {
        
        // グループが配下に項目を管理
        var results : [[String:AnyObject]] = []
        var groupKeyToIndex : [Int:Int] = [:]
        
        for entity in entities {
            
            let prefId = Int(entity.prefId)
        
            if groupKeyToIndex[prefId] == nil {
                groupKeyToIndex[prefId] = groupKeyToIndex.count
            }
            
            if let appendIndex = groupKeyToIndex[prefId] {
                if results.count <= appendIndex {
                    results.append([String:AnyObject]())
                }
                
                if results[appendIndex]["prefId"] == nil {
                    results[appendIndex]["prefId"] = prefId
                    results[appendIndex]["prefName"] = entity.address.prefecture()
                }
                
                if results[appendIndex]["stores"] == nil {
                    results[appendIndex]["stores"] = [Store]()
                }
                
                if var stores = results[appendIndex]["stores"] as? [Store] {
                    stores.append(entity)
                    results[appendIndex]["stores"] = stores
                }
            }
        }
        
        return results
    }
    
    func createHeaderTableView() {
        
        // ___________
        // サーチバー
        
        // サーチ後の結果
        self.filteredStoresTableController = FilteredStoresTableViewController()
        self.filteredStoresTableController.selectBySwipe = self.selectBySwipe
        self.filteredStoresTableController.delegate = self.delegate
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        self.filteredStoresTableController.tableView.delegate = self.filteredStoresTableController
        self.filteredStoresTableController.tableView.dataSource = self.filteredStoresTableController
        self.filteredStoresTableController.navigationControllerOfOriginalViewController = self.navigationController
        
        self.searchController = UISearchController(searchResultsController: self.filteredStoresTableController)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.sizeToFit()
        //self.tableView.tableHeaderView = searchController.searchBar
        
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false // default is YES
        self.searchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        // _______________
        // セグメントフィルタ
        let paddingHeight = CGFloat(5.0)
        
        self.distanceSegment = UISegmentedControl(items: self.distanceSegments.map{$0.name})
        self.distanceSegment.frame = CGRectMake((searchController.searchBar.frame.width - self.distanceSegment.frame.width) / 2.0, searchController.searchBar.frame.height + paddingHeight, self.distanceSegment.frame.width, self.distanceSegment.frame.height)
        self.distanceSegment.selectedSegmentIndex = 0
        self.distanceSegment.addTarget(self, action: "valueChangedDistanceSegment:", forControlEvents: .ValueChanged)
        
        // _______________
        // 親ビュー
        let superView = UIView(frame: CGRectMake(0, 0, searchController.searchBar.frame.width, searchController.searchBar.frame.height + self.distanceSegment.frame.height + paddingHeight * 2))
        superView.addSubview(searchController.searchBar)
        superView.addSubview(self.distanceSegment)
        superView.backgroundColor = UIColor.whiteColor()
        
        self.tableView.tableHeaderView = superView
        
        // AutoLayoutによる制御が必要
        // サーチバーが結果ビューのほうにつけ変わることに対応しないとアベンドするため対応が必要
        // 将来的に対応することとする
//        var layoutRight = NSLayoutConstraint(item: searchController.searchBar, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
//        var layoutLeft = NSLayoutConstraint(item: searchController.searchBar, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
//        searchController.searchBar.setTranslatesAutoresizingMaskIntoConstraints(false)
//        superView.addConstraints([layoutRight, layoutLeft])
        
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        self.definesPresentationContext = true
        
        self.addCancelButtonIfNeeded()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // Update the filtered array based on the search text.
        let searchResults = self.storesData
        
        // サーチバーに入力されたテキストをトリム後に単語単位に分割
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
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
            
            // 都道府県（本当は都道府県文字列でフィルタする必要がある）
//            var lhs = NSExpression(forKeyPath: "prefId")
//            var rhs = NSExpression(forConstantValue: searchString.toInt() ?? 0)
//            
//            var finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption)
//            searchItemsPredicate.append(finalPredicate)
            
            // 店舗名
            var lhs = NSExpression(forKeyPath: "name")
            var rhs = NSExpression(forConstantValue: searchString)
            
            var finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            searchItemsPredicate.append(finalPredicate)
            // 住所
            lhs = NSExpression(forKeyPath: "address")
            rhs = NSExpression(forConstantValue: searchString)
            
            finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            searchItemsPredicate.append(finalPredicate)
            // 数値項目の場合は下記を参考にする
            //            let numberFormatter = NSNumberFormatter()
            //            numberFormatter.numberStyle = .NoStyle
            //            numberFormatter.formatterBehavior = .BehaviorDefault
            //
            //            let targetNumber = numberFormatter.numberFromString(searchString)
            //            // `searchString` may fail to convert to a number.
            //            if targetNumber != nil {
            //                // `yearIntroduced` field matching.
            //                lhs = NSExpression(forKeyPath: "yearIntroduced")
            //                rhs = NSExpression(forConstantValue: targetNumber!)
            //                finalPredicate = NSComparisonPredicate( leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            //
            //                searchItemsPredicate.append(finalPredicate)
            //
            //                // `price` field matching.
            //                lhs = NSExpression(forKeyPath: "introPrice")
            //                rhs = NSExpression(forConstantValue: targetNumber!)
            //                finalPredicate = NSComparisonPredicate( leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            //
            //                searchItemsPredicate.append(finalPredicate)
            //            }
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicates = NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
            andMatchPredicates.append(orMatchPredicates)
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        // キーワードに合致するものを取得
        var filteredResults = searchResults?.map { (groupDic : [String:AnyObject]) -> [String:AnyObject] in
            var newData : [String:AnyObject] = groupDic
            if let stores = groupDic["stores"] as? [Store] {
                newData["stores"] = stores.filter {finalCompoundPredicate.evaluateWithObject($0)}
            }
            return newData
        }
        // 項目のないグループは取り除く
        filteredResults = filteredResults?.filter { ($0["stores"] as? [Store])?.count > 0 }
        
        // Hand over the filtered results to our search results table.
        let resultsController = searchController.searchResultsController as! FilteredStoresTableViewController
        resultsController.filteredStoreData = filteredResults
        resultsController.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: UIStateRestoration
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
        // Encode the view state so it can be restored later.
        
        // Encode the title.
        coder.encodeObject(navigationItem.title!, forKey:RestorationKeys.viewControllerTitle)
        
        // Encode the search controller's active state.
        coder.encodeBool(searchController.active, forKey:RestorationKeys.searchControllerIsActive)
        
        // Encode the first responser status.
        coder.encodeBool(searchController.searchBar.isFirstResponder(), forKey:RestorationKeys.searchBarIsFirstResponder)
        
        // Encode the search bar text.
        coder.encodeObject(searchController.searchBar.text, forKey:RestorationKeys.searchBarText)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
        // Restore the title.
        if let decodedTitle = coder.decodeObjectForKey(RestorationKeys.viewControllerTitle) as? String {
            title = decodedTitle
        }
        else {
            fatalError("A title did not exist. In your app, handle this gracefully.")
        }
        
        // Restore the active state:
        // We can't make the searchController active here since it's not part of the view
        // hierarchy yet, instead we do it in viewWillAppear.
        //
        restoredState.wasActive = coder.decodeBoolForKey(RestorationKeys.searchControllerIsActive)
        
        // Restore the first responder status:
        // Like above, we can't make the searchController first responder here since it's not part of the view
        // hierarchy yet, instead we do it in viewWillAppear.
        //
        restoredState.wasFirstResponder = coder.decodeBoolForKey(RestorationKeys.searchBarIsFirstResponder)
        
        // Restore the text in the search field.
        searchController.searchBar.text = coder.decodeObjectForKey(RestorationKeys.searchBarText) as? String
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.active = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        createHeaderTableView()
        
        initializeStoreData()
        
        // 初期化
        _ = LocationContext.current.coordinate
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // TODO: 本来はAutoLayoutで行うべき？
        if storesData != nil {
            self.searchController.searchBar.sizeToFit()
            let paddingHeight = CGFloat(5.0)
            self.distanceSegment.frame = CGRectMake((searchController.searchBar.frame.width - self.distanceSegment.frame.width) / 2.0, searchController.searchBar.frame.height + paddingHeight, self.distanceSegment.frame.width, self.distanceSegment.frame.height)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.storesData?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return (self.storesData?[section]["stores"] as! [Store]).count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) 

        self.configureCell(cell, forStores: self.storesData, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
//        return String(self.storesData?[section]["prefId"] as? Int ?? 0)
        return self.storesData?[section]["prefName"] as? String ?? ""
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let stores = self.storesData?[indexPath.section]["stores"] as? [Store] {
            
            if stores.count > indexPath.row {
                self.pushStoreDetailViewOnCellSelected(self.navigationController!, store: stores[indexPath.row])
            }
        }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let storeMapViewController = segue.destinationViewController as? StoreMapViewController {
            // 位置情報サービスから現在地を取得
            storeMapViewController.centerCoordinate = LocationContext.current.coordinate ?? storeMapViewController.centerCoordinate
            storeMapViewController.annotations = self.storeAnnotations + [(coordinate : (latitude : storeMapViewController.centerCoordinate.latitude, longitude : storeMapViewController.centerCoordinate.longitude), title : "現在地", subStitle : "", store : nil)]
        }
    }
    
    func allStoreAnnotationsAndCurrent() -> [(coordinate : (latitude : Double, longitude : Double), title : String, subStitle : String, store : Store?)] {
        var results : [(coordinate : (latitude : Double, longitude : Double), title : String, subStitle : String, store : Store?)] = []
        for entity in self.storeEntities {
            let annotationInfo : (coordinate : (latitude : Double, longitude : Double), title : String, subStitle : String, store : Store?) =
            (coordinate: (Double(entity.latitude), Double(entity.longitude)), title: entity.name, subStitle: "\(DateUtility.localTimeString(entity.openingTimeWeekday)) - \(DateUtility.localTimeString(entity.closingTimeWeekday))", store : entity)
            
            results += [annotationInfo]
        }
        
        return results
    }
    
    func refreshAnnotations() {
        self.storeAnnotations = self.allStoreAnnotationsAndCurrent()
    }

    override func storeAtIndexPath(indexPath : NSIndexPath) -> Store? {
        var store : Store? = nil
        if let stores = self.storesData?[indexPath.section]["stores"] as? [Store] {
            
            if stores.count > indexPath.row {
                store = stores[indexPath.row]
            }
        }
        
        return store
    }
    
    override func closeView(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func addCancelButtonIfNeeded(){
        if let rootVc = self.navigationController?.viewControllers.first {
            if self.needToAddCancelButton && rootVc == self {
                
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "didRuntimeCancelButton:")
            }
        }
    }
    
    func didRuntimeCancelButton(sender: UIBarButtonItem){
        self.searchController.active = false
        self.dismissViewControllerAnimated(true, completion: {})
    }

    func didDismissSearchController(searchController: UISearchController){
        // サーチコントローラー表示後に画面の向きが変わっている場合への対応
        self.view.setNeedsLayout()
    }
    
    func valueChangedDistanceSegment(distanceSegment : UISegmentedControl) {
        print("segindex : \(distanceSegment.selectedSegmentIndex) name : \(self.distanceSegments[distanceSegment.selectedSegmentIndex].name) distance : \(self.distanceSegments[distanceSegment.selectedSegmentIndex].distance)")
        
        self.distanceSegment.enabled = false
        if self.distanceSegments[distanceSegment.selectedSegmentIndex].name == "All" {
            self.storesData = self.convertGroupedArray(self.storeEntities)
            self.enableDistanceSegmentAfterReloadData()
        } else {
            // メートルに変換
            let distanceMeter = Double(self.distanceSegments[distanceSegment.selectedSegmentIndex].distance) * 1000.0
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.center = self.view.center
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()

            let hasHereInfo = StoreManager.instance.storesFromHereWithin(distanceMeter, stores: self.storeEntities) { (storesFiltered, error) -> Void in

                let grouped = self.convertGroupedArray(storesFiltered)
                self.dispatch_async_main({ () -> () in
                    activityIndicator.stopAnimating()
                    self.storesData = grouped
                    self.enableDistanceSegmentAfterReloadData()
                })
            }
            
            if !hasHereInfo {
                activityIndicator.stopAnimating()
                
                let alertController = UIAlertController(title: "Unable to get your current location.", message: "Please turn on location services", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                self.distanceSegment.enabled = true
            }
        }
    }
    
    private func enableDistanceSegmentAfterReloadData() {
        self.reloadData()
        self.dispatch_async_main { () -> () in
            self.distanceSegment.enabled = true
        }
    }
}

protocol StoresTableViewDelegate {
    func selectAndClose(store : Store)
}
