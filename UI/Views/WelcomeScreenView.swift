/// File: WelcomeScreenView.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 01.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

@IBDesignable
public class WelcomeScreenView: UIView {

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  func setupNib() {
    self.backgroundColor = StyleKit.Palette.baseColor5
  }

}
