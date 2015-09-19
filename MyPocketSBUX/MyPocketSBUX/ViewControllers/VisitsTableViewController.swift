//
//  VisitsTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class VisitsTableViewController: UITableViewController {

    var visits : [(order: Order, store: Store)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.fetchRecentOrders()
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
        return self.visits.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultVisitsTableViewCell", forIndexPath: indexPath) 

        // Configure the cell...
        cell.textLabel?.text = self.visits[indexPath.row].store.name
        cell.detailTextLabel?.text = "\(DateUtility.localDateString(self.visits[indexPath.row].order.createdAt)) \(DateUtility.localTimeString(self.visits[indexPath.row].order.createdAt))"

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
        if let vc = segue.destinationViewController as? OrderTableViewController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                // TODO: オーダー詳細のソート順は、ドリンク／フード別に分けたいのもあり、単純な名称の辞書順では済まない
                let order = self.visits[indexPath.row].order
//                let orderDetails = OrderDetails.getOrderDetailsWithOrderId(Int(order.id), orderKeys: [("id", true)])
                let orderDetails = order.orderDetails.allObjects as! [OrderDetail]
                let orderInfo = OrderManager.instance.loadOrder(order, orderDetails: orderDetails)
                vc.orderHeader = orderInfo.header
                vc.orderItems = orderInfo.details
            }
        }
    }
    
    func fetchRecentOrders() {
        
        // TODO: おそらくリレーションで、Storeも同時に取得することができるはず。
        let orders = OrderManager.instance.getAllOrderFromLocal()
        for order in orders {
            if let store = Stores.findByStoreId(Int(order.storeId)){
                self.visits += [(order, store)]
            }
        }
    }
}
