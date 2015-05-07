//
//  ProductDetailTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class ProductDetailTableViewController: UITableViewController {
    
    var product: NSObject?
    var productPropertyNames: [String] = []
    var nutritions: [Nutrition] = []

    func initialize(){
        // 不要なもの（id等）もあり、結局指定する必要がある
        // 栄養情報も必要
        // 季節限定ものは期間も表示する
        //self.productPropertyNames = (product?.propertyNames()) ?? []
        self.productPropertyNames = ["name", "price", "notification", "notes", "special"]
        
        self.nutritions = Nutritions.findByJanCode(self.product?.valueForKey("janCode") as? String ?? "", orderKeys: [])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return section == 0 ? self.productPropertyNames.count : self.nutritions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultProductDetailTableViewCell", forIndexPath: indexPath) as! UITableViewCell

        // TODO: ひとまず決め打ちで
        if indexPath.section == 0 {
            if let propValue : AnyObject = self.product?.valueForKey(self.productPropertyNames[indexPath.row]) {
//                cell.textLabel?.text = self.productPropertyNames[indexPath.row]
//                cell.detailTextLabel?.text = "\(propValue)"
                
                cell.textLabel?.text = "\(propValue)"
                cell.detailTextLabel?.text = ""
            }
        }else if indexPath.section == 1 {
            let na = "na"
            cell.textLabel?.text = "\(self.nutritions[indexPath.row].liquidTemperature.emptyIfNa()) \(self.nutritions[indexPath.row].size.emptyIfNa()) \(self.nutritions[indexPath.row].milk.emptyIfNa())"
            cell.detailTextLabel?.text = "\(self.nutritions[indexPath.row].calorie)"
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Product" : "Nutrition Facts (Calories)"
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

//import Foundation

extension NSObject {
    
    //
    // Retrieves an array of property names found on the current object
    // using Objective-C runtime functions for introspection:
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
    //
    func propertyNames() -> [String] {
        var results: [String] = [];
        
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0;
        var myClass: AnyClass = self.classForCoder;
        var properties = class_copyPropertyList(myClass, &count);
        
        // iterate each objc_property_t struct
        for var i: UInt32 = 0; i < count; i++ {
            var property = properties[Int(i)];
            
            // retrieve the property name by calling property_getName function
            var cname = property_getName(property);
            
            // covert the c string into a Swift string
            var name = String.fromCString(cname);
            results.append(name!);
        }
        
        // release objc_property_t structs
        free(properties);
        
        return results;
    }
    
}