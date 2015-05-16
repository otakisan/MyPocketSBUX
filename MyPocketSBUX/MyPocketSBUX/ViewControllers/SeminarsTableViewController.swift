//
//  SeminarsTableViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/03/31.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class SeminarsTableViewController: SeminarsBaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // Search controller to help us with filtering.
    var searchController: UISearchController!
    
    // Secondary search results table view.
    var filteredSeminarsTableController: FilteredSeminarsTableViewController!
    
    func intialize() {
        
        ContentsManager.instance.fetchContents(["seminar"], orderKeys: [(columnName : "edition", ascending : true)], completionHandler: { fetchResults in
            self.seminars = self.categorized(fetchResults.first?.entities as? [Seminar] ?? [])
            self.reloadData()
        })
    }
    
    func intializeRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh() {
        ContentsManager.instance.refreshContents(["seminar"], orderKeys: [(columnName : "edition", ascending : true)], completionHandler: { fetchResults in
            self.seminars = self.categorized(fetchResults.first?.entities as? [Seminar] ?? [])
            self.reloadData()
            
            // ここで戻すようにしないと、セルの再表示時に不正なデータにアクセスしてしまう
            self.refreshControl?.endRefreshing()
        })
    }
    
    func categorized(seminars: [Seminar]) -> [[Seminar]] {
        var prevEdition = ""
        var categorized:[[Seminar]] = []
        for seminar in seminars {
            if prevEdition != seminar.edition {
                categorized.append([])
                prevEdition = seminar.edition
            }
            
            categorized[categorized.endIndex - 1] += [seminar]
        }
        
        return categorized
    }
    
    func initializeDataArrayFromJson(dataJson: NSData) -> NSArray?{
        return NSJSONSerialization.JSONObjectWithData(dataJson, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // Update the filtered array based on the search text.
        let searchResults = self.seminars
        
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
            
            // エディション
            var lhs = NSExpression(forKeyPath: "edition")
            var rhs = NSExpression(forConstantValue: searchString)
            
            var finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            searchItemsPredicate.append(finalPredicate)
            
            // 店舗名
            lhs = NSExpression(forKeyPath: "store.name")
            rhs = NSExpression(forConstantValue: searchString)
            
            finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            searchItemsPredicate.append(finalPredicate)
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicates = NSCompoundPredicate.orPredicateWithSubpredicates(searchItemsPredicate)
            andMatchPredicates.append(orMatchPredicates)
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate.andPredicateWithSubpredicates(andMatchPredicates)
        
        let filteredResults = searchResults.map { $0.filter { finalCompoundPredicate.evaluateWithObject($0) }}
        
        // Hand over the filtered results to our search results table.
        let resultsController = searchController.searchResultsController as! FilteredSeminarsTableViewController
        resultsController.seminars = filteredResults
        resultsController.tableView.reloadData()

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
        self.filteredSeminarsTableController.tableView.delegate = self.filteredSeminarsTableController
        self.filteredSeminarsTableController.tableView.dataSource = self.filteredSeminarsTableController
        self.filteredSeminarsTableController.navigationControllerOfOriginalViewController = self.navigationController
        
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
        
        self.intializeRefreshControl()
        
        self.intialize()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
