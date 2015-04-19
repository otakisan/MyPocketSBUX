//
//  OrderTableViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/13.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrderTableViewController: UITableViewController, OrderTableViewCellDelegate {
    
//    var orderItems : [(productCategory : String, orders : [OrderListItem])] = []
    var orderItems : [OrderListItem] = []

    func getReuseCellIdentifier(orderListItem : OrderListItem) -> String {
        var identifier = ""
        
        if orderListItem.productEntity is Drink {
            identifier = "drinkOrderListItemCell"
        }
        else if orderListItem.productEntity is Food {
            identifier = "foodOrderListItemCell"
        }
        else{
            fatalError("unknown product type")
        }
        
        return identifier
    }
    
    func getSegueIdentifier(orderListItem : OrderListItem) -> String {
        var identifier = ""
        
        if orderListItem.productEntity is Drink {
            identifier = "customizingDrinkOrderSegue"
        }
        else if orderListItem.productEntity is Food {
            identifier = "customizingFoodOrderSegue"
        }
        else{
            fatalError("unknown product type")
        }
        
        return identifier
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//        self.tableView.estimatedRowHeight = 90
//        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        //return self.orderItems.count
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
//        return self.orderItems[section].1.count
        return self.orderItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // ドリンク or フードで、取り出すセルのタイプを分ける
        let cell = tableView.dequeueReusableCellWithIdentifier(self.getReuseCellIdentifier(self.orderItems[indexPath.row]), forIndexPath: indexPath) as! OrderTableViewCell

        // Configure the cell...
        
        cell.configure(self.orderItems[indexPath.row])
        cell.delegate = self

        return cell
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
        if var customizingOrderViewController = segue.destinationViewController as? CustomizingOrderTableViewController {
            customizingOrderViewController.orderItem = self.editRequestedOrderItem
        }
    }
    
    func valueChangedOrderSwitch(cell : OrderTableViewCell, on : Bool) {
        
    }
    
    var editRequestedOrderItem : OrderListItem?
    func touchUpInsideOrderEdit(cell : OrderTableViewCell) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            editRequestedOrderItem = self.orderItems[indexPath.row]
            self.performSegueWithIdentifier(self.getSegueIdentifier(self.editRequestedOrderItem!), sender: self)
        }
    }

}
