/// File: GenericPostTableViewCell.swift
/// Project: FBPV
/// Author: Created by Vlad Gorlov on 01.03.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class GenericPostTableViewCell : IBDesignableTableViewCell {

  override func setupNib() {
    self.backgroundColor = SketchStyleKit.uiTableViewBackground.fillColor
    self.contentView.backgroundColor = UIColor.clearColor()
    self.textLabel?.backgroundColor = UIColor.clearColor()
    self.selectedBackgroundView = UIView()
    self.selectedBackgroundView.backgroundColor = SketchStyleKit.uiSelectedTableViewCellBackground.fillColor
    self.layoutMargins = UIEdgeInsetsZero
    self.preservesSuperviewLayoutMargins = false
  }

}
