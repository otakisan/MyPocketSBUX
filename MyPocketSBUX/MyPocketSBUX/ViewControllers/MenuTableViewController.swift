//
//  MenuTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController, MenuListItemTableViewCellDelegate {
    
    private struct CellIdentifiers {
        static let order = "orderMenuListItemCell"
        static let drink = "drinkMenuListItemCell"
        static let food = "foodMenuListItemCell"
    }
    
    var menuDisplayItemList : [MenuSectionItem] = []

    func initializeProductData(){
        
        self.menuDisplayItemList = [self.createOrderSectionItem()]
        
        // ローカルDBにデータが存在するかどうかチェックしなければ、取得
        // 存在すれば、DBから取得して、一覧表示へ
        // TODO: ３種類のデータを非同期で取得するため、すべてのデータ取得処理が完了したらUIを更新するという処理が必要
        // dispatch_group_t = dispatch_group_create() -> 通信部分で非同期になってしまうため不採用
        // 同期的にセマフォを取得し、UI更新起動用のスレッドで待機に入る。
        // 通信完了後の非同期部分で解放し、すべて完了されたらUI更新起動用スレッドが開始、reloadDataを起動する
        let productCategories = [MenuSectionItem.ProductCategory.drink, MenuSectionItem.ProductCategory.food]
        let semaphoreCount = productCategories.count
        let semaphore = dispatch_semaphore_create(semaphoreCount)
        let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(ContentsManager.instance.timeoutInSeconds * Double(NSEC_PER_SEC)))
        for productCategory in productCategories {
            dispatch_semaphore_wait(semaphore, timeout/*DISPATCH_TIME_FOREVER*/)
            let dbContext = ContentsManager.instance.getDbContext(productCategory)
            let count = dbContext.countByFetchRequestTemplate([String:AnyObject]())
            if count == 0 {
                MenuManager.instance.updateProductLocalDb(productCategory, completionHandler: { (error) -> Void in
                    if error == nil {
                        // ローカルDBのキャッシュデータを取得
                        self.menuDisplayItemList += self.createProductSectionItemsFromLocalDb(productCategory)
                    }
                    
                    // 解放
                    dispatch_semaphore_signal(semaphore)
                })
            }
            else{
                self.menuDisplayItemList += self.createProductSectionItemsFromLocalDb(productCategory)
                
                // 解放
                dispatch_semaphore_signal(semaphore)
            }
        }
        
        // カロリー
        // 商品情報の取得が完了するまで待機して、メニューリストを更新、UIを更新する
        if 0 == Nutritions.instance().countByFetchRequestTemplate([String:AnyObject]()) {
            MenuManager.instance.updateProductLocalDb("nutrition", completionHandler: { (error) -> Void in
                // メニューリストを更新（カロリー情報）
                self.waitAndUpdateCalorie(semaphore, semaphoreCount: semaphoreCount, timeout: timeout)
                
                // UIを更新
                //self.stopActivityIndicator()
                self.reloadData()
            })
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                self.waitAndUpdateCalorie(semaphore, semaphoreCount: semaphoreCount, timeout: timeout)
               
                self.reloadData()
            })
        }
    }
    
    func waitAndUpdateCalorie(semaphore : dispatch_semaphore_t, semaphoreCount : Int, timeout: dispatch_time_t) {
        // 待機
        for _ in 0..<semaphoreCount {
            dispatch_semaphore_wait(semaphore, timeout/*DISPATCH_TIME_FOREVER*/)
        }
        // 解放しないとアベンドする
        for _ in 0..<semaphoreCount {
            dispatch_semaphore_signal(semaphore)
        }
        
        // メニューリスト
        for menu in self.menuDisplayItemList {
            for menuListItems in menu.listItems {
                // 商品のJANコードに紐づく栄養情報を取得（複数）
                menuListItems.nutritionEntities = Nutritions.findByJanCode(
                    menuListItems.productEntity?.valueForKey("janCode") as? String ?? "",
                    orderKeys: [(columnName:"liquidTemperature", ascending: true), (columnName:"milk", ascending: true), (columnName:"size", ascending: true)]
                )
            }
        }
    }
    
    func createOrderSectionItem() -> MenuSectionItem {
        let orderSection = MenuSectionItem()
        orderSection.sectionCategory = MenuSectionItem.SectionCategory.order
        
        return orderSection
    }
    
    func createProductSectionItem(productCategory : String, subCategory : String) -> MenuSectionItem {
        let productSection = MenuSectionItem()
        productSection.sectionCategory = MenuSectionItem.SectionCategory.product
        productSection.productCategory = productCategory
        productSection.subCategory = subCategory
        
        return productSection
    }
    
    func updateProductLocalDb(productCategory : String, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)){
        
        // 全件を取得
        if let url  = NSURL(string: "http://\(ResourceContext.instance.serviceHost()):3000/\(productCategory)s.json") {
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task    = session.dataTaskWithURL(url, completionHandler: completionHandler)
            
            task.resume()
        }
    }
    
    func getProductsAllOrderBy(productCategory : String, orderKeys : [(columnName : String, ascending : Bool)]) -> [AnyObject] {
        return ContentsManager.instance.getDbContext(productCategory).getAllOrderBy(orderKeys)
    }
    
    func createMenuListItem(productCategory : String) -> MenuListItem {
        var menuListItem : MenuListItem?
        if productCategory == MenuSectionItem.ProductCategory.drink {
            menuListItem = DrinkMenuListItem()
        }
        else if productCategory == MenuSectionItem.ProductCategory.food {
            menuListItem = FoodMenuListItem()
        }
        else{
            menuListItem = MenuListItem()
        }
        
        return menuListItem!
    }
    
    func createProductSectionItemsFromLocalDb(productCategory : String) -> [MenuSectionItem] {
        
        var results : [MenuSectionItem] = []
        var prevSectionItem : MenuSectionItem?
        let entities : [AnyObject] = self.getProductsAllOrderBy(productCategory, orderKeys: [(columnName : "category", ascending : true), (columnName : "name", ascending : true)])
        for entity in entities {
            let menuItem = self.createMenuListItem(productCategory)
            menuItem.productEntity = entity
            
            if !(prevSectionItem?.subCategory == entity.category) {
                prevSectionItem = createProductSectionItem(productCategory, subCategory: (entity.valueForKey("category") as? String)!)
                results += [prevSectionItem!]
            }
            
            // TODO: セクションカテゴリをprevSectionItemの値で設定したほうがよいか
            
            prevSectionItem!.listItems += [menuItem]
        }
        
        return results
    }
    
    func getCell(indexPath : NSIndexPath) -> UITableViewCell {
        let menuListItem = self.menuDisplayItemList[indexPath.section].listItems[indexPath.row]
        let reuseId = self.getCellReuseId(menuListItem)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: indexPath) as! MenuListItemTableViewCell
        cell.configure(menuListItem)
        cell.delegate = self
        
        return cell
    }
    
    func getCellReuseId(menuListItem : MenuListItem) -> String {
        let sectionCategory = menuListItem.sectionCategory()
        let productCategory = menuListItem.productCategory()
        
        var reuseId = ""
        if sectionCategory == MenuSectionItem.SectionCategory.order {
            reuseId = CellIdentifiers.order
        }
        else if sectionCategory == MenuSectionItem.SectionCategory.product {
            if productCategory == MenuSectionItem.ProductCategory.drink {
                reuseId = CellIdentifiers.drink
            }
            else if productCategory == MenuSectionItem.ProductCategory.food {
                reuseId = CellIdentifiers.food
            }
        }
        
        return reuseId
    }
    
    func valueChangedOrderSwitch(cell : MenuListItemTableViewCell, on : Bool){
        
        if let fromIndexPath = tableView.indexPathForCell(cell) {

            // データリストをまず編集
            if let menuListItemOrderValueChanged = cell.menuListItem {
                
                var toSectionIndex : Int = -1
                let filtered = self.menuDisplayItemList.filter {
                    $0.sectionCategory == menuListItemOrderValueChanged.sectionCategory()
                        && $0.productCategory == menuListItemOrderValueChanged.productCategory()
                        && $0.subCategory == menuListItemOrderValueChanged.subCategory()
                }
                
                // オーダーセクションはインデックス：0固定の前提
                if on {
                    if filtered.count == 1 {
                        let removed = self.menuDisplayItemList[fromIndexPath.section].listItems.removeAtIndex(fromIndexPath.row)
                        self.menuDisplayItemList[0].listItems += [removed]
                        toSectionIndex = 0
                    }
                    else if filtered.count > 1 {
                        fatalError("duplicate section item")
                    }
                    else {
                        fatalError("section item not found")
                    }
                }
                    // オーダーセクション以外でも、OFFでイベント発生することもあるので…
                    // Onにドラッグしたまま離さず、Offに戻して離せば、元々Offの状態からOffのイベントを発生させられる
                else if fromIndexPath.section == 0 {
                    if filtered.count == 1 {
                        let removed = self.menuDisplayItemList[0].listItems.removeAtIndex(fromIndexPath.row)
                        filtered.first!.listItems += [removed]
                        if let index = menuDisplayItemList.indexOf(filtered.first!) {
                            toSectionIndex = index
                        }
                    }
                    else if filtered.count > 1 {
                        fatalError("duplicate section item")
                    }
                    else {
                        fatalError("section item not found")
                    }
                }
            
                //
                if toSectionIndex >= 0 {
                    let toIndexPath = NSIndexPath(forRow: self.menuDisplayItemList[toSectionIndex].listItems.count - 1, inSection: toSectionIndex)
                    tableView.beginUpdates()
                    self.moveCell(fromIndexPath, toIndexPath: toIndexPath)
                    tableView.endUpdates()
                }
            }
        }
    }
    
    func moveCell(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        if indexPath.section == newIndexPath.section {
            self.tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
        }
        else{
            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.estimatedRowHeight = 45
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.initializeProductData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.menuDisplayItemList.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.menuDisplayItemList[section].listItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(indexPath)

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.menuDisplayItemList[section].sectionName
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
        // TODO: オーダーからメニューに戻り、商品を追加して、またオーダーに戻る仕組み
        // カートみたいなものが独立して存在するようにさせるか
        // 今だと戻るとリセットされてしまう
        // TODO: 過去のオーダーをもとに参照新規する機能
        if let orderViewController = segue.destinationViewController as? OrderTableViewController {
            let orders = self.menuDisplayItemList[0].listItems.map { (m : MenuListItem) -> OrderListItem in
                let orderListItem = OrderListItem()
                orderListItem.productEntity = m.productEntity
                orderListItem.totalPrice = (orderListItem.productEntity?.valueForKey("price") as? NSNumber ?? NSNumber(integer: 0)).integerValue
                orderListItem.on = m.isOnOrderList
                orderListItem.size = .Tall
                orderListItem.hotOrIce = (orderListItem.productEntity?.valueForKey("category") as? String == "frappuccino") ? "Iced" : "Hot"
                orderListItem.originalItems = IngredientCollection()
                orderListItem.originalItems?.ingredients = IngredientManager.instance.getAvailableCustomizationChoices(orderListItem.productEntity?.valueForKey("janCode") as? String ?? "").originals
                orderListItem.nutritionEntities = m.nutritionEntities
                return orderListItem
            }
            
            orderViewController.orderItems = orders
        }
        else if let productDetailViewController = segue.destinationViewController as? ProductDetailTableViewController {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                productDetailViewController.product = self.menuDisplayItemList[indexPath.section].listItems[indexPath.row].productEntity as? NSObject
            }
        }
    }
}
