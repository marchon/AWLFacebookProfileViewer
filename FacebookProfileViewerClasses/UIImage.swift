/// File: UIImage.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 23.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public extension UIImage {
  func imageWithSize(newSize:CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
    self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
    var newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}
