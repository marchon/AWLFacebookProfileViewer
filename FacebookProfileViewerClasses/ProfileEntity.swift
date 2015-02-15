//
//  ProfileEntity.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 29.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import Foundation
import CoreData

public class ProfileEntity: NSManagedObject {

  @NSManaged public var userName: String
  @NSManaged public var coverPhotoData: NSData?
  @NSManaged public var avatarPictureData: NSData?
  @NSManaged public var homeTown: String?

}
