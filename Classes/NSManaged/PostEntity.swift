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
public let kPostEntityKeyDescription = "desc"
public let kPostEntityKeySubtitle    = "subtitle"


public class PostEntity: NSManagedObject, DebugPrintable, Equatable {

  /// Graph API Reference Post /post (https://developers.facebook.com/docs/graph-api/reference/v2.2/post)
  /// facebook graph api - What types of posts are in a feed? - Stack Overflow (http://stackoverflow.com/questions/7334689/what-types-of-posts-are-in-a-feed)
  /// Graph API /user/feed (https://developers.facebook.com/docs/graph-api/reference/v2.2/user/feed)
  public enum PostType : String {
    case Link = "link"
    case Status = "status"
    case Photo = "photo"
    case Video = "video"
    case SWF = "swf"
  }

  @NSManaged public var type: String
  @NSManaged public var id: String
  @NSManaged public var createdDate: NSDate
  @NSManaged public var title: String?
  @NSManaged public var pictureURL: String?
  @NSManaged public var pictureData: NSData? // FIXME: Load HiRes images. See: http://stackoverflow.com/a/12154970/1418981
  @NSManaged public var videoURL: String?
  @NSManaged public var desc: String?
  @NSManaged public var subtitle: String?
  
  public override var debugDescription: String {
    var properties = Array<Reflection.Property>()
    properties.append(Reflection.Property(key: kPostEntityKeyTitle, value: self.title ?? "null"))
    properties.append(Reflection.Property(key: kPostEntityKeyType, value: self.type))
    properties.append(Reflection.Property(key: kPostEntityKeyId, value: self.id))
    properties.append(Reflection.Property(key: kPostEntityKeyCreatedDate, value: self.createdDate.description))
    properties.append(Reflection.Property(key: kPostEntityKeyPictureURL, value: self.pictureURL ?? "null"))
    properties.append(Reflection.Property(key: kPostEntityKeyPictureData, value: self.pictureData == nil ? "null" : "\(self.pictureData!.length) bytes"))
    properties.append(Reflection.Property(key: kPostEntityKeyVideoURL, value: self.videoURL ?? "null"))
    properties.append(Reflection.Property(key: kPostEntityKeySubtitle, value: self.subtitle ?? "null"))
    properties.append(Reflection.Property(key: kPostEntityKeyDescription, value: self.desc ?? "null"))
    return Reflection.propertiesToString(properties, multiline: true)
  }

  public class var entityName: String {
    return PostEntity.description().componentsSeparatedByString(".").last!
  }
}

public func ==(lhs: PostEntity, rhs: PostEntity) -> Bool {
  return lhs.title == rhs.title
    && lhs.type == rhs.type
    && lhs.id == rhs.id
    && lhs.createdDate == rhs.createdDate
    && lhs.pictureURL == rhs.pictureURL
    && lhs.pictureData == rhs.pictureData
    && lhs.videoURL == rhs.videoURL
    && lhs.subtitle == rhs.subtitle
    && lhs.desc == rhs.desc
}
