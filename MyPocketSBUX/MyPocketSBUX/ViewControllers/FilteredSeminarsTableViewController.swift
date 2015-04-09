//
//  FilteredSeminarsTableViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/02.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class FilteredSeminarsTableViewController: SeminarsBaseTableViewController {

    var filteredSeminarData : [[NSDictionary]]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        let sectionCount = self.filteredSeminarData?.count ?? 0
        return sectionCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.filteredSeminarData?[section].count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        if let tableData = self.filteredSeminarData {
            self.configureCell(cell, forSeminars: tableData, indexPath: indexPath)
        }

        return cell
    }
    
    // ストーリーボード上にからの遷移でないViewControllerなのかなんなのか、高さが必要なので、ひとまず通常のセクションを使用する
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return self.filteredSeminarData?[section].first?["edition"] as? String

    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        var label : UIView? = nil
//        if let tableData = self.filteredSeminarData {
//            label = self.configureHeaderInSection(tableView, viewForHeaderInSection: section, forSeminars: tableData)
//        }
//        
//        return label
//    }
//
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return CGFloat(20)
//    }
    
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
