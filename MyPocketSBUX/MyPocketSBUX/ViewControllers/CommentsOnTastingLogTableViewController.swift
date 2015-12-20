//
//  CommentsOnTastingLogTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/13.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class CommentsOnTastingLogTableViewController: PFQueryTableViewController {
    
    var commentsTableDelegate : CommentsOnTastingLogTableViewDelegate?

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

    override func queryForTable() -> PFQuery {
        let tastingLogQuery = PFQuery(className: tastingLogClassKey)
        tastingLogQuery.whereKey(tastingLogIdKey, equalTo: self.commentsTableDelegate?.idOfTastingLog() ?? 0)
        
        let activityQuery = PFQuery(className: activityClassKey)
        activityQuery.whereKey(activityTypeKey, equalTo: activityTypeComment)
        activityQuery.whereKey(activityTastingLogKey, matchesQuery: tastingLogQuery)
        activityQuery.includeKey(activityFromUserKey)
        activityQuery.includeKey(activityToUserKey)
        
        return activityQuery
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        self.commentsTableDelegate = parent as? CommentsOnTastingLogTableViewDelegate
        self.loadObjects()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultCommentsOnTastingLogTableViewCell", forIndexPath: indexPath)

        // Configure the cell...
        if let pfObject = self.objects?[indexPath.row] as? PFObject {
            cell.textLabel?.text = (pfObject[activityFromUserKey] as? PFUser)?.username
            cell.detailTextLabel?.text = (pfObject[activityContentKey] as? String)
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        var editable = false
        if let pfObject = self.objects?[indexPath.row] as? PFObject, let currentUser = PFUser.currentUser() {
            editable = (pfObject[activityFromUserKey] as? PFUser)?.username == currentUser.username || (pfObject[activityToUserKey] as? PFUser)?.username == currentUser.username
        }
        return editable
    }
    
    // スワイプのため、空の実装が必要
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // スワイプ時に表示する項目
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") {(action, indexPath) in
            self.showAlertThenDeleteComment(indexPath)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction]
    }

    func showAlertThenDeleteComment(indexPath : NSIndexPath) {
        let alertController = UIAlertController(title: "Delete ?", message: "", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) {
            action in self.deleteComment(indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            action in
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func deleteComment(indexPath : NSIndexPath) {
        let commentRemoved = self.objects?[indexPath.row][activityContentKey] as? String ?? ""
        self.removeObjectAtIndexPath(indexPath, animated: true)
        self.commentsTableDelegate?.didDeleteComment(commentRemoved)
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol CommentsOnTastingLogTableViewDelegate {
    func idOfTastingLog() -> Int
    func didDeleteComment(comment : String)
}