/// File: UIApplication.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 20.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

private var UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible = 0

public extension UIApplication {
  
  public func showNetworkActivityIndicator() {
    // FIXME: Seems we need to set indicator from Main thread
    UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible++
    self.networkActivityIndicatorVisible = UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible > 0
  }
  
  
  public func hideNetworkActivityIndicator() {
    UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible--
    assert(UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible >= 0, "Unbalanced show/hide calls.")
    self.networkActivityIndicatorVisible = UIApplicationNetworkActivityIndicatorNumberOfCallsToSetVisible > 0
  }
  
}
