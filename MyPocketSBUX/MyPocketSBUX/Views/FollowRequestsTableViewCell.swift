//
//  FollowRequestsTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/12.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class FollowRequestsTableViewCell: PFTableViewCell {
    
    var followApplicant : PFUser?

    @IBOutlet weak var profilePictureImageView: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var approveButton: UIButton!
    
    @IBAction func touchUpInsideDenyButton(sender: UIButton) {
        if let followApplicant = self.followApplicant {
            self.denyButton.enabled = false
            self.approveButton.enabled = false
            
            ParseUtility.instance.denyUserInBackgroundWithBlock(followApplicant, block: { (isSuccess, error) -> Void in
                if !isSuccess {
                    self.denyButton.enabled = true
                    self.approveButton.enabled = true
                }
            })
        }
    }
    
    @IBAction func touchUpInsideApproveButton(sender: UIButton) {
        if let followApplicant = self.followApplicant {
            self.denyButton.enabled = false
            self.approveButton.enabled = false
            
            ParseUtility.instance.approveUserInBackgroundWithBlock(followApplicant, block: { (isSuccess, error) -> Void in
                if !isSuccess {
                    self.denyButton.enabled = true
                    self.approveButton.enabled = true
                }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(followApplicant : PFUser) {
        self.followApplicant = followApplicant
        
        self.usernameLabel.text = self.followApplicant?.username
        self.displayNameLabel.text = self.followApplicant?[userDisplayNameKey] as? String
        self.profilePictureImageView.file = self.followApplicant?[userProfilePictureKey] as? PFFile
        self.profilePictureImageView.loadInBackground()
    }
}
