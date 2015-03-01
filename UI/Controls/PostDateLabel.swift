/// File: PostDateLabel.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 01.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

@IBDesignable
public class PostDateLabel : UILabel {

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    setupNib()
  }

  private func setupNib() {
    self.textColor = StyleKit.Palette.baseColor4.darkerColor
  }

}
