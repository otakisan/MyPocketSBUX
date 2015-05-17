//
//  TastingLogEditorTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TastingLogEditorTableViewCell: UITableViewCell {
    
    var delegate: TastingLogEditorTableViewCellDelegate?
    var detailViewController: UIViewController?
    var detailViewModally : Bool = true

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func didSelect(parentViewController: UITableViewController) {
        if let detailVc = self.detailViewController {
            if detailViewModally {
                parentViewController.presentViewController(detailVc, animated: true, completion: {})
            }
            else{
                if let nv = parentViewController.navigationController {
                    nv.pushViewController(detailVc, animated: true)
                }else{
                    let newNv = UINavigationController(rootViewController: detailVc)
                    parentViewController.presentViewController(newNv, animated: true, completion: {})
                }
            }
            
            self.didPresentDetailView()
        }
    }
    
    func detailView() -> UIViewController? {
        return nil
    }
    
    func configure(tastingLog: TastingLog) {
        self.detailViewController = self.detailView()
    }
    
    func didPresentDetailView(){
        
    }
}

protocol TastingLogEditorTableViewCellDelegate {
    
}

class TitleTastingLogEditorTableViewCell : TastingLogEditorTableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBAction func editingDidEndTitleTextField(sender: UITextField) {
        (self.delegate as? TitleTastingLogEditorTableViewCellDelegate)?.editingDidEndTitleTextField(self, title: sender.text)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.titleTextField.resignFirstResponder()
        (self.delegate as? TitleTastingLogEditorTableViewCellDelegate)?.textFieldShouldReturnTitleTextField(self, title: textField.text)
        return true
    }

    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        
        self.titleTextField.text = tastingLog.title
    }
}

protocol TitleTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
    func textFieldShouldReturnTitleTextField(cell : TitleTastingLogEditorTableViewCell, title : String)
    func editingDidEndTitleTextField(cell : TitleTastingLogEditorTableViewCell, title : String)
}

class TagTastingLogEditorTableViewCell : TastingLogEditorTableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var tagTextField: UITextField!
    
    @IBAction func editingDidEndTagTextField(sender: UITextField) {
        (self.delegate as? TagTastingLogEditorTableViewCellDelegate)?.editingDidEndTagTextField(self, tag: sender.text)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.tagTextField.resignFirstResponder()
        (self.delegate as? TagTastingLogEditorTableViewCellDelegate)?.textFieldShouldReturnTagTextField(self, tag: textField.text)
        return true
    }
    
    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        
        self.tagTextField.text = tastingLog.tag
    }
}

protocol TagTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
    func textFieldShouldReturnTagTextField(cell : TagTastingLogEditorTableViewCell, tag : String)
    func editingDidEndTagTextField(cell : TagTastingLogEditorTableViewCell, tag : String)
}

class TastingAtTastingLogEditorTableViewCell : TastingLogEditorTableViewCell, DatePickerViewControllerDelegate {
    
    @IBOutlet weak var tasitingDateLabel: UILabel!
    
    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        
        self.reloadLabel(tastingLog.tastingAt)
    }
    
    override func detailView() -> UIViewController? {
        var detailView : DatePickerViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DatePickerViewController") as? DatePickerViewController
        
        if detailView != nil {
            detailView!.delegate = self
        }
        
        return detailView
    }
    
    func didOkDatePicker(date: NSDate){
        self.reloadLabel(date)
        
        (self.delegate as? TastingTastingLogEditorTableViewCellDelegate)?.valueChangedTastingAt(date)
    }
    
    func didCancelDatePicker(date: NSDate){
        
    }

    func labelText(date: NSDate) -> String {
        return "\(DateUtility.localDateString(date)) \(DateUtility.localTimeString(date))"
    }
    
    func reloadLabel(date: NSDate){
        if date == DateUtility.minimumDate() {
            self.tasitingDateLabel.text = "tasting date ..."
            self.tasitingDateLabel.textColor = UIColor.lightGrayColor()
        }
        else{
            self.tasitingDateLabel.text = self.labelText(date)
            self.tasitingDateLabel.textColor = UIColor.blackColor()
        }
    }
}

protocol TastingTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
    func valueChangedTastingAt(date: NSDate)
}

class StoreTastingLogEditorTableViewCell : TastingLogEditorTableViewCell, StoresTableViewDelegate {

    @IBOutlet weak var storeLabel: UILabel!

    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        self.detailViewModally = false
        
        if let storeName = tastingLog.store?.name {
            self.reloadLabel(storeName)
        }
    }
    
    override func detailView() -> UIViewController? {
        var detailView : StoresTableViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoresTableViewController") as? StoresTableViewController
        
        if detailView != nil {
            detailView!.delegate = self
            detailView!.selectBySwipe = true
            detailView!.needToAddCancelButton = true
        }
        
        return detailView
    }
    
    func selectAndClose(store : Store){
        self.reloadLabel(store.name)
        (self.delegate as? StoreTastingLogEditorTableViewCellDelegate)?.valueChangedStore(store)
        
        // TODO: かなり密結合な制御になっている
        (self.detailViewController as? StoresTableViewController)?.searchController.active = false
        self.detailViewController?.dismissViewControllerAnimated(true, completion: {})
    }
    
    func reloadLabel(text: String){
        if text == "" {
            self.storeLabel.text = "store ..."
            self.storeLabel.textColor = UIColor.lightGrayColor()
        }
        else{
            self.storeLabel.text = text
            self.storeLabel.textColor = UIColor.blackColor()
        }
    }
}

protocol StoreTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
    func valueChangedStore(store : Store)
}

class DetailTastingLogEditorTableViewCell : TastingLogEditorTableViewCell, TextViewControllerDelegate {
    
    @IBOutlet weak var detailLabel: UILabel!
    
    var placeHolderText = "detail ..."
    var detailText = ""
    
    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        
        self.detailText = tastingLog.detail
        self.reloadLabel(self.detailText)
    }
    
    override func detailView() -> UIViewController? {
        var detailView : TextViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TextViewController") as? TextViewController
        
        if detailView != nil {
            detailView!.delegate = self
        }
        
        return detailView
    }
    
    func didOkTextView(text: String){
        self.detailText = text
        self.reloadLabel(self.detailText)
        (self.delegate as? DetailTastingLogEditorTableViewCellDelegate)?.valueChangedDetail(text)
    }
    
    func didCancelTextView(text: String){
        
    }
    
    func reloadLabel(detail: String){
        if detail == "" {
            self.detailLabel.text = self.placeHolderText
            self.detailLabel.textColor = UIColor.lightGrayColor()
        }
        else{
            self.detailLabel.text = detail
            self.detailLabel.textColor = UIColor.blackColor()
        }
    }

    override func didPresentDetailView() {
        (self.detailViewController as? TextViewController)?.textView.text = self.detailText
    }
}

protocol DetailTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
    func valueChangedDetail(detail: String)
}

class OrderTastingLogEditorTableViewCell : TastingLogEditorTableViewCell, OrdersTableViewControllerDelegate {

    @IBOutlet weak var orderLabel: UILabel!

    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        self.detailViewModally = false
        self.reloadOrderLabel(tastingLog.order)
    }
    
    override func detailView() -> UIViewController? {
        var detailView : OrdersTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("OrdersTableViewController") as!OrdersTableViewController
        detailView.delegate = self
        detailView.handler = SelectItemOrdersTableViewControllerHandler()
        
        return detailView
    }
    
    func didSelectOrder(order: Order) {
        self.reloadOrderLabel(order)
        (self.delegate as? OrderTastingLogEditorTableViewCellDelegate)?.valueChangedOrder(order)
    }
    
    func reloadOrderLabel(order: Order?) {
        if let id = order?.id as? Int {
            let details = OrderDetails.getOrderDetailsWithOrderId(id, orderKeys: [(columnName: "id", ascending: true)])
            self.reloadLabel(details.first?.productName ?? "")
        }
    }
    
    func reloadLabel(text: String){
        if text == "" {
            self.orderLabel.text = "order ..."
            self.orderLabel.textColor = UIColor.lightGrayColor()
        }
        else{
            self.orderLabel.text = text
            self.orderLabel.textColor = UIColor.blackColor()
        }
    }
}

protocol OrderTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
    func valueChangedOrder(order : Order)
}