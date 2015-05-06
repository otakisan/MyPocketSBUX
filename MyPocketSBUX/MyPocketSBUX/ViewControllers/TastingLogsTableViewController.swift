//
//  TastingLogsTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TastingLogsTableViewController: UITableViewController {
    
    var tastingLogs : [TastingLog] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.refreshDataAndReloadTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.tastingLogs.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultTastingLogEditorTableViewCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = self.tastingLogs[indexPath.row].title
        cell.detailTextLabel?.text = "\(DateUtility.localDateString(self.tastingLogs[indexPath.row].tastingAt))@\(self.tastingLogs[indexPath.row].store?.name ?? String())"

        return cell
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
        if let vc = segue.destinationViewController as? TastingLogEditorTableViewController {
            switch segue.identifier ?? "" {
                case "addTastingLogSegue":
                vc.tastingLog = TastingLogManager.instance.newTastingLog()
            case "editTastingLogSegue":
                if let indexPath = self.tableView.indexPathForSelectedRow() {
                    vc.tastingLog = self.tastingLogs[indexPath.row]
                }
            default:
                fatalError("tasting logs: invalid segue: \(segue.identifier)")
            }
        }
    }
    
    @IBAction func tastingLogEditorDidSave(segue : UIStoryboardSegue) {
        if let tastingLogEditorViewController = segue.sourceViewController as? TastingLogEditorTableViewController {
            self.showNavigationPrompt("saved.", message: "log id: \(tastingLogEditorViewController.tastingLog.id)", displayingTime: 500000)
            
            self.refreshDataAndReloadTableView()
        }
    }

    @IBAction func tastingLogEditorDidCancel(segue : UIStoryboardSegue) {
        if let tastingLogEditorViewController = segue.sourceViewController as? TastingLogEditorTableViewController {
        }
    }
    
    func refreshDataAndReloadTableView(){
        
        // TODO: 現状はローカルにしかないので、単純にローカルDBから取得するのみ
        // 将来的にウェブにアップする場合には、ローカルとウェブとの差分の管理なんかも必要になるな
        // キャッシュ用のオフライン専用テーブルを作成したほうがいいかも。
        // シンプルにUNIONする等
        self.tastingLogs = TastingLogs.instance().getAllOrderBy([("tastingAt", false)])
        self.reloadData()
    }
    
    func showNavigationPrompt(title : String, message : String, displayingTime: useconds_t) {
        self.navigationItem.prompt = "\(title) : \(message)"
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            usleep(displayingTime)
            self.dispatch_async_main({
                self.navigationItem.prompt = nil
            })
        })
    }
}
