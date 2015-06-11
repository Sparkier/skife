//
//  AreaOverviewViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 11.06.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

class AreaOverviewViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bbMenu: UIBarButtonItem!
    @IBOutlet weak var tvArea: UITableView!
    
    var areas: [String] = ["Tirol"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // RevealViewController Controls
        bbMenu.target = self.revealViewController()
        bbMenu.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.tvArea.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("areaCell") as! UITableViewCell
        
        cell.textLabel!.text = areas[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("avalancheWarningViewController")
        var detailedSearchViewController: AvalancheWarningViewController = vc as! AvalancheWarningViewController
        navigationController?.pushViewController(vc as! UIViewController, animated: true)
    }
}
