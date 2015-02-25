/// File: NSDateFormatter.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 10.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public extension NSDateFormatter {

  public class func facebookDateFormatter() -> NSDateFormatter {
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


  public class func refreshControlDateFormatter() -> NSDateFormatter {
    struct Static {
      static var onceToken : dispatch_once_t = 0
      static var instance : NSDateFormatter? = nil
    }
    dispatch_once(&Static.onceToken) {
      var theTemplate = "yMMMMdhm"
#if DEBUG
      theTemplate += "s"
#endif
      let dateFormat = NSDateFormatter.dateFormatFromTemplate(theTemplate, options: 0, locale: NSLocale.currentLocale())
      let f = NSDateFormatter()
      f.locale = NSLocale.currentLocale()
      f.dateFormat = dateFormat
      Static.instance = f
    }
    return Static.instance!
  }


}
