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
        
        self.followButton.setTitle("✔︎ Following", forState: UIControlState.Selected)
        self.followButton.setTitle("+ Follow", forState: UIControlState.Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFriend(aUser : PFUser) {
        user = aUser
        self.nameLabel.text = self.user.username
    }
}

protocol FindFriendsCellDelegate: NSObjectProtocol {
    func cell(cellView: FindFriendsTableViewCell, didTapFollowButton: PFUser)
}
