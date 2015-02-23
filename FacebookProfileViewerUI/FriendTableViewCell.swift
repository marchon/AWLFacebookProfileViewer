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
    self.backgroundColor = StyleKit.TableView.cellBackgroundColor
    self.contentView.backgroundColor = UIColor.clearColor()
    self.textLabel?.backgroundColor = UIColor.clearColor()
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    if let theView = self.imageView {
      let radius = 0.5 * max(CGRectGetHeight(theView.bounds), CGRectGetWidth(theView.bounds))
      theView.layer.cornerRadius = radius
      theView.clipsToBounds = true
    }
  }
}