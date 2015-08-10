//
//  ExplanationViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 20.06.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

class ExplanationViewController: BaseViewController {
    
    var explanationName: String!
    
    @IBOutlet weak var tvExplanation: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedString = NSMutableAttributedString(string: "before after")
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: explanationName)!
        
        let oldWidth = textAttachment.image!.size.width;
        
        //I'm subtracting 10px to make the image display nicely, accounting
        //for the padding inside the textView
        let scaleFactor = (tvExplanation.frame.size.width - 10) / oldWidth
        textAttachment.image = UIImage(CGImage: textAttachment.image!.CGImage, scale: scaleFactor, orientation: .Up)
        var attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.appendAttributedString(attrStringWithImage)
        tvExplanation.attributedText = attributedString;
    }
}