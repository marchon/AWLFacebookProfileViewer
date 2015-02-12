/// File: FetchChunk.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 10.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class FetchChunk {
  public var startDate: NSDate
  public var endDate: NSDate

  public init () {
    startDate = NSDate()
    endDate = startDate
  }

  convenience init (dictionary: [String: NSDate]) {
    self.init()
    if let date = dictionary["startDate"] {
      startDate = date
    }
    if let date = dictionary["endDate"] {
      endDate = date
    }
  }

  var dictionaryRepresentation: [String: NSDate] {
    return ["startDate" : self.startDate, "endDate" : self.endDate]
  }
}
