//
//  LoadMorePostsView.swift
//  FacebookProfileViewer
//
//  Created by Volodymyr Gorlov on 24.02.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

public class LoadMorePostsView: UIView {
  
  @IBOutlet public weak var buttonLoadMore: UIButton!

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.buttonLoadMore.backgroundColor = StyleKit.Palette.baseColor4
    self.buttonLoadMore.tintColor = UIColor.whiteColor()
//    let img1 = UIImage.imageFromColor(StyleKit.Palette.baseColor4, size: CGSizeMake(1, 1))
//    let img2 = UIImage.imageFromColor(StyleKit.Palette.baseColor4.darkerColorForColor(), size: CGSizeMake(1, 1))
//    self.buttonLoadMore.setBackgroundImage(img1, forState: UIControlState.Normal)
//    self.buttonLoadMore.setBackgroundImage(img1, forState: UIControlState.Disabled)
//    self.buttonLoadMore.setBackgroundImage(img2, forState: UIControlState.Highlighted)
//    self.buttonLoadMore.setBackgroundImage(img2, forState: UIControlState.Selected)
    self.buttonLoadMore.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    self.buttonLoadMore.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
    self.buttonLoadMore.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
    self.buttonLoadMore.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
  }

}
