/// File: NSDate.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 10.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public extension NSDate {
  var timeIntervalSince1970AsString : String {
    return NSString(format: "%.0f", self.timeIntervalSince1970) as! String
  }
}
