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

    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
