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
public let kFriendEntityKeyAvatarPictureURL  = "avatarPictureURL"
public let kFriendEntityKeyAvatarPictureData = "avatarPictureData"
public let kFriendEntityKeyAvatarPictureIsSilhouette = "avatarPictureIsSilhouette"

public class FriendEntity: NSManagedObject, DebugPrintable, Equatable {

  @NSManaged public var userName: String
  @NSManaged public var avatarPictureIsSilhouette: Bool
  @NSManaged public var avatarPictureURL: String
  @NSManaged public var avatarPictureData: NSData?
  
  public override var debugDescription: String {
    var properties = Array<Reflection.Property>()
    properties.append(Reflection.Property(key: kFriendEntityKeyUserName, value: self.userName))
    properties.append(Reflection.Property(key: kFriendEntityKeyAvatarPictureIsSilhouette, value: "\(self.avatarPictureIsSilhouette)"))
    properties.append(Reflection.Property(key: kFriendEntityKeyAvatarPictureURL, value: self.avatarPictureURL))
    properties.append(Reflection.Property(key: kFriendEntityKeyAvatarPictureData, value: self.avatarPictureData == nil ? "null" : "\(self.avatarPictureData!.length) bytes"))
    return Reflection.propertiesToString(properties, multiline: true)
  }
}

public func ==(lhs: FriendEntity, rhs: FriendEntity) -> Bool {
  return lhs.userName == rhs.userName && lhs.avatarPictureURL == rhs.avatarPictureURL
    && lhs.avatarPictureData == rhs.avatarPictureData && lhs.avatarPictureIsSilhouette == rhs.avatarPictureIsSilhouette
}
