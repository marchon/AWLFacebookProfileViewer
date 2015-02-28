/// File: UIView.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 28.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

extension UIView {

  var isUnderLiveViewTarget: Bool {
#if TARGET_INTERFACE_BUILDER
    return true
#endif
    return false
  }

}
