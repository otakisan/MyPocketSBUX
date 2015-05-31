//
//  FilteredOrdersTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/31.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class FilteredOrdersTableViewController: OrdersBaseTableViewController {
    var delegateForParent: FilteredOrdersTableViewControllerDelegate?
    
    override func deleteAction(indexPath: NSIndexPath) {
        var removed = self.orders.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
        self.delegateForParent?.deleteActionViaFilteredList(removed)
    }
    
    override func refresh() {
        self.delegateForParent?.refreshViaFilteredList()
    }
}

protocol FilteredOrdersTableViewControllerDelegate {
    func deleteActionViaFilteredList(order: Order)
    func refreshViaFilteredList()
}
