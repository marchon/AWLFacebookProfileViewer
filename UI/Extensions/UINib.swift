/// File: UINib.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 01.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public extension UINib {
  
  public class func nibForClass(forClass: AnyClass) -> UINib {
    let name = NSStringFromClass(forClass).componentsSeparatedByString(".").last!
    let bundle = NSBundle(forClass: forClass)
    return UINib(nibName: name, bundle: bundle)
  }
  
}
