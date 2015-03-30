/// File: ProfileEntity.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation
import CoreData

public let kProfileEntityKeyUserName          = "userName"
public let kProfileEntityKeyCoverPhotoData    = "coverPhotoData"
public let kProfileEntityKeyAvatarPictureData = "avatarPictureData"
public let kProfileEntityKeyHomeTown          = "homeTown"

public class ProfileEntity: NSManagedObject, DebugPrintable, Equatable {

  @NSManaged public var userName: String
  @NSManaged public var coverPhotoData: NSData?
  @NSManaged public var avatarPictureData: NSData?
  @NSManaged public var homeTown: String?

  public override var debugDescription: String {
    var properties = Array<Reflection.Property>()
    properties.append(Reflection.Property(key: kProfileEntityKeyUserName, value: self.userName))
    properties.append(Reflection.Property(key: kProfileEntityKeyCoverPhotoData, value: self.coverPhotoData?.description ?? "null"))
    properties.append(Reflection.Property(key: kProfileEntityKeyAvatarPictureData, value: self.avatarPictureData?.description ?? "null"))
    properties.append(Reflection.Property(key: kProfileEntityKeyHomeTown, value: self.homeTown ?? "null"))
    return Reflection.propertiesToString(properties, multiline: true)
  }
}

public func ==(lhs: ProfileEntity, rhs: ProfileEntity) -> Bool {
  return lhs.userName == rhs.userName && lhs.coverPhotoData == rhs.coverPhotoData
    && lhs.avatarPictureData == rhs.avatarPictureData && lhs.homeTown == rhs.homeTown
}

