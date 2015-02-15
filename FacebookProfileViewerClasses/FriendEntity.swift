//
//  FriendEntity.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 13.02.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import Foundation
import CoreData

public let kFriendEntityKeyUserName          = "userName"
public let kFriendEntityKeyAvatarPictureData = "avatarPictureData"

public class FriendEntity: NSManagedObject {

  @NSManaged public var userName: String
  @NSManaged public var avatarPictureURL: String
  @NSManaged public var avatarPictureData: NSData?

  public class func fetchRequest() -> NSFetchRequest {
    let entityName = FriendEntity.description().componentsSeparatedByString(".").last!
    return NSFetchRequest(entityName: entityName)
  }

}
