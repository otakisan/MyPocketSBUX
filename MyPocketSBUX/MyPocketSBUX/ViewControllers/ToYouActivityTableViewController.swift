//
//  ToYouActivityTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/21.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ToYouActivityTableViewController: PFQueryTableViewController {

    struct Constants {
        struct Nib {
            static let name = "FindFriendsTableViewCell"
        }
        
        struct TableViewCell {
            static let identifier = "toYouActivityTableViewCellIndetifier"
        }
    }

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

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // *******
        // Configure the PFQueryTableView
        
        // PFObject/PFUser等のエンティティクラス
        self.parseClassName = "PFObject"
        
        // 一覧に並べる際に、キーとみなす項目。重複があると異常終了する
        //self.textKey = "username"
        
        self.pullToRefreshEnabled = true
        
        // trueにすると、一覧の最下セルにLoad moreが出る（日本語設定でも英語のまま）
        self.paginationEnabled = true
    }
    
    override func queryForTable() -> PFQuery {
        var query = PFQuery()
        if let currentUser = PFUser.currentUser() {
            query = PFQuery(className: activityClassKey)
            query.includeKey(activityToUserKey)
            query.includeKey(activityFromUserKey)
            query.whereKey(activityToUserKey, equalTo: currentUser)
            
            // 非公開アカウントにしている場合は、承認したユーザーのアクティビティのみ表示
            if currentUser[userIsPrivateAccountKey] as? Bool == true {
                let approvedQuery = PFQuery(className: activityClassKey)
                approvedQuery.whereKey(activityTypeKey, equalTo: activityTypeApprove)
                approvedQuery.whereKey(activityFromUserKey, equalTo: currentUser)
                query.whereKey(activityFromUserKey, matchesKey: activityToUserKey, inQuery: approvedQuery)
            }
        }
        
        return query
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath)
        
        if let results = self.objects as? [PFObject] {
            cell.textLabel?.text = "\((results[indexPath.row][activityFromUserKey] as? PFUser)?.username ?? "") \((results[indexPath.row][activityTypeKey] as? String ?? "")) your log."
        }
        
        return cell
    }

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
