//
//  FindFriendsTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/15.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class FindFriendsTableViewCell: PFTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    @IBAction func didTapFollowButton(sender: UIButton) {
        self.delegate?.cell(self, didTapFollowButton: self.user)
    }
    
    var user : PFUser!
    var delegate : FindFriendsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.followButton.setTitle("✔︎ Following", forState: UIControlState(rawValue: UIControlState.Disabled.rawValue | UIControlState.Selected.rawValue))
        self.followButton.setTitle("+ Follow", forState: UIControlState.Normal)
        
        // 初期状態ではボタン押下不可
        self.followButton.enabled = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFriend(aUser : PFUser) {
        user = aUser
        self.nameLabel.text = self.user.username
        
        let activityQuery = PFQuery(className: activityClassKey)
        activityQuery.whereKey(activityFromUserKey, equalTo: PFUser.currentUser() ?? PFUser())
        activityQuery.whereKey(activityToUserKey, equalTo: user)
        activityQuery.whereKey(activityTypeKey, equalTo: activityTypeFollow)
        activityQuery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let activities = results {
                if activities.count <= 0 {
                    self.followButton.enabled = true
                    self.followButton.selected = false
                }
                else if self.user[userIsPrivateAccountKey] as? Bool == false {
                    self.followButton.selected = true
                }
                else{
                    // フォローアクションしているため、承認いかんによらず、選択状態とする
                    self.followButton.selected = true
                    
                    let approveQuery = PFQuery(className: activityClassKey)
                    approveQuery.whereKey(activityFromUserKey, equalTo: self.user)
                    approveQuery.whereKey(activityToUserKey, equalTo: PFUser.currentUser() ?? PFUser())
                    approveQuery.whereKey(activityTypeKey, equalTo: activityTypeApprove)
                    approveQuery.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                        if results?.count == 0 {
                            self.followButton.setTitle("- Requested", forState: UIControlState(rawValue: UIControlState.Selected.rawValue | UIControlState.Disabled.rawValue))
                        }
                    })
                }
            }
        }
    }
}

protocol FindFriendsCellDelegate: NSObjectProtocol {
    func cell(cellView: FindFriendsTableViewCell, didTapFollowButton: PFUser)
}
