/// File: StatusPostTableViewCell.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 06.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FBPVClasses

//@IBDesignable
public class StatusPostTableViewCell : UITableViewCell {

  @IBOutlet public weak var labelDate: UILabel!
  @IBOutlet public weak var labelTitle: UILabel!
  
//  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//    super.init(style: style, reuseIdentifier: reuseIdentifier)
//    self.setupNib()
//  }
//
//  public override init(frame: CGRect) {
//    super.init(frame: frame)
//    self.setupNib()
//  }
//
//  required public init(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//    self.setupNib()
//  }
//
//  public override func prepareForInterfaceBuilder() {
//    self.setupNib()
//  }

  public func setupAppearance() {
    self.backgroundColor = StyleKit.TableView.cellBackgroundColor
    self.contentView.backgroundColor = UIColor.clearColor()
    self.textLabel?.backgroundColor = UIColor.clearColor()
    self.selectedBackgroundView = UIView()
    self.selectedBackgroundView.backgroundColor = StyleKit.TableView.selectedCellBackgroundColor
    self.labelDate.textColor = StyleKit.Palette.baseColor4.darkerColorForColor()
    self.labelTitle.textColor = StyleKit.TableView.Post.titleLabelColor
    self.layoutMargins = UIEdgeInsetsZero
    self.preservesSuperviewLayoutMargins = false
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupAppearance()
  }
  
}