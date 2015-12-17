//
//  FollowingTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class FollowingTableViewController: PFQueryTableViewController, BasicProfileTableViewCellDelegate {

    struct Constants {
        struct Nib {
            static let name = "BasicProfileTableViewCell"
        }
        
        struct TableViewCell {
            static let identifier = "basicProfileTableViewCellIdentifier"
        }
    }
    
    var user : PFUser?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let nib = UINib(nibName: Constants.Nib.name, bundle: nil)
        
        // Required if our subclasses are to use: dequeueReusableCellWithIdentifier:forIndexPath:
        tableView.registerNib(nib, forCellReuseIdentifier: Constants.TableViewCell.identifier)
        
        self.navigationItem.title = "Following"
        
        // TODO: 一旦、未指定時のデフォルトをログインユーザーとする
        if self.user == nil {
            self.user = PFUser.currentUser()
        }
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
        
        // 公開と非公開でor検索
        // 公開ユーザー
        let publicToUserQuery = PFQuery(className: activityClassKey)
        publicToUserQuery.whereKey(activityFromUserKey, equalTo: self.user ?? PFUser())
        publicToUserQuery.whereKey(activityTypeKey, equalTo: activityTypeFollow)
        
        let publicUser = PFUser.query()!
        publicUser.whereKey(userUsernameKey, notEqualTo: self.user?.username ?? "")
        publicUser.whereKey(userIsPrivateAccountKey, equalTo: false)
        publicToUserQuery.whereKey(activityToUserKey, matchesQuery: publicUser)

        // 非公開ユーザー
        let privateToUserQuery = PFQuery(className: activityClassKey)
        privateToUserQuery.whereKey(activityFromUserKey, equalTo: self.user ?? PFUser())
        privateToUserQuery.whereKey(activityTypeKey, equalTo: activityTypeFollow)
        
        let approveQuery = PFQuery(className: activityClassKey)
        approveQuery.whereKey(activityToUserKey, equalTo: self.user ?? PFUser())
        approveQuery.whereKey(activityTypeKey, equalTo: activityTypeApprove)
        privateToUserQuery.whereKey(activityToUserKey, matchesKey: activityFromUserKey, inQuery: approveQuery)
        
        let privateUser = PFUser.query()!
        privateUser.whereKey(userUsernameKey, notEqualTo: self.user?.username ?? "")
        privateUser.whereKey(userIsPrivateAccountKey, equalTo: true)
        privateToUserQuery.whereKey(activityToUserKey, matchesQuery: privateUser)
        
        // or検索
        let query = PFQuery.orQueryWithSubqueries([publicToUserQuery, privateToUserQuery])
        query.includeKey(activityToUserKey)
        query.includeKey(activityFromUserKey)

        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) as! BasicProfileTableViewCell
        
        cell.configure(self.user, toUser: object?[activityToUserKey] as? PFUser)
        cell.delegate = self
        
        return cell
    }
    
    func touchUpInsideFollowButton(cell: BasicProfileTableViewCell) {
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let selectedPFObject = self.objectAtIndexPath(indexPath), let toUser = selectedPFObject[activityToUserKey] as? PFUser {
            let detailViewController = ProfileTableViewController.forUser(toUser)
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
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
