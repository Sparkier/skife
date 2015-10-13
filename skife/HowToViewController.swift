//
//  HowToViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 04.06.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

class HowToViewController: RevealBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var items = ["Send", "Start Searching", "Locate a Person"]
    
    @IBOutlet weak var tvItems: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgImg.removeFromSuperview()
        self.tvItems.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // Table View Specifying how many Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // Table View Generating each Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("howtoCell") as! HowToTableViewCell
        
        let nameLabel:String! = items[indexPath.row]
        cell.titleLabel.text = nameLabel
        cell.imView.image = UIImage(named: items[indexPath.row])
        
        return cell
    }
    
    // Click on TableView Row detection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // Height for TableView Cells
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tvItems.frame.size.width / 4.0 * 3.0
    }
    
    // Segue Preparation 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! HowToTableViewCell
        let vc = segue.destinationViewController as! ExplanationViewController
        vc.explanationName = cell.titleLabel.text
    }
}
