//
//  Profile.swift
//  skife
//
//  Created by Alex Bäuerle on 12.03.15.
//  Copyright (c) 2015 Alex Bäuerle. All rights reserved.
//

import Foundation
import CoreData

@objc(Profile)
class Profile: NSManagedObject {
    @NSManaged var name: String
}
