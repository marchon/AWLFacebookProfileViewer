/// File: PostLinkSubtitleLabel.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 01.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class PostLinkSubtitleLabel : IBDesignableLabel {

  override func setupNib() {
    self.textColor = SketchStyleKit.postLinkSubtitle.textColor
  }
  
}
