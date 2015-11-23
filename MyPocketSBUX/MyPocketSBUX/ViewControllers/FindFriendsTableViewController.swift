//
//  FindFriendsTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/15.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class FindFriendsTableViewController: PFQueryTableViewController, FindFriendsCellDelegate {
    
    struct Constants {
        struct Nib {
            static let name = "FindFriendsTableViewCell"
        }
        
        struct TableViewCell {
            static let identifier = "findFriendsTableViewCellIndetifier"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // ストーリーボードとは別のxibファイルに存在するから必要だと思われる
        let nib = UINib(nibName: Constants.Nib.name, bundle: nil)
        // Required if our subclasses are to use: dequeueReusableCellWithIdentifier:forIndexPath:
        tableView.registerNib(nib, forCellReuseIdentifier: Constants.TableViewCell.identifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Initialise the PFQueryTable tableview
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // *******
        // Configure the PFQueryTableView
        
        // PFObject/PFUser等のエンティティクラス
        self.parseClassName = "PFObject"
        
        // 一覧に並べる際に、キーとみなす項目。重複があると異常終了する
        self.textKey = "username"
        
        self.pullToRefreshEnabled = true
        
        // trueにすると、一覧の最下セルにLoad moreが出る（日本語設定でも英語のまま）
        self.paginationEnabled = true
    }
    
    override func queryForTable() -> PFQuery {
        var query : PFQuery = PFQuery()
        if IdentityContext.sharedInstance.signedIn(), let currentUser = PFUser.currentUser() {
            // TODO: 一旦取得しなくても済む方法はある？
            let activityQuery = PFQuery(className: "Activity")
            activityQuery.includeKey("toUser")
            activityQuery.whereKey("fromUser", equalTo: currentUser)
            if let objects = try? activityQuery.findObjects() {
                let toUserObjectIds : [String] = objects.reduce([], combine: { (var ids, activity) -> [String] in
                    ids += [activity["toUser"].objectId ?? ""]
                    return ids
                })
                
                query = PFUser.query()!
                // TODO: ログインユーザーとすでにフォローが完了しているユーザーを除去する
                query.whereKey("username", notEqualTo: currentUser.username ?? "")
                query.whereKey("objectId", notContainedIn: toUserObjectIds)
                query.orderByDescending("createdAt")
            }
        }
        
        //let query = PFUser.query()!
        
        // If no objects are loaded in memory, we look to the cache
        // first to fill the table and then subsequently do a query
        // against the network.
        // 下の設定を行うと、２回目以降の実行で異常終了するため実行しない
//        if (self.objects?.count ?? 0 == 0) {
//            query.cachePolicy = PFCachePolicy.CacheThenNetwork;
//        }
        

        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        // TODO: PFTableViewCellのメリットは？
        //var cell = tableView.dequeueReusableCellWithIdentifier("FindFriendsTableViewCell") as! PFTableViewCell!
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) as! FindFriendsTableViewCell
        if let user = object as? PFUser {
            cell.delegate = self
            cell.setFriend(user)
        }

        return cell
    }
    
    func cell(cellView: FindFriendsTableViewCell, didTapFollowButton: PFUser){
        self.shouldToggleFollowFriendForCell(cellView)
    }
    
    private func shouldToggleFollowFriendForCell(cell : FindFriendsTableViewCell) {
        let cellUser = cell.user;
        if cell.followButton.selected {
            // Unfollow
            cell.followButton.selected = false
            ParseUtility.instance.unfollowUserEventually(cellUser)
            //[[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
        } else {
            // Follow
            cell.followButton.selected = true
            ParseUtility.instance.followUserEventually(cellUser, completionBlock: { (succeeded, error) -> Void in
                if error == nil {
                    //[[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
                }
                else{
                    cell.followButton.selected = false
                }
            })
        }
    }


//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("FindFriendsTableViewCell", forIndexPath: indexPath) as! FindFriendsTableViewCell
//        if let pfobject = self.objectAtIndexPath(indexPath) {
//            cell.nameLabel.text = pfobject["username"] as? String
//        }
//        
//        return cell
//    }
    // MARK: - Table view data source

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
