//
//  CustomItemsStaticTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/18.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class CustomItemsStaticTableViewController: UITableViewController {

    // IngredientCollection
    // 標準構成（変更不可、イニシャライザの実装軽減のため、var）
    //var baseIngredients : DrinkIngredients!
    var baseIngredients : IngredientCollection!
    // カスタムアイテム
    //var customIngredients : DrinkIngredients!
    var customIngredients : IngredientCollection!
    
    subscript (item:Int) -> Int {
        get{
            return 0
        }
        set{
            self[item] = newValue
        }
    }
    
    // 第一引数も明示的に指定
    func paraTest(#arg1 : Int, arg2 : Int) {
        
    }
    
    // 第２引数も省略
    func paraTest2(arg1 : Int, _ : Int) {
        
    }
    
    // カスタム不可のドリンクもあるが、それは呼び出し元で制御する
    // カスタムは、価格の面、と構成の面と個別に考えればシンプルになる。
    
    func calorieForTotal() -> Int {
        // ショット数、シロップ数等、明確なものはそのまま足し算
        // 増量といった曖昧なものは２倍換算する（原則として倍量まで無料というのもある）
        // 各カスタマイズアイテムのカロリーと数量が分かれば計算できる。
        // ただし、ミルクはドリンクによって変化量が異なるので、別途。
        return 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // ステータスバーの高さをの分だけ余白を作る
        let statusBarHeight: CGFloat! = UIApplication.sharedApplication().statusBarFrame.height
        self.tableView.contentInset = UIEdgeInsetsMake(statusBarHeight, 0.0, 0.0, 0.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int){
//        view.backgroundColor = UIColor.redColor()
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        if var header = view as? UITableViewHeaderFooterView {
            header.contentView.opaque = true
            header.contentView.backgroundColor = UIColor.redColor()
        }
        //self.tableView.headerViewForSection(0)?.contentView.backgroundColor = UIColor.redColor()
    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
    // MARK: - Table view data source

    // Static Cellsのため、不要
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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

class IngredientCollection {
    //var ingredientTable : [String : [Ingredients]] = [:]
    var ingredients : [Ingredient] = []
    
    func calorie() -> Int {
        var calorie = 0
        for ingredient in self.ingredients {
            calorie += ingredient.calorie()
        }
        return calorie
    }
    
    func price() -> Int {
        var price = 0
        for ingredient in self.ingredients {
            price += ingredient.price()
        }
        return price
    }
    
    func categorized(type : CustomizationIngredientype) -> [Ingredient] {
        return self.ingredients.filter({$0.type == type})
    }
}

// TODO: データクラスは、コンストラクタ定義まで含め、自動生成したいところ
// 範囲選択した情報を使って、コンストラクタのソースを出力するアドインって作成できないだろうか
class Ingredient : Equatable {
    
    var type : CustomizationIngredientype = .None
    var name : String = ""
    var unitCalorie : Int = 0
    var unitPrice : Int = 0
    var quantity : Int = 0
    var enable : Bool = false
    var quantityType : QuantityType = .Normal
    var isPartOfOriginalIngredients : Bool = false
    
    init(){
        
    }
    
    init(type : CustomizationIngredientype, name : String, unitCalorie : Int, unitPrice : Int, quantity : Int, enable : Bool, quantityType : QuantityType, isPartOfOriginalIngredients : Bool){
        self.type = type
        self.name = name
        self.unitCalorie = unitCalorie
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.enable = enable
        self.quantityType = quantityType
        self.isPartOfOriginalIngredients = isPartOfOriginalIngredients
    }
    
    convenience init(srcIngredient : Ingredient) {
        self.init(type: srcIngredient.type, name: srcIngredient.name, unitCalorie: srcIngredient.unitCalorie, unitPrice: srcIngredient.unitPrice, quantity: srcIngredient.quantity, enable: srcIngredient.enable, quantityType: srcIngredient.quantityType, isPartOfOriginalIngredients: srcIngredient.isPartOfOriginalIngredients)
    }
    
    func overrideQuantity(newQuantity : Int) -> Ingredient {
        
        var newObject = Ingredient(srcIngredient: self)
        newObject.quantity = newQuantity
        return newObject
    }
    
    func price() -> Int {
        return self.unitPrice * self.type.quantityForPrice(self.quantity)
    }
    
    func calorie() -> Int {
        return self.unitCalorie * self.quantity
    }
    
    func clone() -> Ingredient {
        var cloned = Ingredient(srcIngredient: self)
        return cloned
    }
}

func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
    return lhs.name == rhs.name
}

enum CustomizationIngredientype {
    case Coffee
    case Espresso
    case Syrup
    case Sauce
    case WhippedCreamDrink
    case WhippedCreamFood
    case Chip
    case Milk // dairyという呼び名だが、酪農もの以外もあるのでミルクで統一する
    case None
    
    func unitPrice() -> Int {
        var calorie = 0
        switch self {
        case .Coffee, .Espresso, .Syrup, .WhippedCreamDrink, .Chip, .Milk:
            calorie = 50
        default:
            calorie = 0
        }
        
        return calorie
    }
    
    /**
    価格計算用の数量
    */
    func quantityForPrice(quantity : Int) -> Int {
        var quantityToCalcPrice = 0
        
        switch self {
        case .Coffee, .Espresso:
            quantityToCalcPrice = quantity
        case .Syrup, .WhippedCreamDrink, .Chip, .Milk:
            quantityToCalcPrice = max(0, min(1, quantity))
        default:
            // ソースは無料
            quantityToCalcPrice = 0
        }
        
        return quantityToCalcPrice
    }
    
    func name() -> String {
        var nameString = ""
        
        switch self {
        case Coffee:
            nameString = "Coffee"
        case Espresso:
            nameString = "Espresso"
        case Syrup:
            nameString = "Syrup"
        case Sauce:
            nameString = "Sauce"
        case WhippedCreamDrink:
            nameString = "WhippedCreamDrink"
        case WhippedCreamFood:
            nameString = "WhippedCreamFood"
        case Chip:
            nameString = "Chip"
        case Milk: // dairyという呼び名だが、酪農もの以外もあるのでミルクで統一する
            nameString = "Milk"
        case None:
            nameString = "None"
        default:
            nameString = ""
        }
        
        return nameString
    }
}
