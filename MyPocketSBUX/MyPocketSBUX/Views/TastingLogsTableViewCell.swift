//
//  TastingLogsTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/17.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TastingLogsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // imageViewを正方形にする。ラベルの位置も合わせて補正する。
        self.imageView?.clipsToBounds = true
        self.imageView?.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.FlexibleHeight.rawValue | UIViewAutoresizing.FlexibleWidth.rawValue)
        self.imageView?.contentMode = .ScaleAspectFill

        self.imageView?.frame = CGRectMake(
            self.imageView?.frame.origin.x ?? 0,
            self.imageView?.frame.origin.y ?? 0,
            self.imageView?.frame.size.height ?? 0,
            self.imageView?.frame.size.height ?? 0
        )
        self.textLabel?.frame = CGRectMake(
            (self.imageView?.frame.origin.x ?? 0) + (self.imageView?.frame.size.width ?? 0) + 15,
            self.textLabel?.frame.origin.y ?? 0,
            self.textLabel?.frame.size.width ?? 0,
            self.textLabel?.frame.size.height ?? 0
        )
        self.detailTextLabel?.frame = CGRectMake(
            self.textLabel?.frame.origin.x ?? 0,
            self.detailTextLabel?.frame.origin.y ?? 0,
            self.detailTextLabel?.frame.size.width ?? 0,
            self.detailTextLabel?.frame.size.height ?? 0
        )
    }
}
