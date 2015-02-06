/// File: PostsTableViewCell.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 06.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses

public class PostsTableViewCell: UITableViewCell {
  
  private class func sharedDateFormatter() -> NSDateFormatter {
    struct Static {
      static var onceToken : dispatch_once_t = 0
      static var instance : NSDateFormatter? = nil
    }
    dispatch_once(&Static.onceToken) {
      let dateFormat = NSDateFormatter.dateFormatFromTemplate("yMMMMd", options: 0, locale: NSLocale.currentLocale())
      let f = NSDateFormatter()
      f.locale = NSLocale.currentLocale()
      f.dateFormat = dateFormat
      Static.instance = f
    }
    return Static.instance!
  }
  
  public var acceciatedObject: Post! {
    didSet {
      self.textLabel?.text = acceciatedObject.title
      if let date = acceciatedObject.createdDate {
        self.detailTextLabel?.text = PostsTableViewCell.sharedDateFormatter().stringFromDate(date)
      }
      self.imageView?.image = acceciatedObject.picture
    }
  }
}
