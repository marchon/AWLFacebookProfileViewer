//
//  AvatarImageView.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 23.02.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

@IBDesignable
public class UserProfileAvatarImageView: UIImageView {

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  private func setupNib() {
    self.backgroundColor = StyleKit.Palette.baseColor5

    if self.isUnderLiveViewTarget {
      var img = IBDesignableHelper.imageNamed("userProfilePhoto")
      self.image = img
    }
  }

}
