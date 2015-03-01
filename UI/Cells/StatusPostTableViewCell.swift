/// File: StatusPostTableViewCell.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 06.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import FBPVClasses

@IBDesignable
public class StatusPostTableViewCell : UITableViewCell {

  @IBOutlet public weak var labelDate: UILabel!
  @IBOutlet public weak var labelTitle: UILabel!

  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setupNib()
  }

  public override func prepareForInterfaceBuilder() {
    setupNib()
  }

  private func setupNib() {
    self.backgroundColor = StyleKit.TableView.cellBackgroundColor
    self.contentView.backgroundColor = UIColor.clearColor()
    self.textLabel?.backgroundColor = UIColor.clearColor()
    self.selectedBackgroundView = UIView()
    self.selectedBackgroundView.backgroundColor = StyleKit.TableView.selectedCellBackgroundColor
    self.layoutMargins = UIEdgeInsetsZero
    self.preservesSuperviewLayoutMargins = false
  }
  
}