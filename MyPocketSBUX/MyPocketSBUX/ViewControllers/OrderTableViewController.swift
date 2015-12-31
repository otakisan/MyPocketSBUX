//
//  OrderTableViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/13.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrderTableViewController: UITableViewController, OrderTableViewCellDelegate, CustomizingOrderTableViewDelegate, StoresTableViewDelegate, NotesOrderTableViewCellDelegate {
    
    struct StoryboardConstants {
        static let storyboardName = "Main"
        static let viewControllerIdentifier = "OrderTableViewController"
    }

    let headerSection = 0
    let productSection = 1
    let storeRow = 0
    let notesRow = 1
    
//    var orderItems : [(productCategory : String, orders : [OrderListItem])] = []
    var orderHeader : OrderHeader = OrderHeader()
    var orderItems : [OrderListItem] = []

    class func forOrder(order: Order) -> OrderTableViewController {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardConstants.viewControllerIdentifier) as! OrderTableViewController
        
        let orderInfo = OrderManager.instance.loadOrder(order, orderDetails: order.orderDetails.allObjects as! [OrderDetail])
        viewController.orderHeader = orderInfo.header
        viewController.orderItems = orderInfo.details
        
        return viewController
    }

    func getReuseCellIdentifier(orderListItem : OrderListItem) -> String {
        var identifier = ""
        
        if orderListItem.productEntity is Drink {
            identifier = "drinkOrderListItemCell"
        }
        else if orderListItem.productEntity is Food {
            identifier = "foodOrderListItemCell"
        }
        else if orderListItem.productEntity is Bean {
            identifier = "beanOrderListItemCell"
        }
        else{
            fatalError("unknown product type")
        }
        
        return identifier
    }
    
    func getSegueIdentifier(orderListItem : OrderListItem) -> String {
        var identifier = ""
        
        if orderListItem.productEntity is Drink {
            identifier = "customizingOrderSegue"
        }
        else if orderListItem.productEntity is Food {
            identifier = "customizingOrderSegue"
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
        
        let cell : UITableViewCell
        if indexPath.section == 0 {
            // ここでキャストできないということはあってはならない
            cell = tableView.dequeueReusableCellWithIdentifier(indexPath.row == 0 ? "storeOrderListItemCell" : "notesOrderListItemCell", forIndexPath: indexPath) as! OrderHeaderTableViewCell
            
            let headerCell = cell as! OrderHeaderTableViewCell
            headerCell.configure(self.orderHeader)
            headerCell.delegate = self
        }
        else {
            // ドリンク or フードで、取り出すセルのタイプを分ける
            cell = tableView.dequeueReusableCellWithIdentifier(self.getReuseCellIdentifier(self.orderItems[indexPath.row]), forIndexPath: indexPath) as! OrderTableViewCell
            
            // Configure the cell...
            
            let detailCell = cell as! OrderTableViewCell
            detailCell.configure(self.orderItems[indexPath.row])
            detailCell.delegate = self
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? " " : "Products"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? CGFloat(44) : CGFloat(100)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == productSection {
            self.showOrderProductActionSheet(indexPath)
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // スワイプのため、空の実装が必要
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // スワイプ時に表示する項目
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return self.tableViewRowAction(indexPath.section)
    }
    
    private func tableViewRowAction(section : Int) -> [UITableViewRowAction]? {
        
        var rowActions : [UITableViewRowAction]? = nil
        
        switch(section) {
        case headerSection:
            let clearAction = UITableViewRowAction(style: .Default, title: "Clear") {(action, indexPath) in
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? OrderHeaderTableViewCell {
                    cell.clear()
                }
                self.tableView.setEditing(false, animated: true)
            }
            clearAction.backgroundColor = UIColor.grayColor()
            
            rowActions = [clearAction]
            break
        case productSection:
            let detailAction = UITableViewRowAction(style: .Default, title: "Details") {(action, indexPath) in
                self.showProductDetail(self.orderItems[indexPath.row].productEntity as? NSObject)
                self.tableView.setEditing(false, animated: true)
            }
            let copyAction = UITableViewRowAction(style: .Default, title: "Copy") {(action, indexPath) in
                self.copyProductCell(indexPath)
                self.tableView.setEditing(false, animated: true)
            }
            let editAction = UITableViewRowAction(style: .Default, title: "Edit") {(action, indexPath) in
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? OrderTableViewCell {
                    self.touchUpInsideOrderEdit(cell)
                }
                self.tableView.setEditing(false, animated: true)
            }
            detailAction.backgroundColor = UIColor.grayColor()
            copyAction.backgroundColor = UIColor.blueColor()
            editAction.backgroundColor = UIColor.greenColor()
            
            rowActions = [editAction, copyAction, detailAction]
            break
        default:
            break
        }
        
        return rowActions
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
        
        // フォーカスを返す
        self.notesEndEditing()
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let customizingOrderViewController = segue.destinationViewController as? CustomizingOrderTableViewController {
            customizingOrderViewController.orderItem = self.editRequestedOrderItem
        }
        else if let orderConfirmationViewController = segue.destinationViewController as? OrderConfirmationTableViewController {
            // TODO: ドリンク、フード、…とカテゴリ別に分ける
            orderConfirmationViewController.orderListItem = [(category: ProductCategory.Drink, orders: self.orderItems.filter({$0.on}))]
            orderConfirmationViewController.orderHeader = self.orderHeader
        }
        else if let storesVc = segue.destinationViewController as? StoresTableViewController {
            storesVc.selectBySwipe = true
            storesVc.delegate = self
        }
    }
    
    func valueChangedOrderSwitch(cell : OrderTableViewCell, on : Bool) {
        if let order = cell.orderListItem {
            order.on = on
        }
    }
    
    func editingDidEndNotesTextField(cell : NotesOrderTableViewCell, notes : String){
        self.orderHeader.notes = notes
    }
    
    func textFieldShouldReturnNotesTextField(cell : NotesOrderTableViewCell, notes : String){
        //self.orderHeader.notes = notes
    }
    
    func notesEndEditing() {
        if let notesCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: self.notesRow, inSection: self.headerSection)) as? NotesOrderTableViewCell {
            notesCell.notesTextField.endEditing(true)
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
            if let index = self.orderItems.indexOf(current) {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: self.productSection)], withRowAnimation: .Automatic)
            }
            //self.tableView.reloadData()
        }
    }
    
    func selectAndClose(store : Store){
        self.orderHeader.store = store
        
        // TODO: 位置が決めうちになっている
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: self.storeRow, inSection: self.headerSection)) as? StoreOrderTableViewCell {
            cell.storeNameLabel.text = self.orderHeader.store?.name
        }
    }
    
    private func showOrderProductActionSheet(indexPath : NSIndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            action in
        }
        let copyAction = UIAlertAction(title: "Copy", style: .Default) {
            action in self.copyProductCell(indexPath)
        }
        let detailAction = UIAlertAction(title: "View details", style: .Default) {
            action in self.showProductDetail(self.orderItems[indexPath.row].productEntity as? NSObject)
        }
        
        alertController.addAction(detailAction)
        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func showProductDetail(product : NSObject?) {
        self.navigationController?.pushViewController(ProductDetailTableViewController.forProduct(product), animated: true)
    }
    
    private func copyProductCell(indexPath : NSIndexPath) {
        if indexPath.section == productSection {
            // コピーしたものを、コピー元の位置に挿入する形とするが、要望があれば下に追加する形とする
            // データの複製
            self.orderItems.insert(self.copyProductItem(indexPath.row), atIndex: indexPath.row)
            
            // セルのインサート
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    private func copyProductItem(index : Int) -> OrderListItem {
        // TODO: カスタマイズなしでのコピーは、要望があれば対応する
        return self.orderItems[index].copy() as! OrderListItem
    }

}
