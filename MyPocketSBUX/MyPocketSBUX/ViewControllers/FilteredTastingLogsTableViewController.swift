//
//  FilteredTastingLogsTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/17.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class FilteredTastingLogsTableViewController: TastingLogsBaseTableViewController {
    
    var delegate: FilteredTastingLogsTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didSaveTastingLog(tastingLog: TastingLog) {
        self.delegate?.didSaveTastingLogViaFilteredList(tastingLog)
    }
    
    override func didCancelTastingLog(tastingLog: TastingLog) {
        self.delegate?.didCancelTastingLogViaFilteredList(tastingLog)
    }
    
    override func deleteAction(indexPath: NSIndexPath) {
        var removed = self.tastingLogs.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

        self.delegate?.deleteActionViaFilteredList(removed)
    }

    // MARK: - Table view data source
    
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

protocol FilteredTastingLogsTableViewControllerDelegate {
    func didSaveTastingLogViaFilteredList(tastingLog: TastingLog)
    func didCancelTastingLogViaFilteredList(tastingLog: TastingLog)
    func deleteActionViaFilteredList(tastingLog: TastingLog)
}
