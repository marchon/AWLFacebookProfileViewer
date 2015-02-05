/// File: Post.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class Post {
  
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
  
  public var type: PostType!
  public var createdDate: NSDate!
  public var id: String!
  
  public var isValid: Bool {
    return type != nil && createdDate != nil && id != nil
  }
  
  public class func postForType(type: PostType, properties: NSDictionary) -> Post {
    switch type {
    case .Link:
      var post = LinkPost()
      if let createdTime = propertyForCreatedTime(properties) {
        post.createdDate = createdTime
      }
      if let value = propertyForID(properties) {
        post.id = value
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
      if let value = propertyForID(properties) {
        post.id = value
      }
      if let value = propertyForMessage(properties) {
        post.title = value
      } else if let value = propertyForStory(properties) {
        post.title = value
      }
      return post
    case .Photo:
      var post = PhotoPost()
      if let createdTime = propertyForCreatedTime(properties) {
        post.createdDate = createdTime
      }
      if let value = propertyForID(properties) {
        post.id = value
      }
      if let value = propertyForMessage(properties) {
        post.title = value
      } else if let value = propertyForStory(properties) {
        post.title = value
      } else if let value = propertyForDescription(properties) {
        post.title = value
      } else if let value = propertyForName(properties) {
        post.title = value
      }
      if let value = propertyForPicture(properties) {
        post.pictureURLString = value
      }
      return post
    case .Video:
      var post = VideoPost()
      if let createdTime = propertyForCreatedTime(properties) {
        post.createdDate = createdTime
      }
      if let value = propertyForID(properties) {
        post.id = value
      }
      if let value = propertyForMessage(properties) {
        post.title = value
      } else if let value = propertyForStory(properties) {
        post.title = value
      } else if let value = propertyForDescription(properties) {
        post.title = value
      } else if let value = propertyForName(properties) {
        post.title = value
      }
      if let value = propertyForPicture(properties) {
        post.pictureURLString = value
      }
      if let value = propertyForSource(properties) {
        post.videoURLString = value
      }
      return post
    case .SWF:
      var post = SWFPost()
      if let createdTime = propertyForCreatedTime(properties) {
        post.createdDate = createdTime
      }
      if let value = propertyForID(properties) {
        post.id = value
      }
      if let value = propertyForMessage(properties) {
        post.title = value
      } else if let value = propertyForStory(properties) {
        post.title = value
      } else if let value = propertyForDescription(properties) {
        post.title = value
      } else if let value = propertyForName(properties) {
        post.title = value
      }
      if let value = propertyForPicture(properties) {
        post.pictureURLString = value
      }
      if let value = propertyForSource(properties) {
        post.videoURLString = value
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
  
  private class func propertyForPicture(properties: NSDictionary) -> String? {
    return properties.valueForKey("picture") as? String
  }
  
  private class func propertyForSource(properties: NSDictionary) -> String? {
    return properties.valueForKey("source") as? String
  }
  
  private class func propertyForID(properties: NSDictionary) -> String? {
    return properties.valueForKey("id") as? String
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
  
  public var title: String!
  override public var isValid: Bool {
    return super.isValid && title != nil
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
  
  public var title: String!
  public var pictureURLString: String!
  
  override public var isValid: Bool {
    return super.isValid && title != nil && pictureURLString != nil
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
  
  public var title: String!
  public var pictureURLString: String!
  public var videoURLString: String!
  
  override public var isValid: Bool {
    return super.isValid && title != nil && pictureURLString != nil && videoURLString != nil
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
  
  public var title: String!
  public var pictureURLString: String!
  public var videoURLString: String!
  
  override public var isValid: Bool {
    return super.isValid && title != nil && pictureURLString != nil && videoURLString != nil
  }
}
