//
//  LoadingProgressView.swift
//  FBPV
//
//  Created by Vlad Gorlov on 01.03.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

public class LoadingProgressView: IBDesignableView {

  override func setupNib() {
    self.backgroundColor = SketchStyleKit.uiPopup.fillColor
    self.layer.cornerRadius = 15
//    self.layer.borderWidth = 1
//    self.layer.borderColor = StyleKit.PopupViews.popupViewBorderColor.CGColor
  }
  
}
