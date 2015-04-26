//
//  CustomItemsTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/22.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class CustomItemsTableViewController: UITableViewController, SyrupCustomItemsTableViewCellDelegate, WhippedCreamCustomItemsTableViewCellDelegate, SauceCustomItemsTableViewCellDelegate, MilkCustomItemsTableViewCellDelegate {
    
    let cellIdMappings : [CustomizationIngredientype:String] = [
        CustomizationIngredientype.Syrup : "SyrupTableViewCell",
        CustomizationIngredientype.Milk : "MilkTableViewCell",
        CustomizationIngredientype.WhippedCreamDrink : "WhippedCreamTableViewCell",
        CustomizationIngredientype.Sauce : "SauceTableViewCell",
        CustomizationIngredientype.Chip : "ChocolateChipTableViewCell",
        CustomizationIngredientype.Coffee : "CoffeeTableViewCell",
        CustomizationIngredientype.Espresso : "EspressoTableViewCell",
        CustomizationIngredientype.WhippedCreamFood : "WhippedCreamTableViewCell"
    ]

    @IBOutlet weak var customItemListNavigationBar: UINavigationBar!
    
    // 追加時：すでに追加済みのアイテムは表示しない 編集時：追加済みアイテムのみ表示する という動作が必要
    // 現在の注文状態を受け、プラス、動作モードから、リストに表示するアイテムを決める
    // セルのプロトタイプ自体は全カスタムアイテム（カスタムアイテムの種類の数）だけ作成する
    
    lazy var availableCustomizationChoices : IngredientCollection = self.initAvailableCustomizationChoices()

    // TODO: 呼び出し元の情報のため、編集不可にしたい
    var orderListItem : OrderListItem?
    var customItemForEdit : Ingredient?
    var editResults : [Ingredient] = []
    
    func initAvailableCustomizationChoices() -> IngredientCollection{
        // 商品コード（もしくは名称等の情報）を渡せば、その商品に適用可能なカスタムアイテムを表示する
        var choices = IngredientCollection()
        if let editItem = self.customItemForEdit {
            choices.ingredients += [editItem]
        }
        else{
            choices.ingredients += self.availableCustomizationChoicesRemaining()
        }
        
        return choices
    }
    
    func availableCustomizationChoicesRemaining() -> [Ingredient] {
        var choices = [Ingredient]()
        var availableChoices = self.getAvailableCustomizationChoices(self.orderListItem?.productEntity?.valueForKey("janCode") as? String ?? "").customs
        
        // 適用可能なもののうち、まだカスタマイズに追加されていないもののみにする
        // TODO: オーダーの管理は専用のクラスを作って、そっちで管理する。画面クラスは値の受け渡しのみするように。
        choices = availableChoices
        if let orderListItem = self.orderListItem {
            if let customItems = orderListItem.customizationItems {
                choices = availableChoices.filter { (choice : Ingredient) in
                    !contains(customItems.ingredients) { (added : Ingredient) in
                        added.name == choice.name
                    }
                }
            }
        }
        
        return choices
    }
    
    func getAvailableCustomizationChoices(janCode : String) -> (originals : [Ingredient], customs : [Ingredient]) {
        // 商品の構成要素（カスタム可能なもののみ）を取得する
        var choices = IngredientManager.instance.getAvailableCustomizationChoices(janCode)
        
        return choices
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // ステータスバーの高さをの分だけ余白を作る（隙間ができて、背景色の設定が必要になるので行わない）
        let statusBarHeight: CGFloat! = UIApplication.sharedApplication().statusBarFrame.height
//        self.tableView.contentInset = UIEdgeInsetsMake(statusBarHeight, 0.0, 0.0, 0.0)
        
        // ナビゲーションバーの高さをプラスする（なぜか、タイトルの中心位置がちょうどよいところへ補正される）
        let currentRect = self.customItemListNavigationBar.frame
        self.customItemListNavigationBar.frame = CGRectMake(0, 0, currentRect.width, currentRect.height + statusBarHeight)
        
        // 当該商品に関連するカスタムアイテムのコレクションを取得する
        
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
        return self.availableCustomizationChoices.ingredients.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellId = "defaultCustomItemsTableViewCell"
        if let customCellId = self.cellIdMappings[self.availableCustomizationChoices.ingredients[indexPath.row].type] {
            cellId = customCellId
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! CustomItemsTableViewCell
        cell.configure(self.availableCustomizationChoices.ingredients[indexPath.row], delegate: self)
        //cell.textLabel?.text = self.availableCustomizationChoices.ingredients[indexPath.row].name

        // Configure the cell...

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
        switch segue.identifier ?? "" {
        case "cancelCustomItemListUnwindSegue", "doneCustomItemListUnwindSegue":
            // TODO: 画面上での設定値は、セルからのイベント契機で随時更新するのでここでは処理不要？
            println("now unwinding...")
        default:
            println("undefined segue")
        }
        
    }
    
    func thisCustomItem(sender : Ingredient) -> Ingredient? {
//        return self.orderListItem?.customizationItems?.ingredients.filter { $0.name == sender.name }.first
        var ing : Ingredient?
        if let index = find(self.editResults, sender) {
            ing = self.editResults[index]
        }
        return ing
        //return self.editResults.filter { $0.name == sender.name }.first
    }
    
    func addIngredient(ingredient : Ingredient) -> Ingredient {
        // appendするとコピーになるらしいので不要
        //let ing = Ingredient(srcIngredient: ingredient)
//        if self.orderListItem?.customizationItems == nil {
//            self.orderListItem?.customizationItems = IngredientCollection()
//        }
//        self.orderListItem?.customizationItems?.ingredients.append(ingredient)
        self.editResults.append(ingredient)
        
        return ingredient
    }
    
    // 共通処理（現状では、すべて個別イベントから受けているため、まとめられるのならまとめる）
    func valueChangedCommonAdditionSwitch(cell : CustomItemsTableViewCell, added : Bool){
        var ingredient = self.thisCustomItem(cell.ingredient) ?? self.addIngredient(cell.ingredient)
        
        ingredient.enable = added
        ingredient.quantity = added ? 1: 0
    }
    
    func valueChangedCommonQuantitySegment(cell : CustomItemsTableViewCell, type : QuantityType){
        self.thisCustomItem(cell.ingredient)?.quantityType = type
        self.thisCustomItem(cell.ingredient)?.quantity = type.addQuantity(self.thisCustomItem(cell.ingredient)?.quantity ?? 0)
    }
    
    func valueChangedWhippedCreamAdditionSwitch(cell : WhippedCreamCustomItemsTableViewCell, added : Bool){
        self.valueChangedCommonAdditionSwitch(cell, added: added)
    }
    
    func valueChangedWhippedCreamQuantitySegment(cell : WhippedCreamCustomItemsTableViewCell, type : QuantityType){
        self.valueChangedCommonQuantitySegment(cell, type: type)
    }

    func valueChangedSauceAdditionSwitch(cell : SauceCustomItemsTableViewCell, added : Bool){
        self.valueChangedCommonAdditionSwitch(cell, added: added)
    }
    
    func valueChangedSauceQuantitySegment(cell : SauceCustomItemsTableViewCell, type : QuantityType){
        self.valueChangedCommonQuantitySegment(cell, type: type)
    }

    func valueChangedAdditionSwitch(cell : SyrupCustomItemsTableViewCell, added : Bool){
        // TODO: レシピ情報とサイズがあれば、具体的な数量をだせるけど…
        var ingredient = self.thisCustomItem(cell.ingredient) ?? self.addIngredient(cell.ingredient)
        
        ingredient.enable = added
        ingredient.quantity = added ? 1: 0
    }
    
    func valueChangedQuantitySegment(cell : SyrupCustomItemsTableViewCell, type : QuantityType) {
        // TODO: 数量管理よりも、少なめ／多めの情報を保持しておいた方がよいか？
        self.thisCustomItem(cell.ingredient)?.quantityType = type
        self.thisCustomItem(cell.ingredient)?.quantity = type.addQuantity(self.thisCustomItem(cell.ingredient)?.quantity ?? 0)
    }
    
    func valueChangedMilkAdditionSwitch(cell : MilkCustomItemsTableViewCell, added : Bool){
        var ingredient = self.thisCustomItem(cell.ingredient) ?? self.addIngredient(cell.ingredient)
        
        ingredient.enable = added
    }
    
    func valueChangedMilkSegment(cell : MilkCustomItemsTableViewCell, type : MilkType){
        // ミルクの場合、要素そのものが変わるので新たに取得
        // 一部の値を引き継ぐ
        var milk = IngredientManager.instance.milk(type)
        milk.isPartOfOriginalIngredients = cell.ingredient.isPartOfOriginalIngredients
        milk.quantityType = cell.ingredient.quantityType
        milk.unitPrice = (type == .Soy ? milk.unitPrice : 0)
        milk.enable = cell.ingredient.enable
        
        // セルのミルクを変更
        cell.ingredient = milk
        
        // 結果に反映
        for (index, value) in enumerate(self.editResults) {
            if self.editResults[index].type == milk.type {
                self.editResults[index] = milk
                break
            }
        }
    }
    
    func valueChangedMilkQuantitySegment(cell : MilkCustomItemsTableViewCell, type : QuantityType){
        self.thisCustomItem(cell.ingredient)?.quantityType = type
    }

}
