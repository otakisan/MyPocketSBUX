//
//  FollowRequestsTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/12.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class FollowRequestsTableViewController: PFQueryTableViewController {

    struct Constants {
        struct Nib {
            static let name = "FollowRequestsTableViewCell"
        }
        
        struct TableViewCell {
            static let identifier = "followRequestsTableViewCellIdentifier"
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
        
        self.navigationItem.title = "FollowRequests".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: activityClassKey)
        query.includeKey(activityFromUserKey)
        query.whereKey(activityToUserKey, equalTo: PFUser.currentUser() ?? PFUser())
        query.whereKey(activityTypeKey, equalTo: activityTypeFollow)
        
        let noActivityQuery = PFQuery(className: activityClassKey)
        noActivityQuery.whereKey(activityFromUserKey, equalTo: PFUser.currentUser() ?? PFUser())
        noActivityQuery.whereKey(activityTypeKey, containedIn: [activityTypeApprove, activityTypeDeny])
        
        query.whereKey(activityFromUserKey, doesNotMatchKey: activityToUserKey, inQuery: noActivityQuery)
        
        return query
    }
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) as! FollowRequestsTableViewCell
        
        if let user = object?[activityFromUserKey] as? PFUser {
            cell.configure(user)
        }
        
        return cell
    }

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
