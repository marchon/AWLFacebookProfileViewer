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
}