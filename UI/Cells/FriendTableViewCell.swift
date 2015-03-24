/// File: FriendTableViewCell.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 06.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FBPVClasses

public class FriendTableViewCell : IBDesignableTableViewCell {

  public override func layoutSubviews() {
    super.layoutSubviews()
    if let theView = self.imageView {
      let radius = 0.5 * max(CGRectGetHeight(theView.bounds), CGRectGetWidth(theView.bounds))
      theView.layer.cornerRadius = radius
      theView.clipsToBounds = true
    }
  }

  override func setupNib() {
    self.backgroundColor = StyleKitExport.uiTableViewBackground.fillColor
    self.contentView.backgroundColor = UIColor.clearColor()
    self.textLabel?.backgroundColor = UIColor.clearColor()
    self.selectedBackgroundView = UIView()
    self.selectedBackgroundView.backgroundColor = StyleKitExport.uiSelectedTableViewCellBackground.fillColor
  }

}