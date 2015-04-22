//
//  CustomizingOrderTableViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/14.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class CustomizingOrderTableViewController: UITableViewController,
    SizeCustomizingOrderTableViewCellDelegate,
    ReusableCupCustomizingOrderTableViewCellDelegate,
    OneMoreCoffeeCustomizingOrderTableViewCellDelegate,
    AddCustomItemCustomizingOrderTableViewCellDelegate{

    var orderItem : OrderListItem?
    
    // keyPathsはデフォルトセルを使用する場合にのみ必要
    // TODO: ドリンク／フード、ドリンクの構成要素によって、表示・非表示／活性・非活性を切り替えられるよう、下記配列の要素を変化させる
    // 専用の関数を作って、マッピングを遅延評価するようにする
    var nameMappings : [( section : String, detailItemInfos : [(cellId : String, keyPaths : String)])] = [
        (
            section: "General",
            detailItemInfos: [
                (cellId: CustomizingOrderTableViewCell.CellIds.productName, keyPaths: "productEntity.name"),
                (cellId: CustomizingOrderTableViewCell.CellIds.price, keyPaths: "productEntity.price"),
                (cellId: CustomizingOrderTableViewCell.CellIds.calorie, keyPaths: ""),
                (cellId: CustomizingOrderTableViewCell.CellIds.size, keyPaths: ""),
                (cellId: CustomizingOrderTableViewCell.CellIds.hotOrIced, keyPaths: ""),
                (cellId: CustomizingOrderTableViewCell.CellIds.reusableCup, keyPaths: ""),
                (cellId: CustomizingOrderTableViewCell.CellIds.oneMoreCoffee, keyPaths: ""),
                (cellId: CustomizingOrderTableViewCell.CellIds.ticket, keyPaths: "")
            ]
        ),
        (
            // TODO: 直接カスタムアイテムを並べるか、それとも、「Add Items ...」から別画面に移動するか
            // 結局カスタムセル自体は必要になると思うので
            // 別画面の場合は、モーダル表示する（決定／キャンセルボタンをどこにおくかだけど）
            // それとも前にやったように、ナビゲーションでの遷移にするか（戻るのイベントを取れなかったような）
            section: "Customization",
            detailItemInfos: [
//                (cellId: CustomizingOrderTableViewCell.CellIds.base, keyPaths: "customizationItems")
                (cellId: CustomizingOrderTableViewCell.CellIds.addCustomItem, keyPaths: "")
            ]
        )
    ]
    
    func cellIdForIndexPath(indexPath : NSIndexPath) -> String {
        var cellId = ""
        if self.nameMappings.count > indexPath.section && self.nameMappings[indexPath.section].detailItemInfos.count > indexPath.row {
            cellId = self.nameMappings[indexPath.section].detailItemInfos[indexPath.row].cellId
        }
        else{
            fatalError("not found cellId")
        }
        
        return cellId
    }
    
    func dequeueReusableCellWithIndexPath(indexPath : NSIndexPath) -> CustomizingOrderTableViewCell? {
        return self.tableView.dequeueReusableCellWithIdentifier(self.cellIdForIndexPath(indexPath), forIndexPath: indexPath) as? CustomizingOrderTableViewCell
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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return section == 0 ? self.nameMappings[section].detailItemInfos.count : (self.orderItem?.customizationItems?.ingredients.count ?? 0) + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 必ず取得できる前提
        let cell = self.dequeueReusableCellWithIndexPath(indexPath)!

        // カスタマイズは動的、基本情報は固定数のセルにしたい
        if indexPath.section == 0 {
            if cell.reuseIdentifier == CustomizingOrderTableViewCell.CellIds.base {
                if let value : AnyObject = self.orderItem?.valueForKeyPath(self.nameMappings[indexPath.section].detailItemInfos[indexPath.row].keyPaths){
                    cell.textLabel?.text = value as? String ?? (value as? NSNumber)?.stringValue
                }
            }
            else{
                cell.configure(orderItem!, delegate: self)
            }
        }
        else if indexPath.section == 1 {
            // カスタマイズ項目
            cell.configure(self.orderItem!, delegate: self)
            //cell.textLabel?.text = self.orderItem?.customizationItems?.ingredients[indexPath.row].name
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.nameMappings[section].section
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
    }
    
    
    func addPrice(delta : Int) {
        if var totalPrice = self.orderItem?.totalPrice {
            let newPrice = totalPrice + delta
            self.orderItem?.totalPrice = newPrice
            
            // TODO: 価格のリスト上での位置は、動的に取得するようにする
            if let priceCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? CustomizingOrderTableViewCell {
                priceCell.configure(self.orderItem!, delegate: self)
            }
        }
    }
    
    func valueChangedSizeSegment(cell : SizeCustomizingOrderTableViewCell, size : DrinkSize){
        // サイズ間での価格差分を計算
        let delta = size.priceForDelta() - (self.orderItem?.size.priceForDelta() ?? 0)
        
        self.orderItem?.size = size
        
        if !(self.orderItem?.oneMoreCoffee ?? false) {
            self.addPrice(delta)
        }
    }
    
    func valueChangedReusableCupSwitch(cell : ReusableCupCustomizingOrderTableViewCell, on : Bool){
        self.orderItem?.reusableCup = on
        
        // TODO: 除外品（プレス等）を考慮した上での20円引き
        // TODO: onの場合にのみ、基本価格から値引きするようにしないと初期状態によっては正常動作しない
        let delta = ((on ? -1 : 1) * 20)
        if !(self.orderItem?.oneMoreCoffee ?? false) {
            self.addPrice(delta)
        }
    }
    
    func valueChangedOneMoreCoffeeSwitch(cell : OneMoreCoffeeCustomizingOrderTableViewCell, on : Bool){
        self.orderItem?.oneMoreCoffee = on
        
        if let basePrice = self.orderItem?.productEntity?.valueForKey("price") as? NSNumber {
            let currentBasePrice = basePrice.integerValue + (self.orderItem?.size.priceForDelta() ?? 0) + ((self.orderItem?.reusableCup ?? false) ? -20 : 0)
            
            var delta = currentBasePrice - 100
            if on {
                delta = -delta
            }
            
            self.addPrice(delta)
        }
    }
    
    func touchUpInsideAddCustomItemButton(cell : AddCustomItemCustomizingOrderTableViewCell){
        self.performSegueWithIdentifier("showModallyStaticCustomItemListSegue", sender: nil)
    }
}
