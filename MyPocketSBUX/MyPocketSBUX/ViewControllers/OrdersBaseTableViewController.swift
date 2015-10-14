//
//  OrdersBaseTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/31.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrdersBaseTableViewController: UITableViewController {

    struct Constants {
        struct Nib {
            static let name = "OrdersTableViewCell"
        }
        
        struct TableViewCell {
            static let identifier = "ordersTableViewCellIdentifier"
        }
    }
    
//    var orders : [(order : Order, orderDetails : [OrderDetail])] = []
    var orders : [Order] = []
    var delegate: OrdersTableViewControllerDelegate?
    var handler: OrdersTableViewControllerHandler = MasterDetailOrdersTableViewControllerHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // TODO: ひとまず標準のTableViewCellを使う
        let nib = UINib(nibName: Constants.Nib.name, bundle: nil)
        
        // Required if our subclasses are to use: dequeueReusableCellWithIdentifier:forIndexPath:
        tableView.registerNib(nib, forCellReuseIdentifier: Constants.TableViewCell.identifier)
        
        self.intializeRefreshControl()
        
        self.fetchRecentOrders()
        
        self.handler.ordersTableViewDidLoad(self)
    }
    
    func intializeRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh() {
        if !IdentityContext.sharedInstance.signedIn() {
            self.refreshControl?.endRefreshing()
            return
        }
        
        self.refreshImpl()
    }
    
    func refreshImpl() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.orders.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) 
        
        // Configure the cell...
//        let dateString = DateUtility.localDateString(self.orders[indexPath.row].order.createdAt)
//        let timeString = DateUtility.localTimeString(self.orders[indexPath.row].order.createdAt)
//        cell.textLabel?.text = "\(dateString) \(timeString) ¥\(self.orders[indexPath.row].order.taxExcludedTotalPrice) (¥\(self.orders[indexPath.row].order.taxIncludedTotalPrice)) (\(self.orders[indexPath.row].order.storeId))"
        let dateString = DateUtility.localDateString(self.orders[indexPath.row].createdAt)
        let timeString = DateUtility.localTimeString(self.orders[indexPath.row].createdAt)
        cell.textLabel?.text = "\(dateString) \(timeString) ¥\(self.orders[indexPath.row].taxExcludedTotalPrice) (¥\(self.orders[indexPath.row].taxIncludedTotalPrice)) (\(self.orders[indexPath.row].storeId))"
        //        cell.detailTextLabel?.text = self.orders[indexPath.row].orderDetails.reduce("", combine: {$0 + ($0 != "" ? ", " : "") + $1.productName})
//        cell.detailTextLabel?.text = (self.orders[indexPath.row].order.orderDetails.allObjects as? [OrderDetail])?.reduce("", combine: {$0! + ($0 != "" ? ", " : "") + $1.productName}) ?? ""
        cell.detailTextLabel?.text = (self.orders[indexPath.row].orderDetails.allObjects as? [OrderDetail])?.reduce("", combine: {$0! + ($0 != "" ? ", " : "") + $1.productName}) ?? ""
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.handler.didSelectRow(self, indexPath: indexPath)
        //self.performSegueWithIdentifier("showOrderSegue", sender: self)
    }
    
    // スワイプで編集メニューの表示を有効にする
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.handler.canEditRowAtIndexPath(self, indexPath: indexPath)
    }
    
    // スワイプのため、空の実装が必要
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.handler.commitEditingStyleForRowAtIndexPath(self, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    
    // スワイプ時に表示する項目
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return self.handler.editActionsForRowAtIndexPath(self, indexPath: indexPath)
    }
    
    
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
        if let vc = segue.destinationViewController as? OrderTableViewController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                //                let orderInfo = OrderManager.instance.loadOrder(self.orders[indexPath.row].order, orderDetails: self.orders[indexPath.row].orderDetails)
//                let orderInfo = OrderManager.instance.loadOrder(self.orders[indexPath.row].order, orderDetails: self.orders[indexPath.row].order.orderDetails.allObjects as! [OrderDetail])
//                vc.orderHeader = orderInfo.header
//                vc.orderItems = orderInfo.details
                let order = self.orders[indexPath.row]
                let orderInfo = OrderManager.instance.loadOrder(order, orderDetails: order.orderDetails.allObjects as! [OrderDetail])
                vc.orderHeader = orderInfo.header
                vc.orderItems = orderInfo.details
            }
        }
    }
    
    
    func fetchRecentOrders() {
//        let orders = OrderManager.instance.getAllOrderFromLocal()
//        for order in orders {
//            //            var orderDetails = OrderDetails.getOrderDetailsWithOrderId(Int(order.id), orderKeys: [])
//            //            self.orders += [(order, orderDetails)]
//            self.orders += [(order, order.orderDetails.allObjects as! [OrderDetail])]
//        }
        self.orders = OrderManager.instance.getAllOrderFromLocal()
    }
    
    func deleteAction(indexPath : NSIndexPath) {
    }
    
    func navigationControllerForOrder() -> UINavigationController? {
        return nil
    }
}

protocol OrdersTableViewControllerDelegate {
    func didSelectOrder(order: Order)
}

class OrdersTableViewControllerHandler: NSObject {
    func ordersTableViewDidLoad(viewController: OrdersBaseTableViewController) {
    }
    
    func didSelectRow(viewController: OrdersBaseTableViewController, indexPath: NSIndexPath) {
    }
    
    func canEditRowAtIndexPath(viewController: OrdersBaseTableViewController, indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func commitEditingStyleForRowAtIndexPath(viewController: OrdersBaseTableViewController, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func editActionsForRowAtIndexPath(viewController: OrdersBaseTableViewController, indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return nil
    }
}

class SelectItemOrdersTableViewControllerHandler: OrdersTableViewControllerHandler {
    override func didSelectRow(viewController: OrdersBaseTableViewController, indexPath: NSIndexPath) {
//        viewController.delegate?.didSelectOrder(viewController.orders[indexPath.row].order)
        viewController.delegate?.didSelectOrder(viewController.orders[indexPath.row])
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func ordersTableViewDidLoad(viewController: OrdersBaseTableViewController) {
        self.addCancelButton(viewController)
    }
    
    func addCancelButton(viewController: OrdersBaseTableViewController){
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "didRuntimeCancelButton:")
        cancelTarget = viewController
    }
    
    var cancelTarget: UIViewController?
    func didRuntimeCancelButton(sender: UIBarButtonItem){
        cancelTarget?.dismissViewControllerAnimated(true, completion: {})
    }
}

class MasterDetailOrdersTableViewControllerHandler: OrdersTableViewControllerHandler {
    var viewController: OrdersBaseTableViewController?
    
    override func didSelectRow(viewController: OrdersBaseTableViewController, indexPath: NSIndexPath) {
        //viewController.performSegueWithIdentifier("showOrderSegue", sender: nil)
        pushTastingLogDetailViewOnCellSelected(viewController, order: viewController.orders[indexPath.row])
    }
    
    override func canEditRowAtIndexPath(viewController: OrdersBaseTableViewController, indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func editActionsForRowAtIndexPath(viewController: OrdersBaseTableViewController, indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "delete") {
            (action, indexPath) in viewController.deleteAction(indexPath)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction]
    }
    
    func pushTastingLogDetailViewOnCellSelected(viewController: OrdersBaseTableViewController, order : Order) {
        
        if let nv = viewController.navigationControllerForOrder() {
            // Set up the detail view controller to show.
            let detailViewController = OrderTableViewController.forOrder(order)
            //detailViewController.delegate = self
            
            // Note: Should not be necessary but current iOS 8.0 bug requires it.
            viewController.tableView.deselectRowAtIndexPath(viewController.tableView.indexPathForSelectedRow!, animated: false)
            
            //viewController.presentViewController(detailViewController, animated: true, completion: nil)
            nv.pushViewController(detailViewController, animated: true)
        }
    }
}
