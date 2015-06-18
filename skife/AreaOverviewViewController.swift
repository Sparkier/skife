//
//  AreaOverviewViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 11.06.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

class AreaOverviewViewController: RevealBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tvArea: UITableView!
    
    var areas: [(String, String, String)] = [("Tirol", "http://apps.tirol.gv.at/lwd/produkte/LLBTirol.xml", "Austria"), ("Steiermark", "http://lawine-steiermark.at/content/CAAML/caaml_stmk.xml", "Austria"), ("Yoho and Kootenay","http://avalanche.pc.gc.ca/CAAML-eng.aspx?d=TODAY&r=1", "Canada"), ("Little Yoho","http://avalanche.pc.gc.ca/CAAML-eng.aspx?d=TODAY&r=5", "Canada"), ("Glacier","http://avalanche.pc.gc.ca/CAAML-eng.aspx?d=TODAY&r=3", "Canada"), ("Jasper","http://avalanche.pc.gc.ca/CAAML-eng.aspx?d=TODAY&r=2", "Canada"), ("Waterton Lakes","http://avalanche.pc.gc.ca/CAAML-eng.aspx?d=TODAY&r=4", "Canada")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tvArea.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("areaCell") as! UITableViewCell
        
        cell.textLabel!.text = areas[indexPath.row].0
        cell.detailTextLabel!.text = areas[indexPath.row].2
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("avalancheWarningViewController")
        var avalancheWarningViewController: AvalancheWarningViewController = vc as! AvalancheWarningViewController
        avalancheWarningViewController.parseString = areas[indexPath.row].1
        if areas[indexPath.row].2 == "Canada" {
            avalancheWarningViewController.ca = true
        }
        navigationController?.pushViewController(vc as! UIViewController, animated: true)
    }
}
