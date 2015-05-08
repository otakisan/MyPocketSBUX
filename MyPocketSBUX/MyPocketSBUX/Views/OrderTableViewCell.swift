//
//  OrderTableViewCell.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/14.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    var orderListItem : OrderListItem?
    var delegate : OrderTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func valueChangedOrderSwitch(sender: UISwitch) {
        self.orderListItem?.on = sender.on
        self.delegate?.valueChangedOrderSwitch(self, on: sender.on)
    }
    
    func touchUpInsideOrderEdit(cell : OrderTableViewCell){
        self.delegate?.touchUpInsideOrderEdit(self)
    }
    
    func configure(orderListItem : OrderListItem) {
        self.orderListItem = orderListItem
    }

}

protocol OrderTableViewCellDelegate : NSObjectProtocol {
    func valueChangedOrderSwitch(cell : OrderTableViewCell, on : Bool)
    func touchUpInsideOrderEdit(cell : OrderTableViewCell)
}

class OrderHeaderTableViewCell: UITableViewCell {
    var orderHeader : OrderHeader?
    var delegate : OrderHeaderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(orderHeader : OrderHeader) {
        self.orderHeader = orderHeader
    }
}

protocol OrderHeaderTableViewCellDelegate : NSObjectProtocol {
}

class StoreOrderTableViewCell : OrderHeaderTableViewCell {
    
    @IBOutlet weak var storeNameLabel: UILabel!
    override func configure(orderHeader : OrderHeader) {
        super.configure(orderHeader)
        
        self.storeNameLabel.text = self.orderHeader?.store?.name
    }
}

class NotesOrderTableViewCell : OrderHeaderTableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var notesTextField: UITextField!
    
    @IBAction func editingDidEndNotesTextField(sender: UITextField) {
        (self.delegate as? NotesOrderTableViewCellDelegate)?.editingDidEndNotesTextField(self, notes: sender.text)
    }
    
    override func configure(orderHeader : OrderHeader) {
        super.configure(orderHeader)
        
        self.notesTextField.delegate = self
        self.notesTextField.text = self.orderHeader?.notes
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.notesTextField.resignFirstResponder()
        (self.delegate as? NotesOrderTableViewCellDelegate)?.textFieldShouldReturnNotesTextField(self, notes: textField.text)
        return true
    }

}

protocol NotesOrderTableViewCellDelegate : OrderHeaderTableViewCellDelegate {
    func textFieldShouldReturnNotesTextField(cell : NotesOrderTableViewCell, notes : String)
    func editingDidEndNotesTextField(cell : NotesOrderTableViewCell, notes : String)
}

class BeanOrderTableViewCell : OrderTableViewCell {
    
    @IBOutlet weak var orderSwitch: UISwitch!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    
    @IBAction override func valueChangedOrderSwitch(sender: UISwitch) {
        super.valueChangedOrderSwitch(sender)
    }
    
    override func configure(orderListItem : OrderListItem) {
        super.configure(orderListItem)
        
        self.productNameLabel.text = orderListItem.productEntity?.valueForKey("name") as? String ?? ""
        self.priceLabel.text = "¥\(self.orderListItem?.totalPrice ?? 0)"
        self.orderSwitch.on = orderListItem.on
    }
}

