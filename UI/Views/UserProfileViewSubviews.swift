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


@IBDesignable
public class UserProfileAvatarImageView: UIImageView {

  public override var image: UIImage? {
    didSet {
      if self.image != nil {
        self.layer.borderWidth = 1
      } else {
        self.layer.borderWidth = 0
      }
    }
  }

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  private func setupNib() {
    self.backgroundColor = StyleKit.Palette.baseColor5
    self.layer.borderColor = StyleKit.ProfileView.avatarBorderColor.CGColor
    let radius = 0.5 * max(CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds))
    self.layer.cornerRadius = radius
    self.clipsToBounds = true

    if self.isUnderLiveViewTarget {
      var img = IBDesignableHelper.imageNamed("userProfilePhoto")
      self.image = img
    }
  }
  
}
