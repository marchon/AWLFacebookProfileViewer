/// File: UserProfileViewSubviews.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 23.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class UserProfileBackgroundImageView: IBDesignableImageView {

  override func setupNib() {
    self.backgroundColor = SketchStyleKit.paletteColor5Fill.fillColor
    self.clipsToBounds = true

    if self.isUnderLiveViewTarget {
      var img = IBDesignableHelper.imageNamed("userProfileCover")
      self.image = img
    }
  }
  
}

public class UserProfileAvatarImageView: IBDesignableImageView {

  public override var image: UIImage? {
    didSet {
      if self.image != nil {
        self.layer.borderWidth = 1
      } else {
        self.layer.borderWidth = 0
      }
    }
  }

  override func setupNib() {
    self.backgroundColor = SketchStyleKit.paletteColor5Fill.fillColor
    self.layer.borderColor = SketchStyleKit.profileViewAvatarOutline.borderColor.CGColor
    let radius = 0.5 * max(CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds))
    self.layer.cornerRadius = radius
    self.clipsToBounds = true

    if self.isUnderLiveViewTarget {
      var img = IBDesignableHelper.imageNamed("userProfilePhoto")
      self.image = img
    }
  }
  
}

public class UserProfileNameLabel: IBDesignableLabel {
  override func setupNib() {
    self.textColor = SketchStyleKit.profileTitle.textColor
    self.font = SketchStyleKit.profileTitle.font
  }
}

public class UserProfileLocationLabel: IBDesignableLabel {
  override func setupNib() {
    self.textColor = SketchStyleKit.profileLocation.textColor
    self.font = SketchStyleKit.profileLocation.font
  }
}
