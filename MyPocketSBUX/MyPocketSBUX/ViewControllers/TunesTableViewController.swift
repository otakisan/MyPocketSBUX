//
//  TunesTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/07.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class TunesTableViewController: UITableViewController {
    
    var tunes : [TuneItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.intialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // TODO:セクションは、月別かプロモ別か
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.tunes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultTunesTableViewCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = self.tunes[indexPath.row].entity.trackName
        cell.detailTextLabel?.text = self.tunes[indexPath.row].entity.artistName
        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(self.segueIdForPlayingTunes(), sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            if var webViewVc = segue.destinationViewController as? BaseWKWebViewController {
               webViewVc.absoluteURL = "https://www.youtube.com/results?search_query=\(TuneManager.instance.searchKeyword(self.tunes[indexPath.row]))"
            }
            else if var avPrayerViewVc = segue.destinationViewController as? AVPlayerViewController {
                if let avPlayer = AVPlayer.playerWithURL(NSURL(string: self.tunes[indexPath.row].entity.previewUrl)) as? AVPlayer {
                    avPrayerViewVc.player = avPlayer
                    avPrayerViewVc.player.play()
                }
            }
        }
    }
    
    func segueIdForPlayingTunes() -> String {
        return SettingsManager.instance.siteForPlayingTunes == SettingsManager.Defs.SiteForPlayingTunes.iTunes ? "AVPlayerViewSegue" : "WebViewSegue"
    }

    func intialize() {
        
        ContentsManager.instance.fetchContents(["tune"], orderKeys: [(columnName : "id", ascending : true)], completionHandler: { fetchResults in
            self.tunes = fetchResults.reduce([], combine: {
                $0 + $1.entities.map( { entity in TuneItem(entity: entity as! Tune) } )
            })
            
            self.reloadData()
        })
    }
}

