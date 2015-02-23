/// File: FriendTableViewCell.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 06.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FacebookProfileViewerClasses

//@IBDesignable
public class FriendTableViewCell : UITableViewCell {

  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
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

  public func setupNib() {
    self.backgroundColor = UIColor.fromRGB(0xF3F3F3)
    self.contentView.backgroundColor = UIColor.clearColor()
    self.textLabel?.backgroundColor = UIColor.clearColor()
  }
  
}