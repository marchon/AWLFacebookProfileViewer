//
//  Profile.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 29.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import Foundation
import CoreData

public class Profile: NSManagedObject {

    @NSManaged var avatarPicture: NSData
    @NSManaged var userName: String

}
