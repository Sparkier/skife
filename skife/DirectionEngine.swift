//
//  DirectionEngine.swift
//  skife
//
//  Created by Alex Bäuerle on 24.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation

enum Direction {
    case Back
    case Straight
    case Wrong
    case Any
    case Lost
}

// Engine for resolving the Direction the User has to go
class DirectionEngine {
    var previousDistances: [Double] = []
    var previousDirection: Direction = Direction.Any
    var closestPoint: Double = Double.infinity
    var inRange: Bool = false
    
    func getDirection() -> Direction {
        if previousDistances.count > 2 {
            if !inRange { // Connection Lost
                previousDirection = Direction.Lost
                return previousDirection
            }
            let i = previousDistances.count-1
            let tendency = previousDistances[i] - previousDistances[i-1] + (previousDistances[i-1] - previousDistances[i-2])
            if closestPoint*1.2 < previousDistances.last { // Closest Point Way Closer than Current Point
                previousDirection = Direction.Back
                return previousDirection
            }
            if tendency > 0 { // Tendency Dependant Return
                previousDirection = Direction.Wrong
                return previousDirection
            } else if tendency < 0 {
                previousDirection = Direction.Straight
                return previousDirection
            }
        }
        
        // Return Any if not Anough Samples Collected
        previousDirection = Direction.Any
        return previousDirection
    }
}
