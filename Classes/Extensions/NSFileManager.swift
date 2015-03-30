/// File: NSFileManager.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 13.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public extension NSFileManager {
  public class var applicationDocumentsDirectory: NSURL {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "ua.com.wavelabs.FacebookProfileViewer" in the application's documents Application Support directory.
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1] as! NSURL
    }
}
