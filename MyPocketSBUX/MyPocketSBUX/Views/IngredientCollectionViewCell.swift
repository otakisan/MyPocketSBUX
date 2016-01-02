//
//  IngredientCollectionViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2016/01/01.
//  Copyright © 2016年 Takashi Ikeda. All rights reserved.
//

import UIKit

class IngredientCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ingredientImageView: UIImageView!
    
    func configure(ingredient : Ingredient) {
        if let iconData = ingredient.icon, let image = UIImage(data: iconData) {
            self.ingredientImageView.image = image
        }
    }
}
