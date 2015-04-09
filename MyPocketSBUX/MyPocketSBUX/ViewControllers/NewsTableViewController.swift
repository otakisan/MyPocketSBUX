//
//  NewsTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/03/25.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var pressReleaseEntities : [PressRelease] = []
    var fontSize : Float = 14.0
    let fontSizeMax : Float = 24.0
    var officialSiteRelativePath = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //self.configTableHeaderView()
        self.addPinchGestureRecognizer();
        
        self.initializeNewsData()
    }
    
    func addPinchGestureRecognizer(){
        // ピンチジェスチャをビューに登録
        var pinch = UIPinchGestureRecognizer(target:self, action:"pinchGesture:")
        pinch.delegate = self;
        self.tableView.addGestureRecognizer(pinch)
    }
    
    func pinchGesture(gesture : UIPinchGestureRecognizer) {
        println(gesture.scale)
        
        // scaleは加速度にもよるが、0〜4くらいが多い。最大でも14程度
        self.fontSize = Float(gesture.scale) * 14
        self.reloadData()
    }
    
    func configTableHeaderView(){
        var fontSlider = UISlider()
        fontSlider.value = fontSize / fontSizeMax
        fontSlider.addTarget(self, action: "onChangeValueMySlider:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.tableHeaderView = fontSlider
    }
    
    func onChangeValueMySlider(sender : UISlider){
        self.fontSize = sender.value * fontSizeMax
        self.reloadData()
    }
    
    func getAllPressReleaseFromLocal() -> [PressRelease] {
        return PressReleases.getAllOrderBy([(columnName : "pressReleaseSn", ascending : false)])
    }
    
    func insertNewPressReleaseToLocal(newPressReleaseData : NSArray) -> [PressRelease] {
        
        var results : [PressRelease] = []
        
        for newPressRelease in newPressReleaseData {
            var entity = PressReleases.createEntity()
            entity.fiscalYear = (newPressRelease["fiscal_year"] as? NSNumber) ?? 0
            entity.pressReleaseSn = (newPressRelease["press_release_sn"] as? NSNumber) ?? 0
            entity.title = ((newPressRelease["title"] as? NSString) ?? "") as String
            entity.url = ((newPressRelease["url"] as? NSString) ?? "") as String
            entity.createdAt = (newPressRelease["created_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = (newPressRelease["updated_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            
            PressReleases.insertEntity(entity)
            results.append(entity)
        }
        
        return results
    }
    
    func initializeNewsData(){
        
        // ローカルDBのキャッシュデータを取得
        self.pressReleaseEntities = self.getAllPressReleaseFromLocal()
        
        // トップ１件のSNを取得（ゼロ件ヒットの場合はゼロにする）
        let maxSn = self.pressReleaseEntities.count > 0 ? self.pressReleaseEntities.first!.pressReleaseSn : 0
        
        // 性能改善するのであれば、ローカルにある分でまず表示
        // その後ウェブから取得した分を先頭に追加して表示する
        
        // 最新版を取得
        let nextSn = Int(maxSn) + 1
        if let url  = NSURL(string: "http://localhost:3000/press_releases.json/?type=range&key=press_release_sn&from=\(nextSn)") {
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task    = session.dataTaskWithURL(url, completionHandler: {
                (data, resp, err) in
                if var newsData = self.initializeNewsArrayFromJson(data) {
                    var newPressReleaseData  : [PressRelease] = self.insertNewPressReleaseToLocal(newsData)
                    newPressReleaseData.extend(self.pressReleaseEntities)
                    self.pressReleaseEntities = newPressReleaseData
                }
                self.reloadData()
                //println(NSString(data: data, encoding:NSUTF8StringEncoding))
            })
        
            task.resume()
        }
    }
    
    func initializeNewsArrayFromJson(newsJson: NSData) -> NSArray?{
        return NSJSONSerialization.JSONObjectWithData(newsJson, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray
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
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultNewsTableViewCellIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        if self.pressReleaseEntities.count > indexPath.row {
            cell.textLabel?.text = self.pressReleaseEntities[indexPath.row].title
            cell.textLabel?.numberOfLines = 0 // 複数行表示
            cell.textLabel?.font = UIFont(name: "Arial", size: CGFloat(self.fontSize))
            cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.sizeToFit()
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath)-> NSIndexPath? {
        if self.pressReleaseEntities.count > indexPath.row {
            self.officialSiteRelativePath = (self.pressReleaseEntities[indexPath.row].url) ?? ""
        }
        return indexPath
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
        if var officialWebViewController = segue.destinationViewController as? SBUXWKWebViewController {
            officialWebViewController.relativePath = self.officialSiteRelativePath
        }
    }
    

}
