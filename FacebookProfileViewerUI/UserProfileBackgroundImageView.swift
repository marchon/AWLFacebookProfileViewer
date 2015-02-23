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

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupNib()
  }

  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setupNib()
  }

  public override init(image: UIImage!) {
    super.init(image: image)
    self.setupNib()
  }

  public override init(image: UIImage!, highlightedImage: UIImage?) {
    super.init(image: image, highlightedImage: highlightedImage)
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  func setupNib() {
    self.backgroundColor = UIColor.darkGrayColor()
  }
  
}