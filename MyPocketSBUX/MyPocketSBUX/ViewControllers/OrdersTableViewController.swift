//
//  OrdersTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/29.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrdersTableViewController: OrdersBaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, FilteredOrdersTableViewControllerDelegate {
    
    // Search controller to help us with filtering.
    var searchController: UISearchController!
    
    // Secondary search results table view.
    var filteredOrdersTableController: FilteredOrdersTableViewController!
    
    private var refreshing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.intializeSearchController()
        
        self.refreshDataAndReloadTableView()
    }

    func intializeSearchController() {
        
        // サーチ後の結果
        self.filteredOrdersTableController = FilteredOrdersTableViewController()
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        self.filteredOrdersTableController.tableView.delegate = self.filteredOrdersTableController
        self.filteredOrdersTableController.tableView.dataSource = self.filteredOrdersTableController
        self.filteredOrdersTableController.delegateForParent = self
        self.filteredOrdersTableController.handler = self.handler
        self.filteredOrdersTableController.navigationControllerOfOriginalViewController = self.navigationController
        
        self.searchController = UISearchController(searchResultsController: self.filteredOrdersTableController)
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
        let searchResults = self.orders
        
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
            
            for prop in ["notes"] {
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
        let resultsController = searchController.searchResultsController as! FilteredOrdersTableViewController
        resultsController.orders = filteredResults
        resultsController.tableView.reloadData()
        
    }
    
    func deleteActionViaFilteredList(order: Order){
        OrderManager.instance.deleteOrder(order)
        self.refreshDataAndReloadTableView()
        self.updateSearchResultsForSearchController(self.searchController)
    }

    func refreshDataAndReloadTableView(){
        
        // TODO: オーダーをサーバーにアップするようになったら、オーダーも取得する
        ContentsManager.instance.fetchContents(["store"], orderKeys: [], completionHandler: { fetchResults in
            ContentsManager.instance.fetchContents(["order"], orderKeys: [(columnName : "updatedAt", ascending : false)], completionHandler: { fetchResults in
                self.orders = fetchResults.first?.entities as? [Order] ?? []
                self.reloadData()
            })
        })
    }
    
    func refreshLocalDbAndReload(completionHandler: (Void -> Void)?) {
        ContentsManager.instance.refreshContents(["order"], orderKeys: [(columnName : "updatedAt", ascending : false)], completionHandler: { fetchResults in
            self.orders = fetchResults.first?.entities as? [Order] ?? []
            self.reloadData({self.refreshing = false})
            completionHandler?()
        })
    }

    func refreshViaFilteredList() {
        if !self.refreshing {
            self.refreshing = true
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                // サーバーにアップしていないものをアップする
                OrderManager.instance.postJsonContentsToWebWithSyncRequest()
                
                // サーバーから最新版をフェッチする
                self.refreshLocalDbAndReload({
                    self.updateSearchResultsForSearchController(self.searchController)
                    
                    // TODO: 消すタイミングを親側で決めるのは、密結合だけど、暫定的にそうする
                    self.filteredOrdersTableController.refreshControl?.endRefreshing()
                    
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

    override func refresh() {
        
        // TODO: 一覧のリロードが完了するまでブロックする必要がある
        if !self.refreshing {
            self.refreshing = true
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                // サーバーにアップしていないものをアップする
                OrderManager.instance.postJsonContentsToWebWithSyncRequest()
                
                // サーバーから最新版をフェッチする
                self.refreshLocalDbAndReload({
                    self.refreshControl?.endRefreshing()
                    //                    self.refreshing = false
                })
            })
        }
    }
    
    override func deleteAction(indexPath : NSIndexPath) {
        OrderManager.instance.deleteOrder(self.orders[indexPath.row])
        self.orders.removeAtIndex(indexPath.row)
        self.reloadData(nil)
    }
    
    override func navigationControllerForOrder() -> UINavigationController? {
        return self.navigationController
    }
}
