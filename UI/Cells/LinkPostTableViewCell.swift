/// File: LinkPostTableViewCell.swift
/// Project: FBPV
/// Author: Created by Volodymyr Gorlov on 25.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class LinkPostTableViewCell: GenericPostTableViewCell {

  @IBOutlet public weak var labelDate: UILabel!
  @IBOutlet public weak var labelTitle: UILabel!
  
  @IBOutlet public weak var labelLinkText: UILabel!
  @IBOutlet public weak var labelLinkSubtext: UILabel!

  @IBOutlet public weak var imagePhoto: UIImageView!

  @IBOutlet public weak var layoutImageWidth: NSLayoutConstraint!
  @IBOutlet public weak var layoutImageHeight: NSLayoutConstraint!

}
