/// File: NSDictionary.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 04.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

extension NSDictionary {
  func hasKey(key: String) -> Bool {
    return self.allKeys.filter({
      (element: AnyObject) -> Bool in
      return (element as! String) == key
    }).count == 1
  }
}
