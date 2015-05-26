//
//  MenuViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 29.04.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableArray = [String]()
    var channelArray = [String]()
    
    @IBOutlet var vMenu: UIView!
    @IBOutlet weak var tvMenu: UITableView!
    
    override func viewDidLoad() {
        tableArray = ["Broadcast", "Search"]
        channelArray = ["Information", "Profile", "Avalanche Warnings"]
        let indexpath = NSIndexPath(forRow: 0, inSection: 1)
        self.tvMenu.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Safety"
        case 1:
            return "Extras"
        default: break
        }
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tableArray.count
        } else {
            return channelArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.section {
        case 0:
            cell = tvMenu.dequeueReusableCellWithIdentifier(tableArray[indexPath.row]) as! UITableViewCell
            cell.textLabel?.text = tableArray[indexPath.row]
            
        case 1:
            cell = tvMenu.dequeueReusableCellWithIdentifier(channelArray[indexPath.row]) as! UITableViewCell
            cell.textLabel?.text = channelArray[indexPath.row]
        default:
            break
        }
        cell.textLabel?.textColor = UIColor.whiteColor()
        var cellSelectionView = UIView(frame: cell.frame)
        cellSelectionView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        cell.selectedBackgroundView = cellSelectionView
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.blackColor()
        header.alpha = 0.3
        header.textLabel.textColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
}