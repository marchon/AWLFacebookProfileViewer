//
//  PhotoPostTableViewCell.swift
//  FacebookProfileViewer
//
//  Created by Volodymyr Gorlov on 25.02.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

public class PhotoPostTableViewCell: UITableViewCell {
  
  @IBOutlet public weak var labelDate: UILabel!
  @IBOutlet public weak var labelTitle: UILabel!
  @IBOutlet public weak var imagePhoto: UIImageView!
  
  @IBOutlet public weak var layoutImageWidth: NSLayoutConstraint!
  @IBOutlet public weak var layoutImageHeight: NSLayoutConstraint!

  override public func awakeFromNib() {
    super.awakeFromNib()
    self.setupAppearance()
  }

  override public func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  public func setupAppearance() {
    self.backgroundColor = StyleKit.TableView.cellBackgroundColor
    self.contentView.backgroundColor = UIColor.clearColor()
    self.textLabel?.backgroundColor = UIColor.clearColor()
    self.selectedBackgroundView = UIView()
    self.selectedBackgroundView.backgroundColor = StyleKit.TableView.selectedCellBackgroundColor
    self.labelDate.textColor = StyleKit.Palette.baseColor4.darkerColor
    self.labelTitle.textColor = StyleKit.TableView.Post.titleLabelColor
    self.layoutMargins = UIEdgeInsetsZero
    self.preservesSuperviewLayoutMargins = false
  }

}
