//
//  TastingLogsCollectionViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/22.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

//private let reuseIdentifier = "tastingLogsCollectionViewCellIdentifier"

class TastingLogsCollectionViewController: PFQueryCollectionViewController {
    
    struct Constants {
        struct Nib {
            static let name = "TastingLogsCollectionViewCell"
        }
        
        struct CollectionViewCell {
            static let identifier = "tastingLogsCollectionViewCellIdentifier"
            static let numberOfCellsInRow = 3
            static let spacing = 1
        }
    }

    var user : PFUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: エディター側がローカルDB経由のみのデータ取得であることへの暫定処置
        self.fetchTastingLogAndStoreLocalDb()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        let nib = UINib(nibName: Constants.Nib.name, bundle: nil)
        
        // Required if our subclasses are to use: dequeueReusableCellWithIdentifier:forIndexPath:
        self.collectionView!.registerNib(nib, forCellWithReuseIdentifier: Constants.CollectionViewCell.identifier)

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Tasting Logs"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        // *******
        // Configure the PFQueryTableView
        
        // PFObject/PFUser等のエンティティクラス
        self.parseClassName = "PFObject"
        
        // 一覧に並べる際に、キーとみなす項目。重複があると異常終了する
        //self.textKey = "username"
        
        self.pullToRefreshEnabled = true
        
        // trueにすると、一覧の最下セルにLoad moreが出る（日本語設定でも英語のまま）
        self.paginationEnabled = true
    }

    override func queryForCollection() -> PFQuery {
        return ParseUtility.instance.queryForTastingLog(self.user)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCell.identifier, forIndexPath: indexPath) as! TastingLogsCollectionViewCell
        
        let title = self.objects[indexPath.row]["title"] as? String ?? ""
        if let photoFile = self.objects[indexPath.row]["photo"] as? PFFile {
            photoFile.getDataInBackgroundWithBlock({ (photoData, error) -> Void in
                if let photoDataFetched = photoData {
                    cell.configure(UIImage(data: photoDataFetched), title: title)
                }
                else{
                    cell.configure(nil, title: title)
                }
            })
        }
        else{
            cell.configure(nil, title: title)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(Constants.CollectionViewCell.spacing)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(Constants.CollectionViewCell.spacing)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let spacingInRow = CGFloat((Constants.CollectionViewCell.numberOfCellsInRow - 1) * Constants.CollectionViewCell.spacing)
        let size = (collectionView.frame.width - spacingInRow) / CGFloat(Constants.CollectionViewCell.numberOfCellsInRow)

        return CGSizeMake(size, size)
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO: あらかじめローカルDBに格納しておかないとヒットしない
        if let tastingLog : TastingLog = TastingLogs.instance().findById(self.objects[indexPath.row]["id"] as? Int ?? 0){
            self.presentTastingLogEditor(tastingLog)
        }
    }
    
    private func presentTastingLogEditor(tastingLog: TastingLog) {
        // Set up the detail view controller to show.
        let detailViewController = TastingLogEditorTableViewController.forTastingLog(tastingLog)
        //detailViewController.delegate = self
        
        // Note: Should not be necessary but current iOS 8.0 bug requires it.
        //self.tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow!, animated: false)
        
        self.presentViewController(detailViewController, animated: true, completion: nil)
    }
    
    private func fetchTastingLogAndStoreLocalDb(){
        // TODO: ローカルDBに格納して置かないと、エディター側に渡せない
        ContentsManager.instance.fetchContents(["store"], variables: [:], orderKeys: [], completionHandler: { fetchResults in
            ContentsManager.instance.fetchContents(["tasting_log"], variables: ["myPocketId": self.user?.username ?? ""
                ], orderKeys: [(columnName : "tastingAt", ascending : false)], completionHandler: { fetchResults in
                    print("completed to store \(self.user?.username)'s tastinglogs")
            })
        })
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.loadObjects()
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
