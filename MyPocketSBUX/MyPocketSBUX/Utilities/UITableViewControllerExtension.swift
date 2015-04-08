//
//  UITableViewControllerExtension.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

extension UITableViewController {
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    func dispatch_async_serial(block: () -> ()) {
        var privateQueue : dispatch_queue_t = dispatch_queue_create("jp.cafe.MyPocketSBUX.serial", DISPATCH_QUEUE_SERIAL)
        dispatch_async(privateQueue, block)
    }
    
    func reloadData(){
        dispatch_async_main{self.tableView.reloadData()}
    }
}
