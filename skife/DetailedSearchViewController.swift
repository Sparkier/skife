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
    var rollingRssi: Double!
    var nsTimer: NSTimer!
    var notIncluded = [Double]()
    lazy var noBluetoothView = NoBluetoothView()
    var peripherals = [CBPeripheral]()
    
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
        
        nsTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("checkRSSI"), userInfo: nil, repeats: true)
    }
    
    // Found IPhone
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        // For not getting the same Peripheral twice
        var doubleID = false
        if rider.peripheral!.identifier == peripheral.identifier {
            doubleID = true
        }
        if !doubleID {
            peripherals.append(peripheral)
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    // Called When Peripheral gets disconnected, reconnecting it
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    // Called after Peripheral Connected, discovering Services
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "109F17E4-EF68-43FC-957D-502BB0EFCF46")])
    }
    
    // Called When Services are Dicovered, discovering Characteristics
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service in peripheral.services {
            peripheral.discoverCharacteristics([CBUUID(string: "F2AF77EC-2F1F-4B20-8075-3E69A4B60C53"),CBUUID(string: "F0FEDD89-1BF5-43B7-86D2-ABF53CD0A004")], forService: service as! CBService)
        }
    }
    
    // Called When Cahracteristics are Discovered, reading Values
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        peripheral.readValueForCharacteristic(service.characteristics[1] as! CBCharacteristic)
    }
    
    // Called When Values are updated
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        // Identifier Characteristic
        if characteristic.UUID == CBUUID(string: "F0FEDD89-1BF5-43B7-86D2-ABF53CD0A004") {
            if characteristic.value != nil {
                let identifier = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)!
                let service = peripheral.services[0] as! CBService
                let char = service.characteristics[0] as! CBCharacteristic
                var existing = false
                if rider.identifier == identifier as! String {
                    existing = true
                    rider.peripheral = peripheral
                    peripheral.readValueForCharacteristic(char)
                }
            }
        }
        // Name Characteristic
        if characteristic.UUID == CBUUID(string: "F2AF77EC-2F1F-4B20-8075-3E69A4B60C53") {
            if characteristic.value != nil {
                let name = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)!
                if rider.peripheral == peripheral {
                    rider.name = name as! String
                }
            }
        }
    }
    
    // CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            centralManager.connectPeripheral(rider.peripheral, options: nil)
            rider.peripheral!.delegate = self
            self.noBluetoothView.removeFromSuperview()
        } else {
            self.view.addSubview(noBluetoothView)
        }
    }
    
    // RSSI was Read
    func peripheral(peripheral: CBPeripheral!, didReadRSSI RSSI: NSNumber!, error: NSError!) {
        if rider.peripheral == peripheral && RSSI != nil {
            rollingRssi = (Double(RSSI) * 0.1)+(rollingRssi * (1.0-0.1))
            if notIncluded.count == 3 {
                rider.RSSI = rollingRssi
                rider.accuracy = calculateAccuracy(70.0, rssi: rollingRssi)
                notIncluded = []
            } else {
                if (rollingRssi * 1.5) > rider.RSSI || (rollingRssi * 0.5) < rider.RSSI {
                    notIncluded.append(rollingRssi)
                } else {
                    rider.RSSI = rollingRssi
                    rider.accuracy = calculateAccuracy(70.0, rssi: rollingRssi)
                    notIncluded = []
                }
            }
            if let acc = rider.accuracy {
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
            self.distanceLabel.textColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
            directionImageView.image = UIImage(named: "CloserDirectionIcon")
        } else if dir == Direction.Wrong {
            self.directionLabel.text = "The distance to the Sender is getting bigger."
            self.distanceLabel.textColor = UIColor.redColor().colorWithAlphaComponent(0.3)
            directionImageView.image = UIImage(named: "FurtherDirectionIcon")
        }
    }
    
    // Checks if User is really Close to the Sender
    func checkDistance() {
        let lastDistance = self.directionEngine.previousDistances.last
        if lastDistance <= 3.0 {
            self.distanceLabel.hidden = true
            self.directionImageView.hidden = true
            self.directionLabel.hidden = true
            self.view.addSubview(closeLabel)
        } else if lastDistance > 3.0 {
            self.closeLabel.removeFromSuperview()
            self.distanceLabel.hidden = false
            self.directionLabel.hidden = false
            self.directionImageView.hidden = false
        }
    }
}