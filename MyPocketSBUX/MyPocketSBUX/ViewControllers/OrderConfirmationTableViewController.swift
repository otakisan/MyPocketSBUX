//
//  OrderConfirmationTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/26.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrderConfirmationTableViewController: UITableViewController {
    
    struct CellIds {
        static let defaultCell = "defaultOrderConfirmationTableViewCell"
    }
    
    var orderListItem : [(category : ProductCategory, orders: [OrderListItem])] = []

    @IBAction func didPressDoneBarButton(sender: UIBarButtonItem) {
        // オーダーを登録
        self.saveOrder()
        
        // 確認の通知を画面上部に
        // TODO: 登録成功時に出力する情報 登録日時、件数、金額、…
        self.showNavigationPrompt("order complete", message: "order detail", displayingTime: 2.0)
        
        // ルートへ戻る
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    private func showNavigationPrompt(title : String, message : String, displayingTime: NSTimeInterval) {
        self.navigationItem.prompt = "\(title) : \(message)"
        
        // リピートせず１回のみの実行とするため、invalidateは不要
        NSTimer.scheduledTimerWithTimeInterval(displayingTime, target: self, selector: Selector("dismissNavigationPrompt"), userInfo: nil, repeats: false)
    }
    
    func dismissNavigationPrompt() {
        self.navigationItem.prompt = nil
    }
    
    func saveOrder() {
        // TODO: 店舗をどうやって入力するか
        // 店舗一覧・マップの画面を共通化してそこから選択してもらう形にするか
        // どこで入力を促すかっていうのが問題だな
        // オーダー画面（編集画面）のどこかで入力するほうがよいか？
        
        OrderManager.instance.saveOrder(self.orderListItem)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.orderListItem.count + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return section < self.tableView.numberOfSections() - 1 ? self.orderListItem[section].orders.count : 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIds.defaultCell, forIndexPath: indexPath) as! UITableViewCell

        // 最終セクションは合計
        if indexPath.section < self.tableView.numberOfSections() - 1 {
            let name = self.orderListItem[indexPath.section].orders[indexPath.row].productEntity?.valueForKey("name") as? String ?? ""
            let price = "\(self.orderListItem[indexPath.section].orders[indexPath.row].totalPrice)"
            cell.textLabel?.text = "\(name) ¥\(price)"
        } else {
            let price = PriceCalculator.totalPrice(OrderManager.instance.unionOrderListItem(self.orderListItem))
            cell.textLabel?.text = "¥\(price.taxExcluded) (tax-excluded)  ¥\(price.taxIncluded) (tax-included)"
        }

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < self.tableView.numberOfSections() - 1 ? self.orderListItem[section].category.name() : "Total"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

enum ProductCategory {
    case Drink
    case Food
    case Bean
    
    func name() -> String {
        var name = ""
        switch self {
        case Drink:
            name = "Drink"
        case Food:
            name = "Food"
        case Bean:
            name = "Bean"
        default:
            name = "Drink"
        }
        
        return name
    }
}