//
//  OrderTableViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/13.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrderTableViewController: UITableViewController, OrderTableViewCellDelegate, CustomizingOrderTableViewDelegate, StoresTableViewDelegate {
    
    let headerSection = 0
    let productSection = 1
    
//    var orderItems : [(productCategory : String, orders : [OrderListItem])] = []
    var orderHeader : OrderHeader = OrderHeader()
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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
//        return self.orderItems[section].1.count
        return section == 0 ? 2 : self.orderItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : OrderTableViewCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(indexPath.row == 0 ? "storeOrderListItemCell" : "notesOrderListItemCell", forIndexPath: indexPath) as! OrderTableViewCell
            cell.configure(OrderListItem())
        }
        else {
            // ドリンク or フードで、取り出すセルのタイプを分ける
            cell = tableView.dequeueReusableCellWithIdentifier(self.getReuseCellIdentifier(self.orderItems[indexPath.row]), forIndexPath: indexPath) as! OrderTableViewCell
            
            // Configure the cell...
            
            cell.configure(self.orderItems[indexPath.row])
            cell.delegate = self
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? " " : "Products"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? CGFloat(44) : CGFloat(100)
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
        else if var orderConfirmationViewController = segue.destinationViewController as? OrderConfirmationTableViewController {
            orderConfirmationViewController.orderListItem = [(category: ProductCategory.Drink, orders: self.orderItems.filter({$0.on}))]
        }
        else if var storesVc = segue.destinationViewController as? StoresTableViewController {
            storesVc.selectBySwipe = true
            storesVc.delegate = self
        }
    }
    
    func valueChangedOrderSwitch(cell : OrderTableViewCell, on : Bool) {
        if var order = cell.orderListItem {
            order.on = on
        }
    }
    
    var editRequestedOrderItem : OrderListItem?
    func touchUpInsideOrderEdit(cell : OrderTableViewCell) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            editRequestedOrderItem = self.orderItems[indexPath.row]
            self.performSegueWithIdentifier(self.getSegueIdentifier(self.editRequestedOrderItem!), sender: self)
        }
    }

    /**
    個別オーダー商品のカスタマイズ完了時処理
    */
    func didCompleteCustomizeOrder(orderListItem : OrderListItem?){
        // 全体をリフレッシュするか 個別の情報をもらうか
        // 配列の順に表示が済んでいる前提
        if let current = orderListItem {
            if let index = find(self.orderItems, current) {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: self.productSection)], withRowAnimation: .Automatic)
            }
            //self.tableView.reloadData()
        }
    }
    
    func selectAndClose(store : Store){
        self.orderHeader.store = store
        
        // TODO: 位置が決めうちになっている
        if var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: self.headerSection)) {
            cell.textLabel?.text = self.orderHeader.store?.name
        }
    }
}
