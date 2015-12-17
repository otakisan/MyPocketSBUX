//
//  TastingLogEditorTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TastingLogEditorTableViewController: UITableViewController, TitleTastingLogEditorTableViewCellDelegate,
    TagTastingLogEditorTableViewCellDelegate,
    TastingTastingLogEditorTableViewCellDelegate,
    StoreTastingLogEditorTableViewCellDelegate,
    DetailTastingLogEditorTableViewCellDelegate,
    OrderTastingLogEditorTableViewCellDelegate,
    PhotoTastingLogEditorTableViewCellDelegate{

    struct StoryboardConstants {
        static let storyboardName = "Main"
        static let viewControllerIdentifier = "TastingLogEditorTableViewController"
    }

    @IBOutlet weak var tastingLogEditorNavigationBar: UINavigationBar!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    var tastingLog: TastingLog!
    var newTastingLog = false
    var delegate: TastingLogEditorTableViewControllerDelegate?

    class func forTastingLog(tastingLog: TastingLog) -> TastingLogEditorTableViewController {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardConstants.viewControllerIdentifier) as! TastingLogEditorTableViewController
        
        viewController.tastingLog = tastingLog
        
        return viewController
    }

    @IBAction func actionSaveButtonItem(sender: UIBarButtonItem) {
        // 最初にローカルへ保存
        self.saveTastingLog()
        
        // TODO: サーバーにアップしたデータと、登録日時・更新日時を揃える必要があるか
        // TODO: アップに失敗した場合は、手動にて再度のアップが必要になる。失敗したことがわかるマーキング
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            TastingLogManager.instance.postJsonContentsToWebWithRegiserSyncRequestIfFailed(self.tastingLog)
        })
        
        self.delegate?.didSaveTastingLog(self.tastingLog)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionCancelBarButtonItem(sender: UIBarButtonItem) {
        self.cancelTastingLog()
        self.delegate?.didCancelTastingLog(self.tastingLog)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // ステータスバーの高さの分だけ余白を作る（隙間ができて、背景色の設定が必要になるので行わない）
        let statusBarHeight: CGFloat! = UIApplication.sharedApplication().statusBarFrame.height
        
        // ナビゲーションバーの高さをプラスする（なぜか、タイトルの中心位置がちょうどよいところへ補正される）
        let currentRect = self.tastingLogEditorNavigationBar.frame
        self.tastingLogEditorNavigationBar.frame = CGRectMake(0, 0, currentRect.width, currentRect.height + statusBarHeight)
        
        // 登録されていなければ登録する
        self.newTastingLog = TastingLogs.registerEntity(self.tastingLog)
        
        // ログインユーザー、もしくは新規のログのみ保存可能
        self.saveBarButtonItem.enabled = IdentityContext.sharedInstance.signedIn() && (IdentityContext.sharedInstance.currentUserID == self.tastingLog.myPocketId || self.newTastingLog)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as!TastingLogEditorTableViewCell
        cell.delegate = self
        cell.configure(self.tastingLog)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? TastingLogEditorTableViewCell {
            cell.didSelect(self)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        switch segue.identifier ?? "" {
        case "tastingLogEditorDidSaveSegue":
            self.saveTastingLog()
        case "tastingLogEditorDidCancelSegue":
            self.cancelTastingLog()
        default:
            fatalError("uknown segue \(segue.identifier)")
        }
    }
    
    func saveTastingLog() {
        TastingLogManager.instance.saveTastingLog(self.tastingLog, newTastingLog: self.newTastingLog)
    }
    
    func cancelTastingLog() {
        TastingLogManager.instance.cancelTastingLog(self.tastingLog, newTastingLog: self.newTastingLog)
    }
    
    func textFieldShouldReturnTitleTextField(cell : TitleTastingLogEditorTableViewCell, title : String){
    }
    
    func editingDidEndTitleTextField(cell : TitleTastingLogEditorTableViewCell, title : String){
        self.tastingLog.title = title
    }

    func textFieldShouldReturnTagTextField(cell : TagTastingLogEditorTableViewCell, tag : String){
    }
    
    func editingDidEndTagTextField(cell : TagTastingLogEditorTableViewCell, tag : String){
        self.tastingLog.tag = tag
    }

    func valueChangedTastingAt(date: NSDate){
        self.tastingLog.tastingAt = date
    }
    
    func valueChangedStore(store : Store){
        self.tastingLog.store = store
    }
    
    func valueChangedDetail(detail: String){
        self.tastingLog.detail = detail
    }
    
    func valueChangedOrder(order : Order){
        self.tastingLog.order = order
    }
    
    func valueChangedPhoto(photo: UIImage) {
        // 容量は大きくてもユーザーの端末なので大丈夫
        // TODO: 画像のサイズから圧縮率を決める
        self.tastingLog.photo = UIImageJPEGRepresentation(photo, 0.5)
    }
    
    func deselectSelectedCell() {
        // Note: Should not be necessary but current iOS 8.0 bug requires it.
        self.tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow!, animated: false)
    }
}

protocol TastingLogEditorTableViewControllerDelegate {
    func didSaveTastingLog(tastingLog: TastingLog)
    func didCancelTastingLog(tastingLog: TastingLog)
}