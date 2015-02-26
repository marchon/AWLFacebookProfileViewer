//
//  LinkPostTableViewCell.swift
//  FacebookProfileViewer
//
//  Created by Volodymyr Gorlov on 25.02.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit

public class LinkPostTableViewCell: PhotoPostTableViewCell {
  
  @IBOutlet public weak var labelLinkText: UILabel!
  @IBOutlet public weak var labelLinkSubtext: UILabel!

  override public func awakeFromNib() {
    super.awakeFromNib()
    self.setupAppearance()
    self.labelLinkText.textColor = StyleKit.TableView.Post.linkTitleLabelColor
    self.labelLinkSubtext.textColor = StyleKit.TableView.Post.linkSubtitleLabelColor
  }

  override public func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

}
