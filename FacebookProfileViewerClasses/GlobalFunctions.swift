/// File: GlobalFunctions.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 06.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public func instanceSummary(o: AnyObject, multiline: Bool = true) -> String {
  let mirror = reflect(o)
  var summary = [String]()
  if multiline {
    for var i = 0; i < mirror.count; ++i {
      var property = mirror[i]
      summary.append("\t" + property.0 + ": " + property.1.summary + "")
    }
    return "{\n" + "\n".join(summary) + "\n}"
  } else {
    for var i = 0; i < mirror.count; ++i {
      var property = mirror[i]
      summary.append(property.0 + "=" + property.1.summary)
    }
    return "{" + "; ".join(summary) + "}"
  }
}

