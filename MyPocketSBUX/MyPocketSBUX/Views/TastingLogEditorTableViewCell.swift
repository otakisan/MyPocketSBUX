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
    var newTastingLog = false

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
        self.newTastingLog = tastingLog.id == 0
        self.detailViewController = self.detailView()
    }
    
    func didPresentDetailView(){
        
    }
    
    func clear() {
        
    }
}

protocol TastingLogEditorTableViewCellDelegate {
    func presentViewController(viewController : UIViewController)
}

class TitleTastingLogEditorTableViewCell : TastingLogEditorTableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBAction func editingDidEndTitleTextField(sender: UITextField) {
        (self.delegate as? TitleTastingLogEditorTableViewCellDelegate)?.editingDidEndTitleTextField(self, title: sender.text!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.titleTextField.resignFirstResponder()
        (self.delegate as? TitleTastingLogEditorTableViewCellDelegate)?.textFieldShouldReturnTitleTextField(self, title: textField.text!)
        return true
    }

    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        
        self.titleTextField.text = tastingLog.title
    }
    
    override func clear() {
        self.titleTextField.text = ""
        self.editingDidEndTitleTextField(self.titleTextField)
    }
}

protocol TitleTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
    func textFieldShouldReturnTitleTextField(cell : TitleTastingLogEditorTableViewCell, title : String)
    func editingDidEndTitleTextField(cell : TitleTastingLogEditorTableViewCell, title : String)
}

class TagTastingLogEditorTableViewCell : TastingLogEditorTableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var tagTextField: UITextField!
    
    @IBAction func editingDidEndTagTextField(sender: UITextField) {
        (self.delegate as? TagTastingLogEditorTableViewCellDelegate)?.editingDidEndTagTextField(self, tag: sender.text!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.tagTextField.resignFirstResponder()
        (self.delegate as? TagTastingLogEditorTableViewCellDelegate)?.textFieldShouldReturnTagTextField(self, tag: textField.text!)
        return true
    }
    
    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        
        self.tagTextField.text = tastingLog.tag
    }
    
    override func clear() {
        self.tagTextField.text = ""
        self.editingDidEndTagTextField(self.tagTextField)
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
        let detailView : DatePickerViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DatePickerViewController") as? DatePickerViewController
        
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
    
    override func clear() {
        self.didOkDatePicker(DateUtility.minimumDate())
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
        let detailView : StoresTableViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoresTableViewController") as? StoresTableViewController
        
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
    
    override func clear() {
        self.reloadLabel("")
        (self.delegate as? StoreTastingLogEditorTableViewCellDelegate)?.valueChangedStore(nil)
    }
}

protocol StoreTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
    func valueChangedStore(store : Store?)
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
        let detailView : TextViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TextViewController") as? TextViewController
        
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
    
    override func clear() {
        self.didOkTextView("")
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
        let detailView : OrdersTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("OrdersTableViewController") as!OrdersTableViewController
        detailView.delegate = self
        detailView.handler = SelectItemOrdersTableViewControllerHandler()
        
        return detailView
    }
    
    func didSelectOrder(order: Order) {
        self.reloadOrderLabel(order)
        (self.delegate as? OrderTastingLogEditorTableViewCellDelegate)?.valueChangedOrder(order)
    }
    
    func reloadOrderLabel(order: Order?) {
        if let _ = order?.id as? Int {
//            let details = OrderDetails.getOrderDetailsWithOrderId(id, orderKeys: [(columnName: "id", ascending: true)])
            let details = order?.orderDetails.allObjects as! [OrderDetail]
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
    
    override func clear() {
        self.reloadLabel("")
        (self.delegate as? OrderTastingLogEditorTableViewCellDelegate)?.valueChangedOrder(nil)
    }
}

protocol OrderTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
    func valueChangedOrder(order : Order?)
}

class PhotoTastingLogEditorTableViewCell : TastingLogEditorTableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //private(set) var tastingLogId = 0

    @IBOutlet weak var photoView: UIImageView!

    @IBAction func touchUpInsideAddImageButton(sender: UIButton) {
        self.showMultimediaActionSheet()
    }

    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        self.detailViewModally = false
        (self.detailViewController as? TastingLogImageViewController)?.tastingLogId = Int(tastingLog.id)
        
        // イメージの設定
        self.photoView.layer.borderWidth = 0.5
        self.photoView.layer.borderColor = UIColor(white: 0.8, alpha: 0.5).CGColor
        if let photoData = tastingLog.photo, let photoImage = UIImage(data: photoData) {
            self.photoView.image = ImageUtility.photoThumbnail(photoImage)
            (self.detailViewController as? TastingLogImageViewController)?.imageData = photoData
        }
        else if let thumbnailData = tastingLog.thumbnail {
            self.photoView.image = UIImage(data: thumbnailData)
        }
    }
    
    override func detailView() -> UIViewController? {
        let detailView : TastingLogImageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TastingLogImageViewController") as!TastingLogImageViewController

        return detailView
    }
    
    override func didPresentDetailView() {
        (self.delegate as? PhotoTastingLogEditorTableViewCellDelegate)?.deselectSelectedCell()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        // TODO: 動画の場合は、サイズチェック、静止画表示、データは別途保持する
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.photoView.image = ImageUtility.photoThumbnail(selectedImage)
            (self.detailViewController as? TastingLogImageViewController)?.imageData = UIImageJPEGRepresentation(selectedImage, 1.0)
            (self.delegate as? PhotoTastingLogEditorTableViewCellDelegate)?.valueChangedPhoto(selectedImage)
        }
    }
    
    private func showImagePickerViewController(sourceType : UIImagePickerControllerSourceType) {
        let imageViewController = UIImagePickerController()
        imageViewController.sourceType = sourceType
        imageViewController.delegate = self
        imageViewController.allowsEditing = true
        
        self.delegate?.presentViewController(imageViewController)
    }
    
    private func showMultimediaActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            action in
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default) {
            action in self.showImagePickerViewController(.PhotoLibrary)
        }
        let takePhotoOrVideoAction = UIAlertAction(title: "Take Photo or Video", style: .Default) {
            action in self.showImagePickerViewController(.Camera)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(takePhotoOrVideoAction)
        self.delegate?.presentViewController(alertController)
    }
    
    override func clear() {
        self.photoView.image = nil
        (self.detailViewController as? TastingLogImageViewController)?.imageData = nil
        (self.delegate as? PhotoTastingLogEditorTableViewCellDelegate)?.valueChangedPhoto(nil)
    }
}

protocol PhotoTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
    func valueChangedPhoto(photo: UIImage?)
    func deselectSelectedCell()
}

class LikeTastingLogEditorTableViewCell : TastingLogEditorTableViewCell {
    
    private(set) var tastingLogId = 0
    
    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        
        self.tastingLogId = tastingLog.id as Int
        
        self.textLabel?.textColor = self.newTastingLog ? UIColor.lightGrayColor() : UIColor.blackColor()
        
        // カレントユーザーがすでに「いいね」をつけたか判定
        ParseUtility.instance.hasLikedLogByCurrentUserInBackgroundWithBlock(tastingLog.id as Int) { (hasLiked, error) -> Void in
            if hasLiked {
                self.accessoryType = .Checkmark
            } else {
                self.accessoryType = .None
            }
        }
        
        // いいねの件数を取得、表示
        self.refreshLikeCount()
    }
    
    override func didSelect(parentViewController: UITableViewController) {
        super.didSelect(parentViewController)
        
        // 「いいね」のON/OFF切り替え
        // 新規の場合は不要
        if !self.newTastingLog {
            self.switchLike()
        }
    }
    
    private func switchLike() {
        switch self.accessoryType {
        case .Checkmark:
            ParseUtility.instance.unlikeTastingLogInBackgroundWithBlock(self.tastingLogId, block: { (isSuccess, error) -> Void in
                self.refreshLikeCount()
                self.accessoryType = .None
            })
            break
        case .None:
            ParseUtility.instance.likeTastingLogInBackgroundWithBlock(self.tastingLogId, block: { (isSuccess, error) -> Void in
                if isSuccess {
                    self.accessoryType = .Checkmark
                } else {
                    self.accessoryType = .None
                }
                
                // TODO: 完了後に数を取得しに行っているから、増加した後の値が取れるかと思いきや、サーバー側処理のよってはそうでないこともあるよう
                self.refreshLikeCount()
            })
            break
        default:
            break
        }
    }
    
    private func refreshLikeCount() {
        ParseUtility.instance.countLikeForLogInBackgroundWithBlock(self.tastingLogId as Int) { (count, error) -> Void in
            self.detailTextLabel?.text = "(\(count))"
        }
    }
}

protocol LikeTastingLogEditorTableViewCellDelegate : TastingLogEditorTableViewCellDelegate {
}

class CommentTastingLogEditorTableViewCell : TastingLogEditorTableViewCell, CommentsOnTastingLogContainerViewDelegate {
    
    private(set) var tastingLogId = 0
    
    override func configure(tastingLog: TastingLog) {
        super.configure(tastingLog)
        self.detailViewModally = false
        self.tastingLogId = tastingLog.id as Int
        self.textLabel?.textColor = self.newTastingLog ? UIColor.lightGrayColor() : UIColor.blackColor()
        self.refreshCommentCount()
    }
    
    override func detailView() -> UIViewController? {
        var detailView : CommentsOnTastingLogContainerViewController?
        
        // 新規の場合はコメント不可（不要）
        if !self.newTastingLog {
            detailView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CommentsOnTastingLogContainerViewController") as? CommentsOnTastingLogContainerViewController
            detailView?.delegate = self
        }
        
        return detailView
    }
    
    override func didSelect(parentViewController: UITableViewController) {
        if let detailVc = self.detailViewController as? CommentsOnTastingLogContainerViewController {
            detailVc.tastingLogId = self.tastingLogId
        }
        
        super.didSelect(parentViewController)
    }
    
    func didSendComment(comment : String) {
        self.refreshCommentCount()
    }
    
    func didDeleteComment(comment: String) {
        self.refreshCommentCount()
    }
    
    private func refreshCommentCount() {
        ParseUtility.instance.countCommentForLogInBackgroundWithBlock(self.tastingLogId as Int) { (count, error) -> Void in
            self.detailTextLabel?.text = "(\(count))"
        }
    }
}
