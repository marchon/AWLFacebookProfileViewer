//
// Created by Vlad Gorlov on 12.03.15.
// Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

@IBDesignable
public class IBDesignableImageView : UIImageView {

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  func setupNib() {
  }

}
