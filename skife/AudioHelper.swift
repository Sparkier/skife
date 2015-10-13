//
//  AudioHelper.swift
//  CarTett
//
//  Created by Andreas Reiter on 20.01.15.
//  Copyright (c) 2015 Uni Ulm. All rights reserved.
//

import Foundation
import AVFoundation

class AudioHelper: NSObject, AVAudioPlayerDelegate{
    
    var audioPlayer = AVAudioPlayer()
    
    override init() {
        super.init()
    }
    
    private func initPlayer(filename: String, type: String){
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(filename, ofType:type)!)
        audioPlayer = try! AVAudioPlayer(contentsOfURL: url)
        audioPlayer.volume = 1.0
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    func playBeep(){
        initPlayer("Beep", type: "mp3")
    }
}