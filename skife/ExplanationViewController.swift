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
    let explanations: NSDictionary = ["Send":"As long as you are on the Broadcast tab, you can be found by your comrades. You can then leave the App and go riding. As soon as you select another tab, the sending process will be stopped.", "Start Searching": "You can start your search simply by going to the Search tab. You will then see all signals in your range. It is recommended to begin your search with an emergency call. The emergency call can be directly started from the top right in the search tab. Once you found the signal you were searching for, you should go to the detailed search by clicking it.", "Locate a Person": "Once you have chosen one signal to follow, you have to minimize your distance to about 5 to 7 meters. This is done by following the instructions shown on your display. Once you are getting really close, instructions disappear and you will need to locate the exact position of the burrowed person by checking distances close to the ground."]
    
    @IBOutlet weak var tvExplanation: UITextView!
    @IBOutlet weak var explanationImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgImg.hidden = true
        
        explanationImage.image = UIImage(named: explanationName)!
        
        tvExplanation.text = explanations.valueForKey(explanationName) as! String
    }
}