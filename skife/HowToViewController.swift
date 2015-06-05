//
//  HowToViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 04.06.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

class HowToViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var items = ["Start Search"]
    
    @IBOutlet weak var bbMenu: UIBarButtonItem!
    @IBOutlet weak var tvItems: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // RevealViewController Controls
        bbMenu.target = self.revealViewController()
        bbMenu.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.tvItems.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // Table View Specifying how many Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // Table View Generating each Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("howtoCell") as! UITableViewCell
        
        var nameLabel:String! = items[indexPath.row]
        cell.textLabel!.text = nameLabel
        
        return cell
    }
    
    // Click on TableView Row detection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}
