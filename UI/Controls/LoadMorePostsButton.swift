/// File: LoadMorePostsButton.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 01.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class LoadMorePostsButton: IBDesignableButton {
  
  override func setupNib() {
    self.backgroundColor = SketchStyleKit.paletteColor4Fill.fillColor
    self.tintColor = UIColor.whiteColor()
    //    let img1 = UIImage.imageFromColor(SketchStyleKit.paletteColor4Fill.fillColor, size: CGSizeMake(1, 1))
    //    let img2 = UIImage.imageFromColor(SketchStyleKit.paletteColor4Fill.fillColor.darkerColorForColor(), size: CGSizeMake(1, 1))
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