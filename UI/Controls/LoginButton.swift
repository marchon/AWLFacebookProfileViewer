//
//  LoginButton.swift
//  FBPV
//
//  Created by Volodymyr Gorlov on 27.02.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

public class LoginButton: IBDesignableButton {

  public override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = 0.5 * self.bounds.size.height
  }

  override func setupNib() {
    self.backgroundColor = StyleKit.Palette.baseColor4
  }

}
