/// File: NSURL.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 01.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

public extension NSURL {
  
  // Every element is a string in key=value format
  public class func requestQueryFromParameters(elements: [String]) -> String {
    if elements.count > 0 {
      return elements[1..<elements.count].reduce(elements[0], {$0 + "&" + $1})
    } else {
      return elements[0]
    }
  }
}
