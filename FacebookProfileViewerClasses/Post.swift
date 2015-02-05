/// File: Post.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class Post {
  
  public enum PostType : String {
    case Link = "link"
    case Status = "status"
    case Photo = "photo"
    case Video = "video"
    case SWF = "swf"
  }
  
  public var type: PostType!
  public var createdDate: NSDate!
  
  public var isValid: Bool {
    return type != nil && createdDate != nil
  }
  
  public class func postForType(type: PostType, properties: NSDictionary) -> Post {
    switch type {
    case .Link:
      var post = LinkPost()
      if let createdTime = propertyForCreatedTime(properties) {
        post.createdDate = createdTime
      }
      if let value = propertyForMessage(properties) {
        post.title = value
      } else if let value = propertyForStory(properties) {
        post.title = value
      } else if let value = propertyForCaption(properties) {
        post.title = value
      } else if let value = propertyForDescription(properties) {
        post.title = value
      } else if let value = propertyForName(properties) {
        post.title = value
      }
      return post
    case .Status:
      var post = StatusPost()
      if let createdTime = propertyForCreatedTime(properties) {
        post.createdDate = createdTime
      }
      return post
    case .Photo:
      var post = PhotoPost()
      if let createdTime = propertyForCreatedTime(properties) {
        post.createdDate = createdTime
      }
      return post
    case .Video:
      var post = VideoPost()
      if let createdTime = propertyForCreatedTime(properties) {
        post.createdDate = createdTime
      }
      return post
    case .SWF:
      var post = SWFPost()
      if let createdTime = propertyForCreatedTime(properties) {
        post.createdDate = createdTime
      }
      return post
    }
  }
  
  private class func propertyForCreatedTime(properties: NSDictionary) -> NSDate? {
    if let value = properties.valueForKey("created_time") as? String {
      let enUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
      let facebookDateFormatter = NSDateFormatter()
      facebookDateFormatter.locale = enUSPOSIXLocale
      facebookDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
      facebookDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
      let date = facebookDateFormatter.dateFromString(value)
      return date
    }
    return nil
  }
  
  private class func propertyForMessage(properties: NSDictionary) -> String? {
    return properties.valueForKey("message") as? String
  }
  
  private class func propertyForStory(properties: NSDictionary) -> String? {
    return properties.valueForKey("story") as? String
  }
  
  private class func propertyForCaption(properties: NSDictionary) -> String? {
    return properties.valueForKey("caption") as? String
  }

  private class func propertyForDescription(properties: NSDictionary) -> String? {
    return properties.valueForKey("description") as? String
  }

  private class func propertyForName(properties: NSDictionary) -> String? {
    return properties.valueForKey("name") as? String
  }
}


public class LinkPost : Post {
  override public var type: PostType! {
    get {
      return .Link
    }
    set {
    }
  }
  
  public var title: String!
  override public var isValid: Bool {
    return super.isValid && title != nil
  }
}

public class StatusPost : Post {
  override public var type: PostType! {
    get {
      return .Status
    }
    set {
    }
  }
}

public class PhotoPost : Post {
  override public var type: PostType! {
    get {
      return .Photo
    }
    set {
    }
  }
}

public class VideoPost : Post {
  override public var type: PostType! {
    get {
      return .Video
    }
    set {
    }
  }
}

public class SWFPost : Post {
  override public var type: PostType! {
    get {
      return .SWF
    }
    set {
    }
  }
}
