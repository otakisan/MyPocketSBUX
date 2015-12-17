//
//  ProductsForSaleTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreData

class ProductsForSaleTableViewController: UITableViewController, ProductsForSaleTableViewCellDelegate {
    
    var productsForSaleItems : [(category: String, listItems: [ProductsForSaleListItem])] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        Beans.instance().clearAllEntities()
        ContentsManager.instance.fetchContents(["bean"], variables: [:], orderKeys: [(columnName : "category", ascending : true), (columnName : "name", ascending : true)], completionHandler: { fetchResults in
            self.productsForSaleItems = fetchResults.map {
                var listItems : [ProductsForSaleListItem] = []
                for entity in $0.entities {
                    let listItem = ProductsForSaleListItem()
                    listItem.productEntity = entity
                    listItem.isOnOrderList = false
                    
                    listItems += [listItem]
                }
                
                return ($0.entityName, listItems)
            }
            
            self.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.productsForSaleItems.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productsForSaleItems[section].listItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellId(indexPath), forIndexPath: indexPath) as! ProductsForSaleTableViewCell

        cell.configure(self.productsForSaleItems[indexPath.section].listItems[indexPath.row])
        cell.delegate = self

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.productsForSaleItems[section].category
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
        if let orderViewController = segue.destinationViewController as? OrderTableViewController {
            
            var selected : [OrderListItem] = []
            for category in self.productsForSaleItems {
                let orders = category.listItems.filter({$0.isOnOrderList}).map { (listItem : ProductsForSaleListItem) -> OrderListItem in
                    let orderListItem = OrderListItem()
                    orderListItem.productEntity = listItem.productEntity
                    orderListItem.totalPrice = (orderListItem.productEntity?.valueForKey("price") as? NSNumber ?? NSNumber(integer: 0)).integerValue
                    orderListItem.on = listItem.isOnOrderList
                    return orderListItem
                }
                
                selected += orders
            }
            
            orderViewController.orderItems = selected
        }
        else if let productDetailViewController = segue.destinationViewController as? ProductDetailTableViewController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            
                productDetailViewController.product = self.productsForSaleItems[indexPath.section].listItems[indexPath.row].productEntity
            }
        }
    
    }
    
    func cellId(indexPath: NSIndexPath) -> String {
        var cellIdString = ""
        let entity = self.productsForSaleItems[indexPath.section].listItems[indexPath.row].productEntity
        if entity is Bean {
            cellIdString = "beanProductsForSaleTableViewCell"
        }
        else {
            cellIdString = "defaultProductsForSaleTableViewCell"
        }
        
        return cellIdString
    }
    
    func valueChangedOrderSwitch(cell : ProductsForSaleTableViewCell, on : Bool){
        if let indexPath = self.tableView.indexPathForCell(cell) {
            self.productsForSaleItems[indexPath.section].listItems[indexPath.row].isOnOrderList = on
        }
    }
}
