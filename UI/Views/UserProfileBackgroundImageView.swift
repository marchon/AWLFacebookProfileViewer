//
//  UserProfileBackgroundImageView.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 23.02.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

@IBDesignable
public class UserProfileBackgroundImageView: UIImageView {

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  func setupNib() {
    self.backgroundColor = StyleKit.Palette.baseColor5
    self.clipsToBounds = true


    if self.isUnderLiveViewTarget {
      var img = IBDesignableHelper.imageNamed("userProfileCover")
      self.image = img
    }
  }
  
}
