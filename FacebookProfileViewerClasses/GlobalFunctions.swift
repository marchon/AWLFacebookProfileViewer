/// File: GlobalFunctions.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 06.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public func instanceSummary(o: AnyObject, multiline: Bool = true) -> String {
  let mirror = reflect(o)
  var summary = [String]()
  var entryPrefix = multiline ? "\t" : ""
  var entrySeparator = multiline ? ": " : "="
  
  for var i = 0; i < mirror.count; ++i {
    var property = mirror[i]
    summary.append(entryPrefix + property.0 + entrySeparator + property.1.summary)
  }
  
  return multiline ? "{\n" + "\n".join(summary) + "\n}" : "{" + "; ".join(summary) + "}"
}

