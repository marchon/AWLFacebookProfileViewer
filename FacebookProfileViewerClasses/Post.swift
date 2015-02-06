/// File: Post.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class Post : DebugPrintable {
  
  public var debugDescription: String {
    return instanceSummary(self)
  }
  
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
  
  class func sharedDateFormatter() -> NSDateFormatter {
    struct Static {
      static var onceToken : dispatch_once_t = 0
      static var instance : NSDateFormatter? = nil
    }
    dispatch_once(&Static.onceToken) {
      let facebookDateFormatter = NSDateFormatter()
      facebookDateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
      facebookDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
      facebookDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
      Static.instance = facebookDateFormatter
      
    }
    return Static.instance!
  }
  
  public var type: PostType!
  public var id: String!
  public var title: String!
  public var createdDate: NSDate?
  public var pictureURLString: String?
  public var videoURLString: String?
  public var picture: UIImage?
  
  public var isValid: Bool {
    return id != nil && type != nil && title != nil
  }
  
  public class func postForType(type: PostType, properties: NSDictionary) -> Post {
    var post = Post()
    post.type = type
    
    if let value = properties.valueForKey("created_time") as? String {
      post.createdDate = Post.sharedDateFormatter().dateFromString(value)
    }
    
    if let value = properties.valueForKey("id") as? String {
      post.id = value
    }
    
    if let value = properties.valueForKey("message") as? String {
      post.title = value
    } else if let value = properties.valueForKey("story") as? String {
      post.title = value
    } else if let value = properties.valueForKey("caption") as? String {
      post.title = value
    } else if let value = properties.valueForKey("description") as? String {
      post.title = value
    } else if let value = properties.valueForKey("name") as? String {
      post.title = value
    }
    
    if let value = properties.valueForKey("picture") as? String {
      post.pictureURLString = value
    }
    
    if let value = properties.valueForKey("source") as? String {
      post.videoURLString = value
    }
    
    return post
  }
}
