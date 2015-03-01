/// File: LoadMorePostsButton.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 01.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

@IBDesignable
public class LoadMorePostsButton: UIButton {

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  private func setupNib() {
    self.backgroundColor = StyleKit.Palette.baseColor4
    self.tintColor = UIColor.whiteColor()
    //    let img1 = UIImage.imageFromColor(StyleKit.Palette.baseColor4, size: CGSizeMake(1, 1))
    //    let img2 = UIImage.imageFromColor(StyleKit.Palette.baseColor4.darkerColorForColor(), size: CGSizeMake(1, 1))
    //    self.buttonLoadMore.setBackgroundImage(img1, forState: UIControlState.Normal)
    //    self.buttonLoadMore.setBackgroundImage(img1, forState: UIControlState.Disabled)
    //    self.buttonLoadMore.setBackgroundImage(img2, forState: UIControlState.Highlighted)
    //    self.buttonLoadMore.setBackgroundImage(img2, forState: UIControlState.Selected)
    self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
    self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
    self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
  }
  
}