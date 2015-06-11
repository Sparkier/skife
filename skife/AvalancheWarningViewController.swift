//
//  AvalancheWarningViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 26.05.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

// ViewController for displaying Avalanche Warnings
class AvalancheWarningViewController: BaseViewController, NSXMLParserDelegate {
    
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var highlights = NSMutableString()
    var date = NSMutableString()
    var weather = NSMutableString()
    var snowPackStructure = NSMutableString()
    var travelAdvisoryComment = NSMutableString()
    
    @IBOutlet weak var tvWarnings: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.beginParsing()
        
        tvWarnings.text = (posts[0]["highlights"] as! String) + "\n" + (posts[0]["travelAdvisoryComment"] as! String) + "\n" + (posts[0]["snowPackStructure"] as! String) + "\n" + (posts[0]["weather"] as! String)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beginParsing() {
        posts = []
        parser = NSXMLParser(contentsOfURL: (NSURL(string: "https://apps.tirol.gv.at/lwd/produkte/llb/2014-2015/2015-01-14_0730/2015-01-14_0730_avalanche_bulletin_tyrol_de.xml")))!
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        element = elementName
        if (elementName as NSString).isEqualToString("caaml:Bulletin") {
            elements = NSMutableDictionary.alloc()
            elements = [:]
            highlights = NSMutableString.alloc()
            highlights = ""
            date = NSMutableString.alloc()
            date = ""
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?){
        if element.isEqualToString("caaml:highlights") {
            highlights.appendString(string!)
        } else if element.isEqualToString("caaml:dateTimeReport") {
            date.appendString(string!)
        } else if element.isEqualToString("caaml:wxSynopsisComment") {
            weather.appendString(string!)
        } else if element.isEqualToString("caaml:snowpackStructureComment") {
            snowPackStructure.appendString(string!)
        } else if element.isEqualToString("caaml:travelAdvisoryComment") {
            travelAdvisoryComment.appendString(string!)
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName as NSString).isEqualToString("caaml:Bulletin") {
            if !highlights.isEqual(nil) {
                elements.setObject(highlights, forKey: "highlights")
            }
            if !date.isEqual(nil) {
                elements.setObject(date, forKey: "date")
            }
            if !weather.isEqual(nil) {
                elements.setObject(weather, forKey: "weather")
            }
            if !snowPackStructure.isEqual(nil) {
                elements.setObject(snowPackStructure, forKey: "snowPackStructure")
            }
            if !travelAdvisoryComment.isEqual(nil) {
                elements.setObject(travelAdvisoryComment, forKey: "travelAdvisoryComment")
            }
            posts.addObject(elements)
        }
    }
}