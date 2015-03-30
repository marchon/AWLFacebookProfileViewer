/// File: OverlayErrorViewSubviews.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 02.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class OverlayErrorBackgroundView: IBDesignableView {

  override func setupNib() {
    self.backgroundColor = UIColor.fromRGB(0xF39600).colorWithAlphaComponent(0.92)
    self.layer.cornerRadius = 15
  }
  
}

public class OverlayErrorIconImageView: IBDesignableImageView {

  override func setupNib() {
    if self.isUnderLiveViewTarget {
      self.image = IBDesignableHelper.imageNamed("iconGears")
    } else {
      self.image = UIImage(named: "iconGears")
    }
  }
  
}
