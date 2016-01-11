//
//  OrderConfirmationTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/26.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrderConfirmationTableViewController: UITableViewController {
    
    let productSectionOffset = 1
    
    struct OrderHeaderIndex {
        static let tableViewSection = 0
        static let store = 0
        static let notes = 1
    }
    
    struct CellIds {
        static let defaultCell = "defaultOrderConfirmationTableViewCell"
    }
    
    var orderHeader : OrderHeader?
    var orderListItem : [(category : ProductCategory, orders: [OrderListItem])] = []

    @IBAction func didPressDoneBarButton(sender: UIBarButtonItem) {
        
        // サインイン必須
        if !IdentityContext.sharedInstance.signedIn() {
            self.showNavigationPrompt("PleaseSignIn".localized(), message: "", displayingTime: 2.0)
            return
        }
        
        // オーダーを登録
        self.saveOrder()
        
        // 確認の通知を画面上部に
        // TODO: 登録成功時に出力する情報 登録日時、件数、金額、…
        self.showNavigationPrompt("OrderComplete".localized(), message: "", displayingTime: 2.0)
        
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
        
        OrderManager.instance.saveOrder(self.orderListItem, orderHeader: self.orderHeader)
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
        // 先頭がヘッダ、末尾が合計、残りはオーダー数による
        return self.productSectionOffset + self.orderListItem.count + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 先頭がヘッダ（2行）、末尾が合計（1行）、残りはオーダー数による
        return section == OrderHeaderIndex.tableViewSection ? 2 : section < self.tableView.numberOfSections - 1 ? self.orderListItem[section - self.productSectionOffset].orders.count : 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIds.defaultCell, forIndexPath: indexPath) 

        // 先頭がヘッダ、最終セクションは合計
        if indexPath.section == OrderHeaderIndex.tableViewSection {
            // TODO: 何か綺麗にまとめる術があれば
            switch indexPath.row {
            case OrderHeaderIndex.store:
                cell.textLabel?.text = self.orderHeader?.store?.name
            case OrderHeaderIndex.notes:
                cell.textLabel?.text = self.orderHeader?.notes
            default:
                cell.textLabel?.text = "uknown"
            }
        }
        else if indexPath.section < self.tableView.numberOfSections - 1 {
            let name = self.orderListItem[indexPath.section - self.productSectionOffset].orders[indexPath.row].productEntity?.valueForKey("name") as? String ?? ""
            let price = "\(self.orderListItem[indexPath.section - self.productSectionOffset].orders[indexPath.row].totalPrice)"
            cell.textLabel?.text = "\(name) ¥\(price)"
        } else {
            let price = PriceCalculator.totalPrice(OrderManager.instance.unionOrderListItem(self.orderListItem))
            cell.textLabel?.text = "¥\(price.taxExcluded) (\("tax-excluded".localized()))  ¥\(price.taxIncluded) (\("tax-included".localized()))"
        }

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == OrderHeaderIndex.tableViewSection ? "General".localized() : section < self.tableView.numberOfSections - 1 ? self.orderListItem[section - self.productSectionOffset].category.name().localized() : "Total".localized()
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