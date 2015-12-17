//
//  ProfileTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/22.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse

class ProfileTableViewController: UITableViewController {
    
    var user : PFUser?
    private(set) var isPrivateAccount = true

    struct Constants {
        struct Storyboard {
            static let storyboardName = "Main"
            static let viewControllerIdentifier = "ProfileTableViewController"
        }
    }

    class func forUser(user : PFUser?) -> ProfileTableViewController {
        let storyboard = UIStoryboard(name: Constants.Storyboard.storyboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Constants.Storyboard.viewControllerIdentifier) as! ProfileTableViewController
        
        viewController.user = user
        
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if self.user == nil {
            self.user = PFUser.currentUser()
        }
        
        self.navigationItem.title = self.user?.username
        
        self.setIsPrivateAccount()
        //self.changeCellSelectionStyle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let logsVC = segue.destinationViewController as? TastingLogsCollectionViewController {
            logsVC.user = self.user
        } else if let editProfileVC = segue.destinationViewController as? EditProfileTableViewController {
            editProfileVC.user = self.user
        } else if let followersVC = segue.destinationViewController as? FollowersTableViewController {
            followersVC.user = self.user
        } else if let followingVC = segue.destinationViewController as? FollowingTableViewController {
            followingVC.user = self.user
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return !(["tastingLogsCollectionViewControllerSegue", "followerTableViewControllerSegue", "followingTableViewControllerSegue", "editProfileTableViewControllerSegue"].contains(identifier) && self.isPrivateAccount)
    }
    
    private func setIsPrivateAccount() {
        if let currentUser = PFUser.currentUser(), let targetUser = self.user, let isPrivateAccount = currentUser[userIsPrivateAccountKey] as? Bool {
            if currentUser.username == targetUser.username || !isPrivateAccount {
                // 自分自身もしくは公開アカウント
                // 閲覧を有効化
                self.isPrivateAccount = false
            }
            else {
                // プロフィール閲覧の対象ユーザーをフォローしているか（非同期通信の結果で切り分け）
                ParseUtility.instance.isFollowerInBackgroundWithBlock(currentUser, target: targetUser, block: { (results, error) -> Void in
                    if error == nil, let activities = results where activities.count > 0 {
                        self.isPrivateAccount = false
                    } else {
                        self.isPrivateAccount = true
                    }
                })
            }
        } else {
            // 判定に必要な情報が取得できない場合は、参照不可
            self.isPrivateAccount = true
        }
    }
    
    private func changeCellSelectionStyle() {
        if let currentUser = PFUser.currentUser(), let targetUser = self.user, let isPrivateAccount = currentUser[userIsPrivateAccountKey] as? Bool {
            if currentUser.username == targetUser.username || !isPrivateAccount {
                // 自分自身もしくは公開アカウント
                // 閲覧を有効化
                self.changeCellSelectionStyleOfPrivateInfos(.Default)
            }
            else {
                // プロフィール閲覧の対象ユーザーをフォローしているか（非同期通信の結果で切り分け）
                ParseUtility.instance.isFollowerInBackgroundWithBlock(currentUser, target: targetUser, block: { (results, error) -> Void in
                    if error == nil, let activities = results where activities.count > 0 {
                        self.changeCellSelectionStyleOfPrivateInfos(.Default)
                    } else {
                        self.changeCellSelectionStyleOfPrivateInfos(.None)
                    }
                })
            }
        } else {
            // 判定に必要な情報が取得できない場合は、参照不可
            self.changeCellSelectionStyleOfPrivateInfos(.None)
        }
    }
    
    private func changeCellSelectionStyleOfPrivateInfos(selectionStyle : UITableViewCellSelectionStyle) {
        for index in 0...3 {
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))?.selectionStyle = selectionStyle
        }
    }

}
