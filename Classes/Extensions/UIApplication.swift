/// File: UIApplication.swift
/// Project: FBPV
/// Author: Created by Volodymyr Gorlov on 20.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

private var UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible = 0

public extension UIApplication {
  
  public func showNetworkActivityIndicator() {
    
    let doStaff: () -> Void = {
      UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible++
      self.networkActivityIndicatorVisible = UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible > 0
    }
    
    if NSThread.isMainThread() {
      doStaff()
    } else {
      dispatch_sync(dispatch_get_main_queue(), doStaff);
    }
  }
  
  
  public func hideNetworkActivityIndicator() {
    
    let doStaff: () -> Void = {
      UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible--
      if UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible < 0 {
        logError("Unbalanced show/hide calls: \(UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible)")
      }
      self.networkActivityIndicatorVisible = UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible > 0
    }
    
    if NSThread.isMainThread() {
      doStaff()
    } else {
      dispatch_sync(dispatch_get_main_queue(), doStaff);
    }
  }
  
}
