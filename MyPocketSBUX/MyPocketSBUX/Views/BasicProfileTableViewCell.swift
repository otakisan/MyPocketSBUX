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
    private (set) var user : PFUser?
    
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
    
    func configure(user : PFUser?) {
        self.user = user
        self.configureProfilePicture()
        self.configureFollowButton()

        if self.user != nil {
            self.idLabel.text = self.user?.username
        }
        else{
            self.idLabel.text = "(No User Data)"
        }
    }
    
    private func configureFollowButton() {
        self.followButton.setTitle("✔︎ Following", forState: UIControlState.Selected)
        self.followButton.setTitle("+ Follow", forState: UIControlState.Normal)
        
        if let user = self.user, let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "Activity")
            query.whereKey("fromUser", equalTo: currentUser)
            query.whereKey("toUser", equalTo: user)
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
    }
    
    private func configureProfilePicture() {
        if let user = self.user {
            self.profilePictureImageView.file = user["profilePicture"] as? PFFile
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
        if let cellUser = self.user {
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