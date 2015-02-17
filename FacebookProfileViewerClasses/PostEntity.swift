//
//  PostEntity.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 29.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import Foundation
import CoreData

public let kPostEntityKeyTitle       = "title"
public let kPostEntityKeyType        = "type"
public let kPostEntityKeyId          = "id"
public let kPostEntityKeyCreatedDate = "createdDate"
public let kPostEntityKeyPictureURL  = "pictureURL"
public let kPostEntityKeyPictureData = "pictureData"
public let kPostEntityKeyVideoURL    = "videoURL"


public class PostEntity: NSManagedObject, DebugPrintable, Equatable {
  
  @NSManaged public var title: String
  @NSManaged public var type: String
  @NSManaged public var id: String
  @NSManaged public var createdDate: NSDate
  @NSManaged public var pictureURL: String?
  @NSManaged public var pictureData: NSData?
  @NSManaged public var videoURL: String?
  
  public override var debugDescription: String {
    var properties = Array<Reflection.Property>()
    properties.append(Reflection.Property(key: kPostEntityKeyTitle, value: self.title))
    properties.append(Reflection.Property(key: kPostEntityKeyType, value: self.type))
    properties.append(Reflection.Property(key: kPostEntityKeyId, value: self.id))
    properties.append(Reflection.Property(key: kPostEntityKeyCreatedDate, value: self.createdDate.description))
    properties.append(Reflection.Property(key: kPostEntityKeyPictureURL, value: self.pictureURL?.debugDescription ?? "null"))
    properties.append(Reflection.Property(key: kPostEntityKeyPictureData, value: self.pictureData?.description ?? "null"))
    properties.append(Reflection.Property(key: kPostEntityKeyVideoURL, value: self.videoURL?.debugDescription ?? "null"))
    return Reflection.propertiesToString(properties, multiline: true)
  }
}

public func ==(lhs: PostEntity, rhs: PostEntity) -> Bool {
  return lhs.title == rhs.title && lhs.type == rhs.type
    && lhs.id == rhs.id && lhs.createdDate == rhs.createdDate && lhs.pictureURL == rhs.pictureURL
    && lhs.pictureData == rhs.pictureData && lhs.videoURL == rhs.videoURL
}
