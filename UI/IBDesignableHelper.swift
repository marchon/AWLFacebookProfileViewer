/// File: IBDesignableHelper.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 28.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class IBDesignableHelper {

  public class func resourcePathForResourceName(resourceName: String) -> String? {

    if let projectSourceDirectoriesValue = NSProcessInfo.processInfo().environment["IB_PROJECT_SOURCE_DIRECTORIES"] as? String {
      let projectSourceDirectories = projectSourceDirectoriesValue.componentsSeparatedByString(",")
      for projectSourceDirectory in projectSourceDirectories {
        if let enumerator = NSFileManager.defaultManager().enumeratorAtPath(projectSourceDirectory) {
          var file: String?
          while let file = enumerator.nextObject() as? String {
            if file.hasPrefix(".") {
              continue
            }
            var baseName = file.lastPathComponent
            if baseName == resourceName {
              return projectSourceDirectory.stringByAppendingPathComponent(file)
            }
            else {
              continue
            }
          }
        }
      }
    }
    return nil
  }

  public class func imageNamed(name: String, scaleFactor: Int = 2) -> UIImage? {

    if let imagesetPath = IBDesignableHelper.resourcePathForResourceName("\(name).imageset") {
      let JSONPath = imagesetPath.stringByAppendingPathComponent("Contents.json")
      if !NSFileManager.defaultManager().fileExistsAtPath(JSONPath) {
        return nil
      }
      var foundImagePath: String?
      if let JSONData = NSData(contentsOfFile: JSONPath),
        let JSONObject = NSJSONSerialization.JSONObjectWithData(JSONData, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary,
        let images = JSONObject.valueForKey("images") as? NSArray {
          for image in images {
            if let scale = image.valueForKey("scale") as? String,
              let filename = image.valueForKey("filename") as? String {
                if scale == "\(scaleFactor)x" {
                  foundImagePath = imagesetPath.stringByAppendingPathComponent(filename)
                  break
                }
            }
          }
      }
      if let imagePath = foundImagePath,
        let image = UIImage(contentsOfFile: imagePath) {
          return image
      }
    }

    return nil
  }

}
