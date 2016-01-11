//
//  ProductDetailTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class ProductDetailTableViewController: UITableViewController {
    
    struct StoryboardConstants {
        static let storyboardName = "Main"
        static let viewControllerIdentifier = "ProductDetailTableViewController"
    }

    var product: NSObject?
    var productPropertyNames: [String] = []
    var nutritions: [Nutrition] = []

    class func forProduct(product : NSObject?) -> ProductDetailTableViewController {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardConstants.viewControllerIdentifier) as! ProductDetailTableViewController
        
        viewController.product = product
        
        return viewController
    }

    func initialize(){
        // 不要なもの（id等）もあり、結局指定する必要がある
        // 栄養情報も必要
        // 季節限定ものは期間も表示する
        //self.productPropertyNames = (product?.propertyNames()) ?? []
        self.productPropertyNames = ["name", "price", "notification", "notes", "special"]
        
        self.nutritions = Nutritions.findByJanCode(self.product?.valueForKey("janCode") as? String ?? "", orderKeys: [])
        
        // TODO: 背景に商品画像を表示 デザインて面で検討の余地あり
        if let image = UIImage(named: self.product?.valueForKey("janCode") as! String) {
            let imageView = UIImageView(image: image)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            self.tableView.backgroundView = imageView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.title = "ProductDetails".localized()
        
        self.initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.nutritions.count == 0 ? 1 : 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return section == 0 ? self.productPropertyNames.count + 1: self.nutritions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(indexPath.section == 0 && indexPath.row == 0 ? "productImagesProductDetailTableViewCell" : "defaultProductDetailTableViewCell", forIndexPath: indexPath) 
        
        // TODO: ひとまず決め打ちで
        if indexPath.section == 0 {
            if indexPath.row == 0 {
            }
            else{
                if let propValue : AnyObject = self.product?.valueForKey(self.productPropertyNames[indexPath.row - 1]) {
                    //                cell.textLabel?.text = self.productPropertyNames[indexPath.row]
                    //                cell.detailTextLabel?.text = "\(propValue)"
                    
                    cell.textLabel?.text = "\(propValue)"
                    cell.detailTextLabel?.text = ""
                }
                else{
                    // Parseでは、undefinedだと、JSON的にいうと、プロパティが存在しない状態になる
                    // なので、値が取得できないこと場合は空を設定する必要がある。
                    // なにも設定しないと、セルが再利用されることに絡んでか、意図したのと別のセクションにデータが表示されたりする
                    cell.textLabel?.text = ""
                    cell.detailTextLabel?.text = ""
                }
            }
        }else if indexPath.section == 1 {
            cell.textLabel?.text = "\(self.nutritions[indexPath.row].liquidTemperature.emptyIfNa()) \(self.nutritions[indexPath.row].size.emptyIfNa()) \(self.nutritions[indexPath.row].milk.emptyIfNa())"
            cell.detailTextLabel?.text = "\(self.nutritions[indexPath.row].calorie)"
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // TODO: 自動計算による高さ調節をしたいところだけどうまく効いてくれていないようなので直接指定
        // カスタムセルクラスの設定が必要なんだろうか
        return indexPath.section == 0 && indexPath.row == 0 ? CGFloat(88.0) : CGFloat(44.0)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? ""/*"Product".localized()*/ : "NutritionFactsCalories".localized()
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
        
        if let vc = segue.destinationViewController as? ProductImageViewController {
            if let indexPath = (sender as? UICollectionView)?.indexPathsForSelectedItems()!.first {
                vc.imageName = self.imageNames()[indexPath.row % self.imageNames().count]
            }
        }
    }
    

}

extension ProductDetailTableViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func imageNames() -> [String] {
        return ["4524785261297", "4524785253186", "4524785243224"]
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        // TODO: 商品画像を別途取得し、その数を返却する
        return 20
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("productImagesCollectionViewCell", forIndexPath: indexPath) as! ProductImagesCollectionViewCell
        cell.productImageView.image = UIImage(named: self.imageNames()[indexPath.row % self.imageNames().count])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showProductImageViewSegue", sender: collectionView)
    }
}
