//
//  BasicProfileTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class BasicProfileTableViewCell: PFTableViewCell {

    @IBOutlet weak var profilePictureImageView: PFImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate : BasicProfileTableViewCellDelegate?
    private (set) var toUser : PFUser?
    private (set) var fromUser : PFUser?
    
    @IBAction func touchUpInsideFollowButton(sender: UIButton) {
        self.shouldToggleFollowFriendForCell()
        self.delegate?.touchUpInsideFollowButton(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(fromUser : PFUser?, toUser : PFUser?) {
        self.fromUser = fromUser
        self.toUser = toUser
        self.configureProfilePicture()
        self.configureFollowButton()

        if self.toUser != nil {
            self.idLabel.text = self.toUser?.username
        }
        else{
            self.idLabel.text = "(No User Data)"
        }
    }
    
    private func configureFollowButton() {
        self.followButton.setTitle("✔︎ Following", forState: UIControlState.Selected)
        self.followButton.setTitle("+ Follow", forState: UIControlState.Normal)
        
        if let toUser = self.toUser, let fromUser = self.fromUser {
            let query = PFQuery(className: activityClassKey)
            query.whereKey(activityTypeKey, equalTo: activityTypeFollow)
            query.whereKey(activityFromUserKey, equalTo: fromUser)
            query.whereKey(activityToUserKey, equalTo: toUser)
            query.findObjectsInBackgroundWithBlock({ (pfObjects, error) -> Void in
                if pfObjects != nil && pfObjects!.count > 0 {
                    self.followButton.selected = true
                }
                else{
                    self.followButton.selected = false
                }
            })
        }
        else{
            self.followButton.enabled = false
        }
        
        // fromUserが自分の場合のときのみ編集可能
        if self.fromUser?.username != PFUser.currentUser()?.username {
            self.followButton.enabled = false
        }
    }
    
    private func configureProfilePicture() {
        if let user = self.toUser {
            self.profilePictureImageView.file = user[userProfilePictureKey] as? PFFile
            self.profilePictureImageView.loadInBackground({ (profilePictureImage, error) -> Void in
                if profilePictureImage == nil {
                    self.profilePictureImageView.backgroundColor = UIColor.lightGrayColor()
                }
                else{
                    self.profilePictureImageView.backgroundColor = UIColor.clearColor()
                }
            })
        }
        else{
            self.profilePictureImageView.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    private func shouldToggleFollowFriendForCell(){
        if let cellUser = self.toUser {
            if self.followButton.selected {
                // Unfollow
                self.followButton.selected = false
                ParseUtility.instance.unfollowUserEventually(cellUser)
                //[[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
            } else {
                // Follow
                self.followButton.selected = true
                ParseUtility.instance.followUserEventually(cellUser, completionBlock: { (succeeded, error) -> Void in
                    if error == nil {
                        //[[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
                    }
                    else{
                        self.followButton.selected = false
                    }
                })
            }
        }
    }

}

protocol BasicProfileTableViewCellDelegate {
    func touchUpInsideFollowButton(cell: BasicProfileTableViewCell)
}