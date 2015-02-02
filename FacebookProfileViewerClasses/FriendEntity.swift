//
//  FriendEntity.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 29.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import Foundation
import CoreData

public class FriendEntity: NSManagedObject {

    @NSManaged var userName: String
    @NSManaged var avatarPicture: NSData

}
