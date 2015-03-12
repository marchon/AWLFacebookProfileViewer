//
// Created by Vlad Gorlov on 12.03.15.
// Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

public class EmptyUserProfileCloudImageView: IBDesignableImageView {

  override func setupNib() {
    if self.isUnderLiveViewTarget {
      self.image = IBDesignableHelper.imageNamed("iconCloud")
    } else {
      self.image = UIImage(named: "iconCloud")
    }
  }
}
