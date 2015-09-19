//
//  StoresBaseTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class StoresBaseTableViewController: UITableViewController {

    struct Constants {
        struct Nib {
            static let name = "StoresTableViewCell"
        }
        
        struct TableViewCell {
            static let identifier = "storesTableViewCellIdentifier"
        }
        
        struct TableViewHeaderFooter {
            static let identifier = "storesTableViewHeaderFooterIdentifier"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let nib = UINib(nibName: Constants.Nib.name, bundle: nil)
        
        // Required if our subclasses are to use: dequeueReusableCellWithIdentifier:forIndexPath:
        tableView.registerNib(nib, forCellReuseIdentifier: Constants.TableViewCell.identifier)
        
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: Constants.TableViewHeaderFooter.identifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureCell(cell: UITableViewCell, forStores stores: [[String:AnyObject]]?, indexPath : NSIndexPath) {
        if let entities = stores?[indexPath.section]["stores"] as? [Store] {
            // 将来的には曜日・時間に応じて、営業時間の表示や開店状況を変化させる
            if entities.count > indexPath.row {
                let entity = entities[indexPath.row]
                let storeName = entity.name
                let openTime = DateUtility.localTimeString(entity.openingTimeWeekday)
                let closeTime = DateUtility.localTimeString(entity.closingTimeWeekday)
                
                cell.textLabel?.text = "\(storeName)"
                cell.detailTextLabel?.text = "\(openTime) - \(closeTime)"
            }
        }
    }
    
    func pushStoreDetailViewOnCellSelected(navigationController: UINavigationController, store : Store) {
        
        // Set up the detail view controller to show.
        let detailViewController = StoreDetailTableViewController.forStore(store)
        
        // Note: Should not be necessary but current iOS 8.0 bug requires it.
        self.tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow!, animated: false)
        
        navigationController.pushViewController(detailViewController, animated: true)
    
    }
//    func configureHeaderInSection(tableView: UITableView, viewForHeaderInSection section: Int, forSeminars seminars: [[NSDictionary]]) -> UIView? {
//        var label = UILabel()
//        label.text = seminars[section].first?["edition"] as? NSString
//        label.sizeToFit()
//        label.backgroundColor = UIColor.grayColor()
//        
//        return label
//    }
    
    // MARK: - Table view data source

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
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

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

    // TODO: 【暫定】スワイプでの項目選択
    var selectBySwipe = false
    var delegate : StoresTableViewDelegate?
    // スワイプを有効にする
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.selectBySwipe
    }
    
    // スワイプのため、空の実装が必要
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // スワイプ時に表示する項目
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let editAction =
        UITableViewRowAction(style: .Normal, // 削除等の破壊的な操作を示さないスタイル
            title: "select"){(action, indexPath) in
                print("\(indexPath) selected")
                self.selectAndClose(indexPath)
        }
        editAction.backgroundColor = UIColor.greenColor()
        
        return [editAction]
    }
    
    func selectAndClose(indexPath : NSIndexPath) {
        self.delegate?.selectAndClose(self.storeAtIndexPath(indexPath)!)
        self.closeView()
    }
    
    func storeAtIndexPath(indexPath : NSIndexPath) -> Store? {
        return nil
    }
    
    func closeView(){
        
    }

}
