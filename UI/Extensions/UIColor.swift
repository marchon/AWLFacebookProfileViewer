/// File: UIColor.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 23.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public extension UIColor {
  public class func fromRGB(hex: Int) -> UIColor {
    let R = CGFloat((hex & 0xFF0000) >> 16) / 255.0
    let G = CGFloat((hex & 0xFF00) >> 8) / 255.0
    let B = CGFloat(hex & 0xFF) / 255.0
    return UIColor(red: R, green: G, blue: B, alpha: 1.0)
  }
  
  public var lighterColor: UIColor {
    var r = CGFloat(0)
    var g = CGFloat(0)
    var b = CGFloat(0)
    var a = CGFloat(0)
    if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
      return UIColor(red: min(r + 0.2, 1.0), green: min(g + 0.2, 1.0), blue: min(b + 0.2, 1.0), alpha: a)
    } else {
      assert(false, "Unable to get lighter color for color: \(self)")
      return self
    }
  }
  
  public var darkerColor: UIColor {
    var r = CGFloat(0)
    var g = CGFloat(0)
    var b = CGFloat(0)
    var a = CGFloat(0)
    if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
      return UIColor(red: min(r - 0.2, 1.0), green: min(g - 0.2, 1.0), blue: min(b - 0.2, 1.0), alpha: a)
    } else {
      assert(false, "Unable to get lighter color for color: \(self)")
      return self
    }
  }
  
}