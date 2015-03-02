/// File: BackgroundForOverlayErrorView.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 02.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

@IBDesignable
public class BackgroundForOverlayErrorView: UIView {

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  func setupNib() {
    self.backgroundColor = UIColor.fromRGB(0xF39600).colorWithAlphaComponent(0.92)
    self.layer.cornerRadius = 15
  }
  
}
