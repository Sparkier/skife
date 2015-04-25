//
//  DetailedSearchViewController.swift
//  skife
//
//  Created by Alex Bäuerle on 28.02.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import UIKit
import CoreBluetooth

class DetailedSearchViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    var rider: Rider!
    var closeLabel: UILabel!
    var goingBack: Bool = false
    let directionEngine = DirectionEngine()
    var centralManager: CBCentralManager!
    var nsTimer: NSTimer!
    
    @IBOutlet weak var directionImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Set up Close Label
        closeLabel = UILabel(frame: self.view.frame)
        closeLabel.font = closeLabel.font.fontWithSize(50.0)
        closeLabel.textAlignment = NSTextAlignment.Center
        
        nsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("checkRSSI"), userInfo: nil, repeats: true)
    }
    
    // Called when Peripheral disconnects
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        if peripheral == rider.peripheral {
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    // CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            centralManager.connectPeripheral(rider.peripheral, options: nil)
            rider.peripheral!.delegate = self
            println("Power")
        }
    }
    
    // RSSI was Read
    func peripheral(peripheral: CBPeripheral!, didReadRSSI RSSI: NSNumber!, error: NSError!) {
        if rider.peripheral == peripheral {
            rider.RSSI = RSSI
            rider.accuracy = calculateAccuracy(55.0, rssi: Double(RSSI))
            self.distanceLabel.text = "~ \(round(rider.accuracy!*100.0)/100.0) m"
            self.closeLabel.text = "\(round(rider.accuracy!*100.0)/100.0)"
            self.directionEngine.previousDistances.append(rider.accuracy!)
            self.directionEngine.inRange = true
            if directionEngine.closestPoint > rider.accuracy! {
                self.directionEngine.closestPoint = rider.accuracy!
            }
            self.checkDistance()
            self.checkDirection()
        }
    }
    
    // Calculate the Accuracy of Peripheral
    func calculateAccuracy(txPower: Double, rssi: Double) -> Double {
        if rssi == 0 {
            return -1.0
        }
        var ratio: Double = rssi*1.0/txPower
        if ratio < 1.0 {
            return pow(ratio, 10.0)
        } else {
            return ((0.89976) * (pow(ratio,7.7095)) + 0.111)
        }
    }
    
    // Update RSSI of peripheral
    func checkRSSI() {
        rider.peripheral!.readRSSI()
    }
    
    // Checks which Direction the User needs to go
    func checkDirection() {
        // Get Direction from DirectionEngine
        let dir = directionEngine.getDirection()
        if dir == Direction.Any {
            directionLabel.text = "Please go where you think the Sender might be burrowed."
            directionImageView.image = UIImage(named: "AnyDirectionIcon")
        } else if dir == Direction.Lost {
            directionLabel.text = "You lost Connection to the Sender. Please move back to where you had a connection."
            directionImageView.image = UIImage(named: "AnyDirectionIcon")
        } else if dir == Direction.Back {
            self.directionLabel.text = "Turn around and go back to where your distance was about \(round(directionEngine.closestPoint*100.0)/100.0). Then turn left or right."
            directionImageView.image = UIImage(named: "BackDirectionIcon")
        } else if dir == Direction.Straight {
            self.directionLabel.text = "Keep on walking this direction."
            self.view.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
            directionImageView.image = UIImage(named: "CloserDirectionIcon")
        } else if dir == Direction.Wrong {
            self.directionLabel.text = "The distance to the Sender is getting bigger."
            self.view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.3)
            directionImageView.image = UIImage(named: "FurtherDirectionIcon")
        }
    }
    
    // Checks if User is really Close to the Sender
    func checkDistance() {
        let lastDistance = self.directionEngine.previousDistances.last
        if lastDistance <= 3.0 {
            self.distanceLabel.hidden = true
            self.directionImageView.hidden = true
            self.view.addSubview(closeLabel)
        } else if lastDistance > 3.0 {
            self.closeLabel.removeFromSuperview()
            self.distanceLabel.hidden = false
            self.directionImageView.hidden = false
        }
    }
}
