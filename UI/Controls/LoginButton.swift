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
  
  public override func prepareForInterfaceBuilder() {
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = 0.5 * self.bounds.size.height
    self.backgroundColor = StyleKit.Palette.baseColor4
  }
  
}
