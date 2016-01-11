//
//  TastingLogsTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TastingLogsTableViewController: TastingLogsBaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, FilteredTastingLogsTableViewControllerDelegate {
    
    struct StoryboardConstants {
        static let storyboardName = "Main"
        static let viewControllerIdentifier = "TastingLogsTableViewController"
    }
    
    // Search controller to help us with filtering.
    var searchController: UISearchController!
    
    // Secondary search results table view.
    var filteredTastingLogsTableController: FilteredTastingLogsTableViewController!
    
    private var refreshing = false
    
    var myPocketId = ""
    
    class func forUser(myPocketId : String) -> TastingLogsTableViewController {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardConstants.viewControllerIdentifier) as! TastingLogsTableViewController
        
        viewController.myPocketId = myPocketId
        
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // TODO: 一旦、設定ない場合にはカレントユーザーを初期設定とする
        if self.myPocketId == "" {
            self.myPocketId = IdentityContext.sharedInstance.currentUserID
        }
        
        self.intializeSearchController()
        
        self.refreshDataAndReloadTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func intializeSearchController() {
        
        // サーチ後の結果
        self.filteredTastingLogsTableController = FilteredTastingLogsTableViewController()
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        self.filteredTastingLogsTableController.tableView.delegate = self.filteredTastingLogsTableController
        self.filteredTastingLogsTableController.tableView.dataSource = self.filteredTastingLogsTableController
        self.filteredTastingLogsTableController.delegate = self
        
        self.searchController = UISearchController(searchResultsController: self.filteredTastingLogsTableController)
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

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // Update the filtered array based on the search text.
        let searchResults = self.tastingLogs
        
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
            
            for prop in ["title", "tag", "detail"] {
                let lhs = NSExpression(forKeyPath: prop)
                let rhs = NSExpression(forConstantValue: searchString)
                
                let finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
                searchItemsPredicate.append(finalPredicate)
            }
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicates = NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
            andMatchPredicates.append(orMatchPredicates)
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluateWithObject($0) }
        
        // Hand over the filtered results to our search results table.
        let resultsController = searchController.searchResultsController as! FilteredTastingLogsTableViewController
        resultsController.tastingLogs = filteredResults
        resultsController.tableView.reloadData()
        
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let vc = segue.destinationViewController as? TastingLogEditorTableViewController {
            vc.delegate = self
            switch segue.identifier ?? "" {
                case "addTastingLogSegue":
                vc.tastingLog = TastingLogManager.instance.newTastingLog()
            case "editTastingLogSegue":
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    vc.tastingLog = self.tastingLogs[indexPath.row]
                }
            default:
                fatalError("tasting logs: invalid segue: \(segue.identifier)")
            }
        }
    }
    
    @IBAction func tastingLogEditorDidSave(segue : UIStoryboardSegue) {
        if let tastingLogEditorViewController = segue.sourceViewController as? TastingLogEditorTableViewController {
            self.showNavigationPrompt("Saved".localized(), message: "log id: \(tastingLogEditorViewController.tastingLog.id)", displayingTime: 500000)
            
            self.refreshDataAndReloadTableView()
        }
    }

    @IBAction func tastingLogEditorDidCancel(segue : UIStoryboardSegue) {
        if let tastingLogEditorViewController = segue.sourceViewController as? TastingLogEditorTableViewController {
        }
    }
    
    func refreshDataAndReloadTableView(){
                
        // TODO: オーダーをサーバーにアップするようになったら、オーダーも取得する
        ContentsManager.instance.fetchContents(["store"], variables: [:], orderKeys: [], completionHandler: { fetchResults in
            ContentsManager.instance.fetchContents(["tasting_log"], variables: ["myPocketId": self.myPocketId
                ], orderKeys: [(columnName : "tastingAt", ascending : false)], completionHandler: { fetchResults in
                self.tastingLogs = fetchResults.first?.entities as? [TastingLog] ?? []
                self.reloadData()
            })
        })
    }
    
    func refreshLocalDbAndReload(completionHandler: (Void -> Void)?) {
        ContentsManager.instance.refreshContents(["tasting_log"], variables: ["myPocketId": self.myPocketId
            ], orderKeys: [(columnName : "tastingAt", ascending : false)], completionHandler: { fetchResults in
            self.tastingLogs = fetchResults.first?.entities as? [TastingLog] ?? []
            self.reloadData({self.refreshing = false})
            self.dispatch_async_main({ () -> () in
                completionHandler?()
            })
        })
    }
    
    func showNavigationPrompt(title : String, message : String, displayingTime: useconds_t) {
        self.navigationItem.prompt = "\(title) : \(message)"
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            usleep(displayingTime)
            self.dispatch_async_main({
                self.navigationItem.prompt = nil
            })
        })
    }
    
    override func didSaveTastingLog(tastingLog: TastingLog) {
        self.showNavigationPrompt("Saved".localized(), message: "log id: \(tastingLog.id)", displayingTime: 500000)
        
        self.refreshDataAndReloadTableView()
    }
    
    override func didCancelTastingLog(tastingLog: TastingLog) {
        
    }
    
    func didSaveTastingLogViaFilteredList(tastingLog: TastingLog){
        self.refreshDataAndReloadTableView()
        self.updateSearchResultsForSearchController(self.searchController)
    }
    
    func didCancelTastingLogViaFilteredList(tastingLog: TastingLog){
        
    }
    
    func deleteActionViaFilteredList(tastingLog: TastingLog){
        TastingLogManager.instance.deleteTastingLog(tastingLog)
        self.refreshDataAndReloadTableView()
        self.updateSearchResultsForSearchController(self.searchController)
    }
    
    override func deleteAction(indexPath : NSIndexPath) {
        let removed = self.tastingLogs.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        TastingLogManager.instance.deleteTastingLog(removed)
    }
    
    override func refresh() {
        
        // TODO: 一覧のリロードが完了するまでブロックする必要がある
        if !self.refreshing {
            self.refreshing = true
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                // サーバーにアップしていないものをアップする
                TastingLogManager.instance.postJsonContentsToWebWithSyncRequest()
                
                // サーバーから最新版をフェッチする
                self.refreshLocalDbAndReload({
                    self.refreshControl?.endRefreshing()
//                    self.refreshing = false
                })
            })
        }
    }
    
    func refreshViaFilteredList() {
        if !self.refreshing {
            self.refreshing = true
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                // サーバーにアップしていないものをアップする
                TastingLogManager.instance.postJsonContentsToWebWithSyncRequest()
                
                // サーバーから最新版をフェッチする
                self.refreshLocalDbAndReload({
                    self.updateSearchResultsForSearchController(self.searchController)
                    
                    // TODO: 消すタイミングを親側で決めるのは、密結合だけど、暫定的にそうする
                    self.filteredTastingLogsTableController.refreshControl?.endRefreshing()
                    
//                    self.refreshing = false
                })
            })
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO: データの更新中に、非表示領域から復帰するセルの描画を空にすることでデータの不整合を防ぐ
        if self.refreshing {
            return tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) 
        }
        else{
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }

}
