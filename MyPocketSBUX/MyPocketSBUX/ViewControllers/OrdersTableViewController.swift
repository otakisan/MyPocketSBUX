//
//  OrdersTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/29.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrdersTableViewController: UITableViewController {
    
    var orders : [(order : Order, orderDetails : [OrderDetail])] = []
    var delegate: OrdersTableViewControllerDelegate?
    var handler: OrdersTableViewControllerHandler = MasterDetailOrdersTableViewControllerHandler()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.fetchRecentOrders()
        
        self.handler.ordersTableViewDidLoad(self)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultOrdersTableViewCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        let dateString = DateUtility.localDateString(self.orders[indexPath.row].order.createdAt)
        let timeString = DateUtility.localTimeString(self.orders[indexPath.row].order.createdAt)
        cell.textLabel?.text = "\(dateString) \(timeString) ¥\(self.orders[indexPath.row].order.taxExcludedTotalPrice) (¥\(self.orders[indexPath.row].order.taxIncludedTotalPrice)) (\(self.orders[indexPath.row].order.storeId))"
        cell.detailTextLabel?.text = self.orders[indexPath.row].orderDetails.reduce("", combine: {$0 + ($0 != "" ? ", " : "") + $1.productName})

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.handler.didSelectRow(self, indexPath: indexPath)
        //self.performSegueWithIdentifier("showOrderSegue", sender: self)
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
        if var vc = segue.destinationViewController as? OrderTableViewController {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let orderInfo = OrderManager.instance.loadOrder(self.orders[indexPath.row].order, orderDetails: self.orders[indexPath.row].orderDetails)
                vc.orderHeader = orderInfo.header
                vc.orderItems = orderInfo.details
            }
        }
    }
    
    
    func fetchRecentOrders() {
        let orders = OrderManager.instance.getAllOrderFromLocal()
        for order in orders {
            var orderDetails = OrderDetails.getOrderDetailsWithOrderId(Int(order.id), orderKeys: [])
            self.orders += [(order, orderDetails)]
        }
        
    }

}

protocol OrdersTableViewControllerDelegate {
    func didSelectOrder(order: Order)
}

class OrdersTableViewControllerHandler: NSObject {
    func ordersTableViewDidLoad(viewController: OrdersTableViewController) {
        
    }
    
    func didSelectRow(viewController: OrdersTableViewController, indexPath: NSIndexPath) {
    }
}

class SelectItemOrdersTableViewControllerHandler: OrdersTableViewControllerHandler {
    override func didSelectRow(viewController: OrdersTableViewController, indexPath: NSIndexPath) {
        viewController.delegate?.didSelectOrder(viewController.orders[indexPath.row].order)
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func ordersTableViewDidLoad(viewController: OrdersTableViewController) {
        self.addCancelButton(viewController)
    }
    
    func addCancelButton(viewController: OrdersTableViewController){
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "didRuntimeCancelButton:")
        cancelTarget = viewController
    }
    
    var cancelTarget: UIViewController?
    func didRuntimeCancelButton(sender: UIBarButtonItem){
        cancelTarget?.dismissViewControllerAnimated(true, completion: {})
    }
}

class MasterDetailOrdersTableViewControllerHandler: OrdersTableViewControllerHandler {
    override func didSelectRow(viewController: OrdersTableViewController, indexPath: NSIndexPath) {
        viewController.performSegueWithIdentifier("showOrderSegue", sender: nil)
    }
}
