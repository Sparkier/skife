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
    
    var regionString = ""
    
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var dangerPosts = NSMutableArray()
    var elements = NSMutableDictionary()
    var dangers = NSMutableDictionary()
    var element = NSString()
    var highlights = NSMutableString()
    var date = NSMutableString()
    var weather = NSMutableString()
    var snowPackStructure = NSMutableString()
    var travelAdvisoryComment = NSMutableString()
    var mainValue = NSMutableString()
    var timeValue = NSMutableString()
    var parseString: String!
    var ca = false
    
    @IBOutlet weak var lblRegion: UILabel!
    @IBOutlet weak var lblDanger: UILabel!
    @IBOutlet weak var imDanger: UIImageView!
    @IBOutlet weak var tvWarnings: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblRegion.text = regionString
    }
    
    // Parsing Bulletin and settung TextView
    override func viewDidAppear(animated: Bool) {
        self.beginParsing()
        
        var attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)]
        
        // Highlights Section
        var attributedString = NSMutableAttributedString(string:"Highlights\n", attributes:attrs)
        attributedString.appendAttributedString(NSMutableAttributedString(string:posts[0]["highlights"] as! String + "\n\n"))
        
        // TravelAdvisoryComment Section
        attributedString.appendAttributedString(NSMutableAttributedString(string: "Travel advisoy Comment\n", attributes: attrs))
        attributedString.appendAttributedString(NSMutableAttributedString(string:posts[0]["travelAdvisoryComment"] as! String + "\n\n"))
        
        // Snowpack Structure Section
        attributedString.appendAttributedString(NSMutableAttributedString(string: "Snowpack Structure\n", attributes: attrs))
        attributedString.appendAttributedString(NSMutableAttributedString(string:posts[0]["snowPackStructure"] as! String + "\n\n"))
        
        // Weather Section
        attributedString.appendAttributedString(NSMutableAttributedString(string: "Weather\n", attributes: attrs))
        attributedString.appendAttributedString(NSMutableAttributedString(string:posts[0]["weather"] as! String))
        
        setDangerLevel()
        tvWarnings.attributedText = attributedString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Starting to parse
    func beginParsing() {
        posts = []
        parser = NSXMLParser(contentsOfURL: (NSURL(string: parseString)))!
        parser.delegate = self
        parser.parse()
    }
    
    // Beginning to parse one Element
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        element = elementName
        if (elementName as NSString).isEqualToString("caaml:Bulletin") || (elementName as NSString).isEqualToString("CaamlData") {
            elements = NSMutableDictionary.alloc()
            elements = [:]
            highlights = NSMutableString.alloc()
            highlights = ""
            date = NSMutableString.alloc()
            date = ""
            weather = NSMutableString.alloc()
            weather = ""
            snowPackStructure = NSMutableString.alloc()
            snowPackStructure = ""
            travelAdvisoryComment = NSMutableString.alloc()
            travelAdvisoryComment = ""
        } else if (elementName as NSString).isEqualToString("caaml:DangerRating") || (elementName as NSString).isEqualToString("DangerRating") {
            dangers = NSMutableDictionary.alloc()
            dangers = [:]
            mainValue = NSMutableString.alloc()
            mainValue = ""
            timeValue = NSMutableString.alloc()
            timeValue = ""
        }
    }
    
    // Checking for special Characters
    func parser(parser: NSXMLParser, foundCharacters string: String?){
        if element.isEqualToString("caaml:highlights") || element.isEqualToString("highlights") {
            highlights.appendString(string!)
        } else if element.isEqualToString("caaml:dateTimeReport") || element.isEqualToString("dateTimeReport") {
            date.appendString(string!)
        } else if element.isEqualToString("caaml:wxSynopsisComment") || element.isEqualToString("wxSynopsisComment") {
            weather.appendString(string!)
        } else if element.isEqualToString("caaml:snowpackStructureComment") || element.isEqualToString("snowpackStructureComment") {
            snowPackStructure.appendString(string!)
        } else if element.isEqualToString("caaml:travelAdvisoryComment") || element.isEqualToString("travelAdvisoryComment") {
            travelAdvisoryComment.appendString(string!)
        } else if element.isEqualToString("caaml:mainValue") || element.isEqualToString("mainValue") {
            mainValue.appendString(string!)
        } else if element.isEqualToString("caaml:timePosition") || element.isEqualToString("timePosition") || element.isEqualToString("caaml:beginPosition") || element.isEqualToString("beginPosition") {
            timeValue.appendString(string!)
        }
    }
    
    // Finished with parsing one Element
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName as NSString).isEqualToString("caaml:Bulletin") || (elementName as NSString).isEqualToString("observations") {
            if !highlights.isEqual(nil) {
                elements.setObject(stringReplacement(highlights), forKey: "highlights")
            }
            if !date.isEqual(nil) {
                elements.setObject(stringReplacement(date).stringByReplacingOccurrencesOfString(" ", withString: ""), forKey: "date")
            }
            if !weather.isEqual(nil) {
                elements.setObject(stringReplacement(weather), forKey: "weather")
            }
            if !snowPackStructure.isEqual(nil) {
                elements.setObject(stringReplacement(snowPackStructure), forKey: "snowPackStructure")
            }
            if !travelAdvisoryComment.isEqual(nil) {
                elements.setObject(stringReplacement(travelAdvisoryComment), forKey: "travelAdvisoryComment")
            }
            posts.addObject(elements)
        } else if (elementName as NSString).isEqualToString("caaml:DangerRating") || (elementName as NSString).isEqualToString("DangerRating") {
            if !mainValue.isEqual(nil) {
                dangers.setObject(mainValue, forKey: "mainValue")
            }
            if !timeValue.isEqual(nil) {
                dangers.setObject(stringReplacement(timeValue).stringByReplacingOccurrencesOfString(" ", withString: ""), forKey: "timeValue")
            }
            dangerPosts.addObject(dangers)
        }
    }
    
    // Filtering out HTML and CSS of String
    func stringReplacement(entered: NSMutableString) -> String {
        var str = String(entered).stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        str = str.stringByReplacingOccurrencesOfString("\\.[^\\}]+\\}", withString: "", options: .RegularExpressionSearch, range: nil)
        str = str.stringByReplacingOccurrencesOfString("\\{[^\\}]+\\}", withString: "", options: .RegularExpressionSearch, range: nil)
        str = str.stringByReplacingOccurrencesOfString("\n", withString: "", options: nil, range: nil)
        str = str.stringByReplacingOccurrencesOfString("!_!", withString: "", options: nil, range: nil)
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return str
    }
    
    // Setting Danger Level
    func setDangerLevel() {
        var maxLevel = "0"
        if ca {
            for var i = 0; i < dangerPosts.count; i = i+3 {
                let elem = dangerPosts[i] as! NSDictionary
                var value = (elem["mainValue"]! as! String).stringByReplacingOccurrencesOfString("\n", withString: "", options: nil, range: nil)
                value = value.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
                if value == "N/A" {
                    maxLevel = "N/A"
                    break
                } else {
                    if let val = value.toInt() {
                        if val > maxLevel.toInt()! {
                            maxLevel = value
                        }
                    }
                }
            }
        } else {
            let date: String = (posts[0]["date"] as! String).stringByPaddingToLength(10, withString: " ", startingAtIndex: 0)
            for elem in dangerPosts {
                let elemDate: String = (elem["timeValue"] as! String).stringByPaddingToLength(10, withString: "", startingAtIndex: 0)
                if date == elemDate {
                    var value = (elem["mainValue"]! as! String).stringByReplacingOccurrencesOfString("\n", withString: "", options: nil, range: nil)
                    value = value.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
                    if value == "N/A" {
                        maxLevel = "N/A"
                        break
                    } else {
                        if let val = value.toInt() {
                            if val > maxLevel.toInt()! {
                                maxLevel = value
                            }
                        }
                    }
                }
            }
        }
        lblDanger.text = "Warnstufe: " + maxLevel
        setImage(maxLevel)
    }
    
    // Setting the Danger Image
    func setImage(danger: String) {
        switch danger {
        case "1":
            self.imDanger.image = UIImage(named: "Danger1")
        case "2":
            self.imDanger.image = UIImage(named: "Danger2")
        case "3":
            self.imDanger.image = UIImage(named: "Danger3")
        case "4":
            self.imDanger.image = UIImage(named: "Danger45")
        case "5":
            self.imDanger.image = UIImage(named: "Danger45")
        default:
            self.imDanger.image = UIImage(named: "Danger0")
        }
    }
}