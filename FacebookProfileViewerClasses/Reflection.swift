/// File: Reflection.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 16.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class Reflection {
  
  public struct Property {
    var key = ""
    var value = ""
  }
  
  public class func instanceSummary(object: AnyObject, multiline: Bool = true) -> String {
    let properties = instanceProperties(object)
    return propertiesToString(properties, multiline: multiline)
  }
  
  public class func instanceProperties(object: AnyObject) -> [Property] {
    var result = [Property]()
    let mirror = reflect(object)
    for var i = 0; i < mirror.count; ++i {
      var property = mirror[i]
      result.append(Property(key: property.0, value:property.1.summary))
    }
    return result
  }
  
  public class func propertiesToString(properties: [Property], multiline: Bool = true) -> String {
    var summary = [String]()
    var entryPrefix = multiline ? "\t" : ""
    var entrySeparator = multiline ? ": " : "="
    
    for var i = 0; i < properties.count; ++i {
      var property = properties[i]
      summary.append(entryPrefix + property.key + entrySeparator + property.value)
    }
    
    return multiline ? "{\n" + "\n".join(summary) + "\n}" : "{" + "; ".join(summary) + "}"
  }
}