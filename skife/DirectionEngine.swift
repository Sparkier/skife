//
//  DirectionEngine.swift
//  skife
//
//  Created by Alex Bäuerle on 24.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation
import CoreLocation

enum Direction {
    case Back
    case Left
    case Right
    case Turn
    case Straight
    case Any
}

class DirectionEngine {
    var previousDistances: [CLLocationAccuracy] = []
    var previousDirection: Direction = Direction.Any
    var closestPoint: CLLocationAccuracy = CLLocationAccuracy.infinity
    var inRange: Bool = false
    
    func getDirection() -> Direction {
        if previousDistances.count == 0 {
            return Direction.Any
        }
        else {
            return Direction.Straight
        }
    }
}
