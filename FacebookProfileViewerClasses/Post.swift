/// File: Post.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class Post : DebugPrintable {
  
  public var debugDescription: String {
    let mirror = reflect(self)
    var description = [String]()
    for i in 0 ..< mirror.count {
      let value = mirror[i].1.value
      var summary = mirror[i].1.summary
      if value is PostType {
        summary = (value as PostType).rawValue
      }
      description.append("\t" + mirror[i].0 + ": " + summary)
    }
    return "{\n" + "\n".join(description) + "\n}"
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
  
  public var type: PostType!
  public var id: String!
  public var title: String!
  public var createdDate: NSDate?
  public var pictureURLString: String?
  public var videoURLString: String?
  public var picture: UIImage?
  
  private var isValid: Bool {
    return id != nil && type != nil
  }
  
  public init? (properties: NSDictionary) {
    if let value = properties.valueForKey("type") as? String {
      if let type = Post.PostType(rawValue: value) {
        self.type = type
      }
    }
    
    if let value = properties.valueForKey("id") as? String {
      self.id = value
    }
    
    if let value = properties.valueForKey("created_time") as? String {
      self.createdDate = NSDateFormatter.facebookDateFormatter().dateFromString(value)
    }
    
    if let value = properties.valueForKey("message") as? String {
      self.title = value
    } else if let value = properties.valueForKey("story") as? String {
      self.title = value
    } else if let value = properties.valueForKey("caption") as? String {
      self.title = value
    } else if let value = properties.valueForKey("description") as? String {
      self.title = value
    } else if let value = properties.valueForKey("name") as? String {
      self.title = value
    }
    
    if let value = properties.valueForKey("picture") as? String {
      self.pictureURLString = value
    }
    
    if let value = properties.valueForKey("source") as? String {
      self.videoURLString = value
    }
    
    if !self.isValid {
      return nil
    }
  }
}
