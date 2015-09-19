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
    var navigationControllerOfOriginalViewController: UINavigationController?
    
    override func deleteAction(indexPath: NSIndexPath) {
        let removed = self.orders.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
        self.delegateForParent?.deleteActionViaFilteredList(removed)
    }
    
    override func refresh() {
        self.delegateForParent?.refreshViaFilteredList()
    }
    
    override func navigationControllerForOrder() -> UINavigationController? {
        return self.navigationControllerOfOriginalViewController
    }
}

protocol FilteredOrdersTableViewControllerDelegate {
    func deleteActionViaFilteredList(order: Order)
    func refreshViaFilteredList()
}
