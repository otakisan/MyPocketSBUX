//
//  NewsBaseTableViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/05/11.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class NewsBaseTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var pressReleaseEntities : [PressRelease] = []
    var fontSize : Float = 17.0
    var officialSiteRelativePath = ""

    struct Constants {
        struct Nib {
            static let name = "NewsTableViewCell"
        }
        
        struct TableViewCell {
            static let identifier = "newsTableViewCellIndetifier"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let nib = UINib(nibName: Constants.Nib.name, bundle: nil)
        
        // Required if our subclasses are to use: dequeueReusableCellWithIdentifier:forIndexPath:
        tableView.registerNib(nib, forCellReuseIdentifier: Constants.TableViewCell.identifier)
        
        self.addPinchGestureRecognizer();
        
        tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableViewAutomaticDimension // カスタムセルの場合は明示的な指定が必要
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        // 年度ごとに分けてデータを保持するようになったら、年度の数だけセクションを分けるようにする
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.pressReleaseEntities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) as! NewsTableViewCell
        
        // Configure the cell...
        self.configure(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath)-> NSIndexPath? {
        if self.pressReleaseEntities.count > indexPath.row {
            self.officialSiteRelativePath = (self.pressReleaseEntities[indexPath.row].url) ?? ""
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.pressReleaseEntities.count > indexPath.row {
            self.pushStoreDetailViewOnCellSelected(self.navigationControllerForDetail()!, relativePath: self.pressReleaseEntities[indexPath.row].url)
        }
    }
    
    func navigationControllerForDetail() -> UINavigationController? {
        return self.navigationController
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
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using [segue destinationViewController].
//        // Pass the selected object to the new view controller.
//    }
    
    func addPinchGestureRecognizer(){
        // ピンチジェスチャをビューに登録
        var pinch = UIPinchGestureRecognizer(target:self, action:"pinchGesture:")
        pinch.delegate = self;
        self.tableView.addGestureRecognizer(pinch)
    }
    
    func pinchGesture(gesture : UIPinchGestureRecognizer) {
        //println(gesture.scale)
        
        // scaleは加速度にもよるが、0〜4くらいが多い。最大でも14程度
        self.fontSize = Float(gesture.scale) * 14
        self.reloadData()
    }

    func configure(cell: NewsTableViewCell, indexPath: NSIndexPath) {
        
        // Configure the cell...
        if pressReleaseEntities.count > indexPath.row {
            cell.titleLabel.text = pressReleaseEntities[indexPath.row].title
            cell.titleLabel.numberOfLines = 0 // 複数行表示
            cell.titleLabel.font = UIFont(name: "Arial", size: CGFloat(self.fontSize))
            cell.titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.issueDateLabel.text = DateUtility.localDateString(pressReleaseEntities[indexPath.row].issueDate)
            cell.sizeToFit()
        }

    }
    
    func pushStoreDetailViewOnCellSelected(navigationController: UINavigationController, relativePath : String) {
        
        // Set up the detail view controller to show.
        let detailViewController = SBUXWKWebViewController.forRelativePath(relativePath)
        
        // Note: Should not be necessary but current iOS 8.0 bug requires it.
        self.tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
        
        navigationController.pushViewController(detailViewController, animated: true)
        
    }

}
