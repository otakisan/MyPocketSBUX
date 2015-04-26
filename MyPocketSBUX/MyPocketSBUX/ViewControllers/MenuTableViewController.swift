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
        let productCategories = [MenuSectionItem.ProductCategory.drink, MenuSectionItem.ProductCategory.food]
        for productCategory in productCategories {
            let dbContext = self.getDbContext(productCategory)
            var count = dbContext.countByFetchRequestTemplate([NSObject:AnyObject]())
            if count == 0 {
                self.updateProductLocalDb(productCategory, completionHandler: { data, res, error in
                    
                    if var productsJson = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray {
                        dbContext.insertEntityFromJsonObject(productsJson)
                    }
                    
                    // ローカルDBのキャッシュデータを取得
                    self.menuDisplayItemList += self.createProductSectionItemsFromLocalDb(productCategory)
                    
                    //self.stopActivityIndicator()
                    self.reloadData()
                })
            }
            else{
                self.menuDisplayItemList += self.createProductSectionItemsFromLocalDb(productCategory)
            }
        }
    }
    
    func getDbContext(productCategory : String) -> DbContextBase {
        var dbContext : DbContextBase?
        if productCategory == MenuSectionItem.ProductCategory.drink {
            dbContext = Drinks.instance()
        }
        else if productCategory == MenuSectionItem.ProductCategory.food {
            dbContext = Foods.instance()
        }
        else {
            fatalError("invalid productCategory : \(productCategory)")
        }
        
        return dbContext!
    }
    
    func createOrderSectionItem() -> MenuSectionItem {
        var orderSection = MenuSectionItem()
        orderSection.sectionCategory = MenuSectionItem.SectionCategory.order
        
        return orderSection
    }
    
    func createProductSectionItem(productCategory : String, subCategory : String) -> MenuSectionItem {
        var productSection = MenuSectionItem()
        productSection.sectionCategory = MenuSectionItem.SectionCategory.product
        productSection.productCategory = productCategory
        productSection.subCategory = subCategory
        
        return productSection
    }
    
    func updateProductLocalDb(productCategory : String, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?){
        
        // 全件を取得
        if let url  = NSURL(string: "http://\(ResourceContext.instance.serviceHost()):3000/\(productCategory)s.json") {
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task    = session.dataTaskWithURL(url, completionHandler: completionHandler)
            
            task.resume()
        }
    }
    
    func getProductsAllOrderBy(productCategory : String, orderKeys : [(columnName : String, ascending : Bool)]) -> [AnyObject] {
        return self.getDbContext(productCategory).getAllOrderBy(orderKeys)
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
        var entities : [AnyObject] = self.getProductsAllOrderBy(productCategory, orderKeys: [(columnName : "category", ascending : true), (columnName : "name", ascending : true)])
        for entity in entities {
            var menuItem = self.createMenuListItem(productCategory)
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
                        if let index = find(menuDisplayItemList, filtered.first!) {
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
        if var orderViewController = segue.destinationViewController as? OrderTableViewController {
            var orders = self.menuDisplayItemList[0].listItems.map { (m : MenuListItem) -> OrderListItem in
                var orderListItem = OrderListItem()
                orderListItem.productEntity = m.productEntity
                orderListItem.totalPrice = (orderListItem.productEntity?.valueForKey("price") as? NSNumber ?? NSNumber(integer: 0)).integerValue
                orderListItem.on = m.isOnOrderList
                orderListItem.size = .Tall
                orderListItem.hotOrIce = "Hot"
                orderListItem.originalItems = IngredientCollection()
                orderListItem.originalItems?.ingredients = IngredientManager.instance.getAvailableCustomizationChoices(orderListItem.productEntity?.valueForKey("janCode") as? String ?? "").originals
                return orderListItem
            }
            
            orderViewController.orderItems = orders
        }
    }
}
