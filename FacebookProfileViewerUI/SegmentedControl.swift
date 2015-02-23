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

  public override init(items: [AnyObject]!) {
    super.init(items: items)
    self.setupNib()
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupNib()
  }

  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    self.setupNib()
  }

  func setupNib() {
    var imgDevider = UIImage(named: "segmControlDevider", inBundle:NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection:nil)
    imgDevider = imgDevider?.resizableImageWithCapInsets(UIEdgeInsetsMake(10, 1, 10, 1))
    let imgBg = UIImage(named: "segmControlBackground", inBundle:NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection:nil)
    self.setBackgroundImage(imgBg, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
    self.setBackgroundImage(imgBg, forState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)

    self.setDividerImage(imgDevider, forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
    self.setDividerImage(imgDevider, forLeftSegmentState: UIControlState.Selected, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
    self.setDividerImage(imgDevider, forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
    self.tintColor = UIColor.whiteColor()
  }
  
}
