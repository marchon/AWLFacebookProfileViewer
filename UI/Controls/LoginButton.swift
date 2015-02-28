//
//  LoginButton.swift
//  FBPV
//
//  Created by Volodymyr Gorlov on 27.02.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

@IBDesignable
public class LoginButton: UIButton {

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = 0.5 * self.bounds.size.height
  }

  private func setupNib() {
    self.backgroundColor = StyleKit.Palette.baseColor4
  }

}
