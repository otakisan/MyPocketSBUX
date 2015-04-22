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
    
    // カスタムアイテムの計算仕様
    // シロップ、チップ、ホイップと種別ごとに小計を算出し、基本価格（Base Price）に合計する
    // セルの種類は、シロップ・ソース・チップ…という種類ごとでよい？
    // カスタムの要素と数量から、標準構成との差をとり、カスタムメニューの情報を表示する
    func priceForTotal() -> Int {
        // カスタム内容によらず無料のものは除外する
        // ショット、コーヒー、ホイップ、シロップ、チップ、ソイ、期間限定（ジェリー、プリン）
        // 期間限定ものは、それが始まってから随時対応する
        var total = self.priceForEspresso() + self.priceForBrewedCoffee() + self.priceForWhippedCreme() + self.priceForSyrup() + self.priceForChips() + self.priceForMilk()
        
        return total
    }
    
    func priceForMilk() -> Int {
        return self.isSoy() ? 50 : 0
    }
    
    func isSoy() -> Bool {
        return false
    }
    
    func priceForChips() -> Int {
        //
        var baseNumberOfChipTypes = self.baseIngredients.categorized(.Chip).count
        var totalNumberOfChipTypes = self.totalNumberOfChipTypes()
        var addedNumberOfChipTypes = totalNumberOfChipTypes - baseNumberOfChipTypes
        
        // ベース以下のショット数にしても価格は同じ
        var price = max(0, addedNumberOfChipTypes * 50)
        
        return price
    }
    
    func totalNumberOfChipTypes() -> Int {
        // 画面上、選択項目から種類数を算出する
        return 1
    }

    func priceForWhippedCreme() -> Int {
        //
        var baseNumberOfWhippedCreamTypes = self.baseIngredients.categorized(.WhippedCreamDrink).count
        var totalNumberOfWhippedCreamTypes = self.totalNumberOfWhippedCreamTypes()
        var addedNumberOfWhippedCreamTypes = totalNumberOfWhippedCreamTypes - baseNumberOfWhippedCreamTypes
        
        // ベース以下のショット数にしても価格は同じ
        var price = max(0, addedNumberOfWhippedCreamTypes * 50)
        
        return price
    }
    
    func totalNumberOfWhippedCreamTypes() -> Int {
        // 画面上、選択項目から種類数を算出する
        return 1
    }
    
    func priceForBrewedCoffee() -> Int {
        // 1が標準、2が増量
        var baseNumberOfCoffee = self.baseIngredients.categorized(.Coffee).count
        var totalNumberOfCoffee = self.totalNumberOfCoffee()
        var addedNumberOfCoffee = totalNumberOfCoffee - baseNumberOfCoffee
        
        // ベース以下のショット数にしても価格は同じ
        var price = max(0, addedNumberOfCoffee * 50)
        
        return price
    }

    func totalNumberOfCoffee() -> Int {
        return 2
    }
    
    func priceForEspresso() -> Int {
        // ショット数の差分
        var baseNumberOfEspressoShots = self.baseIngredients.categorized(.Espresso).count
        var totalNumberOfEspressoShots = self.totalNumberOfEspressoShots()
        var addedNumberOfEspressoShots = totalNumberOfEspressoShots - baseNumberOfEspressoShots
        
        // ベース以下のショット数にしても価格は同じ
        var price = max(0, addedNumberOfEspressoShots * 50)
        
        return price
    }

    func totalNumberOfEspressoShots() -> Int {
        // 初期表示時に、標準構成でのショット数を表示し、画面上の値がそのまま合計値となるようにする
        return 2
    }
    
    func priceForSyrup() -> Int {
        // シロップの種類から
        var baseNumberOfSyrupTypes = self.baseIngredients.categorized(.Syrup).count
        var totalNumberOfSyrupTypes = self.totalNumberOfSyrupTypes()
        var addedNumberOfSyrupTypes = totalNumberOfSyrupTypes - baseNumberOfSyrupTypes
        
        // ベースが１種類、ノンシロップにしてもマイナスにはならない
        // 変更であれば、差分がゼロになる
        var price = max(0, addedNumberOfSyrupTypes * 50)
        
        return price
    }
    
    func totalNumberOfSyrupTypes() -> Int {
        // 画面上、選択項目から種類数を算出する
        return 3
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
    
    func categorized(type : CustomizationIngredientype) -> [Ingredient] {
        return self.ingredients.filter({$0.type == type})
    }
}

//class DrinkIngredients : IngredientCollection {
//    var numberOfEspressoShots : Int = 0
//    var numberOfCoffee : Int = 0
//    var syrups : [Ingredient] = []
//    var sauces : [Ingredient] = []
//    var chips : [Ingredient] = [] // チョコチップ
//    var whippedCream : [Ingredient] = [] // 通常／チョコ／コーヒー
//}
//
//class FoodIngredients : IngredientCollection{
//    var sauces : [Ingredient] = []
//    var whippedCream : [Ingredient] = [] // 通常／チョコ／コーヒー
//}

// TODO: データクラスは、コンストラクタ定義まで含め、自動生成したいところ
// 範囲選択した情報を使って、コンストラクタのソースを出力するアドインって作成できないだろうか
class Ingredient {
    
    var type : CustomizationIngredientype = .None
    var name : String = ""
    var unitCalorie : Int = 0
    var unitPrice : Int = 0
    var quantity : Int = 0
    
    init(){
        
    }
    
    init(type : CustomizationIngredientype, name : String, unitCalorie : Int, unitPrice : Int, quantity : Int){
        self.type = type
        self.name = name
        self.unitCalorie = unitCalorie
        self.unitPrice = unitPrice
        self.quantity = quantity
    }
    
    convenience init(srcIngredient : Ingredient) {
        self.init(type: srcIngredient.type, name: srcIngredient.name, unitCalorie: srcIngredient.unitCalorie, unitPrice: srcIngredient.unitPrice, quantity: srcIngredient.quantity)
    }
    
    func overrideQuantity(newQuantity : Int) -> Ingredient {
        
        var newObject = Ingredient(srcIngredient: self)
        newObject.quantity = newQuantity
        return newObject
    }
    
    func calorie() -> Int {
        return self.unitPrice * self.quantity
    }
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
    
}
