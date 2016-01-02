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
    AddCustomItemCustomizingOrderTableViewCellDelegate,
    CustomItemCustomizingOrderTableViewCellDelegate,
    HotOrIcedCustomizingOrderTableViewCellDelegate{
    
    struct SectionIndex {
        static let General = 0
        static let Original = 1
        static let Custom = 2
    }

    var orderItem : OrderListItem?
    var delegate : CustomizingOrderTableViewDelegate?
    
    // keyPathsはデフォルトセルを使用する場合にのみ必要
    // TODO: ドリンク／フード、ドリンクの構成要素によって、表示・非表示／活性・非活性を切り替えられるよう、下記配列の要素を変化させる
    // 専用の関数を作って、マッピングを遅延評価するようにする
    // Generalセクションの項目を変えれば共用できるような気がする
    lazy var nameMappings : [( section : String, detailItemInfos : [(cellId : String, keyPaths : String)])] = self.initializeNameMappings()
    
    func initializeNameMappings() -> [( section : String, detailItemInfos : [(cellId : String, keyPaths : String)])] {
        return [
            (
                section: "General",
                detailItemInfos: self.orderItem?.productEntity is Drink ? [
                    (cellId: CustomizingOrderTableViewCell.CellIds.productName, keyPaths: "productEntity.name"),
                    (cellId: CustomizingOrderTableViewCell.CellIds.price, keyPaths: "productEntity.price"),
                    (cellId: CustomizingOrderTableViewCell.CellIds.calorie, keyPaths: ""),
                    (cellId: CustomizingOrderTableViewCell.CellIds.size, keyPaths: ""),
                    (cellId: CustomizingOrderTableViewCell.CellIds.hotOrIced, keyPaths: ""),
                    (cellId: CustomizingOrderTableViewCell.CellIds.reusableCup, keyPaths: ""),
                    (cellId: CustomizingOrderTableViewCell.CellIds.oneMoreCoffee, keyPaths: ""),
                    (cellId: CustomizingOrderTableViewCell.CellIds.ticket, keyPaths: "")
                ] : [
                    (cellId: CustomizingOrderTableViewCell.CellIds.productName, keyPaths: ""),
                    (cellId: CustomizingOrderTableViewCell.CellIds.price, keyPaths: ""),
                    (cellId: CustomizingOrderTableViewCell.CellIds.calorie, keyPaths: "")
                ]
            ),
            (
                section: "Original",
                detailItemInfos: [
                ]
            ),
            (
                // TODO: 直接カスタムアイテムを並べるか、それとも、「Add Items ...」から別画面に移動するか
                // 結局カスタムセル自体は必要になると思うので
                // 別画面の場合は、モーダル表示する（決定／キャンセルボタンをどこにおくかだけど）
                // それとも前にやったように、ナビゲーションでの遷移にするか（戻るのイベントを取れなかったような）
                section: "Custom",
                detailItemInfos: [
                ]
            )
        ]
    }
    
    func cellIdForIndexPath(indexPath : NSIndexPath) -> String {
        var cellId = ""
        if self.nameMappings.count > indexPath.section && self.nameMappings[indexPath.section].detailItemInfos.count > indexPath.row {
            cellId = self.nameMappings[indexPath.section].detailItemInfos[indexPath.row].cellId
        }
        else if indexPath.section == SectionIndex.Original{
            cellId = CustomizingOrderTableViewCell.CellIds.customItemAdded
        }
        else if indexPath.section == SectionIndex.Custom {
            if self.orderItem?.customizationItems?.ingredients.count > indexPath.row {
                cellId = CustomizingOrderTableViewCell.CellIds.customItemAdded
            }
            else{
                cellId = CustomizingOrderTableViewCell.CellIds.addCustomItem
            }
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
        
        self.navigationItem.title = "Customizing Order"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.nameMappings.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return section == SectionIndex.General ? self.nameMappings[section].detailItemInfos.count : section == SectionIndex.Original ? self.orderItem?.originalItems?.ingredients.count ?? 0 : (self.orderItem?.customizationItems?.ingredients.count ?? 0) + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 必ず取得できる前提
        let cell = self.dequeueReusableCellWithIndexPath(indexPath)!

        // カスタマイズは動的、基本情報は固定数のセルにしたい
        if indexPath.section == SectionIndex.General {
            if cell.reuseIdentifier == CustomizingOrderTableViewCell.CellIds.base {
                if let value : AnyObject = self.orderItem?.valueForKeyPath(self.nameMappings[indexPath.section].detailItemInfos[indexPath.row].keyPaths){
                    cell.textLabel?.text = value as? String ?? (value as? NSNumber)?.stringValue
                }
            }
            else{
                cell.configure(orderItem!, delegate: self, indexPath: indexPath)
            }
        }
        else if indexPath.section == SectionIndex.Custom || indexPath.section == SectionIndex.Original {
            // カスタマイズ項目
            cell.configure(self.orderItem!, delegate: self, indexPath: indexPath)
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
    
    // スワイプで削除を有効にする
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == SectionIndex.Custom && indexPath.row < self.tableView.numberOfRowsInSection(indexPath.section) - 1
    }
    
    // スワイプのため、空の実装が必要
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    // スワイプ時に表示する項目
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        let editAction =
//        UITableViewRowAction(style: .Normal, // 削除等の破壊的な操作を示さないスタイル
//            title: "edit"){(action, indexPath) in println("\(indexPath) edited")}
//        editAction.backgroundColor = UIColor.greenColor()
        
        let deleteAction =
        UITableViewRowAction(style: .Default, // 標準のスタイル
            title: "delete"){(action, indexPath) in
                print("\(indexPath) deleted")
                // カスタムアイテムを削除
                self.deleteCustomItem(indexPath)
//                self.orderItem?.customizationItems?.ingredients.removeAtIndex(indexPath.row)
//                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
//        return [editAction, deleteAction]
        return [deleteAction]
    }
    
    func deleteCustomItem(indexPath : NSIndexPath) {
        self.orderItem?.customizationItems?.ingredients.removeAtIndex(indexPath.row)
        self.updateTotalPrice()
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        //self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let customItemsViewController = segue.destinationViewController as? CustomItemsTableViewController {
            customItemsViewController.orderListItem = self.orderItem
            if let cell = sender as? CustomItemCustomizingOrderTableViewCell {
                customItemsViewController.customItemForEdit = cell.ingredient
            }
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if let nv = parent as? UINavigationController {
            print("appended")
            
            // 直前のViewControllerを取得し、delegateに設定
            if let ov = nv.viewControllers[nv.viewControllers.count - 2] as? CustomizingOrderTableViewDelegate {
                self.delegate = ov
            }
        }
        else {
            print("unwind")
            self.delegate?.didCompleteCustomizeOrder(self.orderItem)
            self.delegate = nil
        }
    }
    
    @IBAction func customItemListDidComplete(segue : UIStoryboardSegue) {
        if let customItemListViewController = segue.sourceViewController as? CustomItemsTableViewController {
            print("[complete] unwind to dst")
            
            // オリジナルかカスタムかで制御を分ける
            // オリジナル
            if customItemListViewController.customItemForEdit != nil && customItemListViewController.customItemForEdit!.isPartOfOriginalIngredients{
                
                // ミルクの変更の場合は、nameで検索できないので、種類で検索して差し替える（ミルクは一種類という縛りがあるための特別仕様）
//                if customItemListViewController.customItemForEdit!.type == .Milk {
//                    if var current = self.orderItem?.originalItems?.ingredients.filter( { $0.type == customItemListViewController.customItemForEdit!.type }).first {
//                        current.name = customItemListViewController.customItemForEdit!.name
//                        current.enable = customItemListViewController.customItemForEdit!.enable
//                        current.quantityType = customItemListViewController.customItemForEdit!.quantityType
//                    }
//                }
//                else {
                    if let current = self.orderItem?.originalItems?.ingredients.filter( { $0.name == customItemListViewController.customItemForEdit!.name }).first {
                        
                        current.name = customItemListViewController.editResults.first?.name ?? ""
                        current.enable = customItemListViewController.editResults.first?.enable ?? false
                        current.quantityType = customItemListViewController.editResults.first?.quantityType ?? .Normal
                        current.icon = customItemListViewController.editResults.first?.icon
                        
                        // 総額を更新
                        self.updateTotalPrice()
                        
                        self.tableView.reloadSections(NSIndexSet(index: SectionIndex.Original), withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
//                }
            // カスタム
            } else {
                
                self.addOrUpdateCustomItems(customItemListViewController.editResults)
                self.updateTotalPrice()
                self.tableView.reloadSections(NSIndexSet(index: SectionIndex.Custom), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    @IBAction func customItemListDidCancel(segue : UIStoryboardSegue) {
        if let customItemListViewController = segue.sourceViewController as? CustomItemsTableViewController {
            print("[cancel] unwind to dst")
            
        }
    }
    
    func deltaPriceForOriginal(ingredient : Ingredient, currentUnitPrice : Int) -> Int {
        var delta = 0
        switch ingredient.type {
        case .Milk:
            delta = ingredient.unitPrice - currentUnitPrice
        case .Syrup:
            // ノンシロップでかつ、カスタムに１項目以上シロップがあれば、-50
            delta = 0
        default:
            delta = 0
        }
        
        return delta
    }
    
    func addOrUpdateCustomItems(ingredients : [Ingredient]) {
        if self.orderItem?.customizationItems == nil {
            self.orderItem?.customizationItems = IngredientCollection()
        }
        
        // 単純に置き換えた方が効率がいい？
        //self.orderItem?.customizationItems?.ingredients = ingredients
        
        for ing in ingredients {
            if let index = self.orderItem!.customizationItems!.ingredients.indexOf(ing) {
                if ing.enable {
                    self.orderItem?.customizationItems?.ingredients[index].quantityType = ing.quantityType
                }
                else {
                    self.orderItem?.customizationItems?.ingredients.removeAtIndex(index)
                }
            }
            else{
                if ing.enable {
                    self.orderItem?.customizationItems?.ingredients.append(ing)
                }
            }
        }
    }
    
    func discountFactors() -> [String] {
        
        var factors : [String] = []
        
        // ワンモア
        if self.orderItem?.oneMoreCoffee ?? false {
            factors += [DrinkPriceCalculator.Discount.oneMoreCoffee.name]
        }
        
        // カップ値引き
        if self.orderItem?.reusableCup ?? false {
            factors += [DrinkPriceCalculator.Discount.reusableCup.name]
        }
        
        // TODO: チケット値引き等は追って実装する
        
        return factors
    }
    
    func updateTotalPrice() {
        if let calculator = PriceCalculator.createPriceCalculatorForEntity(self.orderItem?.productEntity, customizedOriginals: self.orderItem?.originalItems, customs: self.orderItem?.customizationItems, discountFactors: self.discountFactors(), size: self.orderItem?.size ?? DrinkSize.Tall) {
            self.orderItem?.customPrice = calculator.priceForCustoms()
            self.orderItem?.totalPrice = calculator.priceForTotal()
            self.addPrice(0)
        }
    }

    func updateCustomizationPrice() {
        let delta = (self.orderItem?.customizationItems?.price() ?? 0) - (self.orderItem?.customPrice ?? 0)
        self.orderItem?.customPrice = self.orderItem?.customizationItems?.price() ?? 0
        self.addPrice(delta)
    }
    
    func addPrice(delta : Int) {
        if let totalPrice = self.orderItem?.totalPrice {
            let newPrice = totalPrice + delta
            self.orderItem?.totalPrice = newPrice
            
            // TODO: 価格のリスト上での位置は、動的に取得するようにする
            let indexPath = NSIndexPath(forRow: 1, inSection: SectionIndex.General)
            if let priceCell = self.tableView.cellForRowAtIndexPath(indexPath) as? CustomizingOrderTableViewCell {
                priceCell.configure(self.orderItem!, delegate: self, indexPath: indexPath)
            }
        }
    }
    
    func updateCalorie(){
        // TODO: カロリーのリスト上での位置は、動的に取得するようにする
        let indexPath = NSIndexPath(forRow: 2, inSection: SectionIndex.General)
        if let calorieCell = self.tableView.cellForRowAtIndexPath(indexPath) as? CustomizingOrderTableViewCell {
            calorieCell.configure(self.orderItem!, delegate: self, indexPath: indexPath)
        }
    }
    
    func valueChangedSizeSegment(cell : SizeCustomizingOrderTableViewCell, size : DrinkSize){
        // サイズ間での価格差分を計算
        let delta = size.priceForDelta() - (self.orderItem?.size.priceForDelta() ?? 0)
        
        self.orderItem?.size = size
        
        if !(self.orderItem?.oneMoreCoffee ?? false) {
            self.addPrice(delta)
        }
        
        self.updateCalorie()
    }
    
    func valueChangedHotOrIcedSegment(cell : HotOrIcedCustomizingOrderTableViewCell, hotOrIced : String){
        self.orderItem?.hotOrIce = hotOrIced
        self.updateCalorie()
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
        self.performSegueWithIdentifier("showModallyCustomItemListSegue", sender: cell)
    }
    
    func touchUpInsideEditButton(cell : CustomItemCustomizingOrderTableViewCell){
        self.performSegueWithIdentifier("showModallyCustomItemListSegue", sender: cell)
    }
}

protocol CustomizingOrderTableViewDelegate {
    func didCompleteCustomizeOrder(orderListItem : OrderListItem?)
}
