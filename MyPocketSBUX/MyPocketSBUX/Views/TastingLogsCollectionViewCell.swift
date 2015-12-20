//
//  TastingLogsCollectionViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/22.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TastingLogsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(photoImage: UIImage?, title: String) {
        if let photoImage = photoImage {
            self.photoImageView.image = photoImage
            self.titleLabel.text = ""
        }else{
            self.photoImageView.image = nil
            self.titleLabel.text = title
        }
    }
}
