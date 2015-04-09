//
//  StoreDetailTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class StoreDetailTableViewController: UITableViewController {

    // Constants for Storyboard/ViewControllers
    struct StoryboardConstants {
        static let storyboardName = "Main"
        static let viewControllerIdentifier = "StoreDetailTableViewController"
    }

    // Constants for state restoration.
    struct RestorationKeys {
        static let restoreStore = "restoreStoreKey"
    }

    var store: Store!
    var displayData : [(key:String, value:String)] = []
    
    // MARK: Factory Methods
    
    class func forStore(store: Store) -> StoreDetailTableViewController {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardConstants.viewControllerIdentifier) as! StoreDetailTableViewController
        
        viewController.store = store
        
        return viewController
    }
    
    func initializeDisplayData(){
        self.displayData = [
            ("name", value:self.store.name), (key : "tel", value :self.store.phoneNumber),
            ("address", value:self.store.address), (key : "access", value :self.store.access),
            ("holiday", value:self.store.holiday), (key : "notes", value :self.store.notes)
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.initializeDisplayData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultStoreDetailTableViewCellIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // cell.detailTextLabelのほうだと複数行でも自動調整されない
        cell.textLabel?.text = self.displayData[indexPath.row].value
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.sizeToFit()
        
//        cell.textLabel?.text = self.displayData[indexPath.row].key
//        cell.textLabel?.numberOfLines = 0
//        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
//        cell.detailTextLabel?.text = self.displayData[indexPath.row].value
//        cell.detailTextLabel?.numberOfLines = 0
//        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
//        //cell.detailTextLabel?.font = UIFont(name: "Arial", size: CGFloat(14.0))
//        cell.textLabel?.frame = CGRectMake(0, 0, cell.detailTextLabel?.frame.width ?? 0, cell.detailTextLabel?.frame.height ?? 0)
//        cell.sizeToFit()
//        var maxSize: CGSize = CGSizeMake(self.view.bounds.width,self.view.bounds.height)
//        let size = cell.detailTextLabel?.sizeThatFits(maxSize)
//        cell.frame = CGRectMake(0, 0, size?.width ?? 0, size?.height ?? 0)
//        cell.sizeToFit()

        return cell
    }
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
        // Encode the Store.
        coder.encodeObject(store, forKey: RestorationKeys.restoreStore)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
        // Restore the Store.
        if let decodedStore = coder.decodeObjectForKey(RestorationKeys.restoreStore) as? Store {
            store = decodedStore
            self.initializeDisplayData()
        }
        else {
            fatalError("A Store did not exist. In your app, handle this gracefully.")
        }
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
