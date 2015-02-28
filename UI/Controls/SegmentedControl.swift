//
//  SegmentedControl.swift
//  FacebookProfileViewer
//
//  Created by Vlad Gorlov on 22.02.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

@IBDesignable
public class SegmentedControl: UISegmentedControl {

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  private func setupNib() {
    var imgDevider = UIImage(named: "segmControlDevider")
    var imgBg = UIImage(named: "segmControlBackground")

    if self.isUnderLiveViewTarget {
      imgDevider = IBDesignableHelper.imageNamed("segmControlDevider")
      imgBg = IBDesignableHelper.imageNamed("segmControlBackground")
    }

    imgDevider = imgDevider?.resizableImageWithCapInsets(UIEdgeInsetsMake(10, 1, 10, 1))
    self.setBackgroundImage(imgBg, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
    self.setBackgroundImage(imgBg, forState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)

    self.setDividerImage(imgDevider, forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
    self.setDividerImage(imgDevider, forLeftSegmentState: UIControlState.Selected, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
    self.setDividerImage(imgDevider, forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
    self.tintColor = UIColor.whiteColor()
  }

}



