//
//  TastingLogsBaseTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/17.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TastingLogsBaseTableViewController: UITableViewController, TastingLogEditorTableViewControllerDelegate {

    struct Constants {
        struct Nib {
            static let name = "TastingLogsTableViewCell"
        }
        
        struct TableViewCell {
            static let identifier = "tastingLogsTableViewCellIdentifier"
        }
    }

    var tastingLogs : [TastingLog] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // TODO: ひとまず標準のTableViewCellを使う
        let nib = UINib(nibName: Constants.Nib.name, bundle: nil)
        
        // Required if our subclasses are to use: dequeueReusableCellWithIdentifier:forIndexPath:
        tableView.registerNib(nib, forCellReuseIdentifier: Constants.TableViewCell.identifier)

        self.intializeRefreshControl()
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
        return self.tastingLogs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) as! UITableViewCell
        
        // Configure the cell...
        cell.textLabel?.text = self.tastingLogs[indexPath.row].title
        cell.detailTextLabel?.text = "\(DateUtility.localDateString(self.tastingLogs[indexPath.row].tastingAt))@\(self.tastingLogs[indexPath.row].store?.name ?? String())"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.pushTastingLogDetailViewOnCellSelected(self.tastingLogs[indexPath.row])
    }

    func pushTastingLogDetailViewOnCellSelected(tastingLog : TastingLog) {
        
        // Set up the detail view controller to show.
        var detailViewController = TastingLogEditorTableViewController.forTastingLog(tastingLog)
        detailViewController.delegate = self
        
        // Note: Should not be necessary but current iOS 8.0 bug requires it.
        self.tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
        
        self.presentViewController(detailViewController, animated: true, completion: nil)
    }
    
    func didSaveTastingLog(tastingLog: TastingLog){
        
    }
    
    func didCancelTastingLog(tastingLog: TastingLog){
        
    }

    // スワイプで編集メニューの表示を有効にする
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // スワイプのため、空の実装が必要
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // スワイプ時に表示する項目
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "delete") {
            (action, indexPath) in self.deleteAction(indexPath)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction]
    }
    
    func deleteAction(indexPath : NSIndexPath) {
    }

    func intializeRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh() {
    }
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
