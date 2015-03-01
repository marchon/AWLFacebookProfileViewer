//
//  LoadingProgressView.swift
//  FBPV
//
//  Created by Vlad Gorlov on 01.03.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

@IBDesignable
public class LoadingProgressView: UIView {

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  private func setupNib() {
    self.backgroundColor = StyleKit.Palette.baseColor5
    self.layer.cornerRadius = 10
  }
  
}