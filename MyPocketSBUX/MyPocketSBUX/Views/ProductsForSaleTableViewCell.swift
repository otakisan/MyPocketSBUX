//
//  ProductsForSaleTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/08.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreData

class ProductsForSaleTableViewCell: UITableViewCell {
    
    var delegate : ProductsForSaleTableViewCellDelegate?
    var productListItem : ProductsForSaleListItem?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(productListItem: ProductsForSaleListItem) {
        self.productListItem = productListItem
    }

    func valueChangedOrderSwitch(sender: UISwitch) {
        self.productListItem?.isOnOrderList = sender.on
        self.delegate?.valueChangedOrderSwitch(self, on: sender.on)
    }
}

protocol ProductsForSaleTableViewCellDelegate {
    func valueChangedOrderSwitch(cell : ProductsForSaleTableViewCell, on : Bool)
}

class BeanProductsForSaleTableViewCell: ProductsForSaleTableViewCell {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBAction override func valueChangedOrderSwitch(sender: UISwitch) {
        super.valueChangedOrderSwitch(sender)
    }
    
    override func configure(productListItem: ProductsForSaleListItem) {
        if let beanEntity = productListItem.productEntity as? Bean {
            self.productNameLabel.text = beanEntity.name
            self.priceLabel.text = "¥\(beanEntity.price)"
        }
    }
}

protocol BeanProductsForSaleTableViewCellDelegate : ProductsForSaleTableViewCellDelegate {
    
}
