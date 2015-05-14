//
//  SeminarsBaseTableViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/02.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class SeminarsBaseTableViewController: UITableViewController {

    struct Constants {
        struct Nib {
            static let name = "SeminarsTableViewCell"
        }
        
        struct TableViewCell {
            static let identifier = "seminarsTableViewCellIdentifier"
        }
        
        struct TableViewHeaderFooter {
            static let identifier = "seminarsTableViewHeaderFooterIdentifier"
        }
    }

    let statusMappings = ["1" : "available", "2" : "almost full", "3" : "full"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let nib = UINib(nibName: Constants.Nib.name, bundle: nil)
        
        // Required if our subclasses are to use: dequeueReusableCellWithIdentifier:forIndexPath:
        tableView.registerNib(nib, forCellReuseIdentifier: Constants.TableViewCell.identifier)
        
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: Constants.TableViewHeaderFooter.identifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureCell(cell: UITableViewCell, forSeminars seminars: [[NSDictionary]], indexPath : NSIndexPath) {
        let objDic = seminars[indexPath.section][indexPath.row]
        let storeName = (objDic["store"] as! NSDictionary)["name"] as! NSString
        let capacity = objDic["capacity"] as! Int
        let status = objDic["status"] as! String
        let start_time = objDic["start_time"] as! String
        
        if let startDateTime = DateUtility.dateFromSqliteDateTimeString(start_time) {
            let startDate = DateUtility.localDateString(startDateTime)
            let startTime = DateUtility.localTimeString(startDateTime)
            let capacityLabel = "capacity".localized()
            let statusLabel = "status".localized()
            let statusValue = (self.statusMappings[status] == nil ? "" : self.statusMappings[status]!).localized()
            cell.detailTextLabel?.text = "\(startDate) \(startTime)  \(capacityLabel):\(capacity)  \(statusLabel):\(statusValue)"
        }
        cell.textLabel?.text = "\(storeName)"
    }
    
    func configureHeaderInSection(tableView: UITableView, viewForHeaderInSection section: Int, forSeminars seminars: [[NSDictionary]]) -> UIView? {
        var label = UILabel()
        label.text = seminars[section].first?["edition"] as? String
        label.sizeToFit()
        label.backgroundColor = UIColor.grayColor()
        
        return label
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        if self.pressReleaseEntities.count > indexPath.row {
            self.pushSeminarDetailViewOnCellSelected(self.navigationControllerForDetail()!, relativePath: self.detailUrl(indexPath))
//        }
    }
    
    func navigationControllerForDetail() -> UINavigationController? {
        return self.navigationController
    }
    
    func detailUrl(ndexPath: NSIndexPath) -> String {
        return ""
    }
    
    func pushSeminarDetailViewOnCellSelected(navigationController: UINavigationController, relativePath : String) {
        
        // Set up the detail view controller to show.
        let detailViewController = SBUXWKWebViewController.forRelativePath(relativePath)
        
        // Note: Should not be necessary but current iOS 8.0 bug requires it.
        self.tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
        
        navigationController.pushViewController(detailViewController, animated: true)
        
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

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
