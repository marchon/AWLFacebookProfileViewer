/// File: StyleKit.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 23.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit

public class StyleKit {
  
  public class Palette {
    public class var baseColor1: UIColor {
      return UIColor.fromRGB(0xEF1945)
    }
    public class var baseColor2: UIColor {
      return UIColor.fromRGB(0xF39600)
    }
    public class var baseColor3: UIColor {
      return UIColor.fromRGB(0xE4EFD7)
    }
    public class var baseColor4: UIColor {
      return UIColor.fromRGB(0x44D4C3)
    }
    public class var baseColor5: UIColor {
      return UIColor.fromRGB(0x2B90B3)
    }
  }
  
  public class TableView {
    
    public class var backgroundColor: UIColor {
      return UIColor.fromRGB(0xF9F9F9)
    }
    
    public class var cellBackgroundColor: UIColor {
      return UIColor.fromRGB(0xF9F9F9)
    }
    
    public class var selectedCellBackgroundColor: UIColor {
      return UIColor.fromRGB(0xF2F2F2)
    }
    
    public class var pullToLoadLabelColor: UIColor {
      return UIColor.fromRGB(0x838383)
    }
    
    public class var pullToLoadLabelFont: UIFont {
      return UIFont(name: "OpenSans-Light", size: 17)!
    }

    public class Post {
      public class var titleLabelColor: UIColor {
        return UIColor.fromRGB(0x424242)
      }

      public class var linkTitleLabelColor: UIColor {
        return UIColor.fromRGB(0x7C7C7C)
      }

      public class var linkSubtitleLabelColor: UIColor {
        return UIColor.fromRGB(0x2B8FB3)
      }
    }
  }
  
  public class ProfileView {
    
    public class var avatarBorderColor: UIColor {
      return UIColor.whiteColor()
    }
    
  }

  public class PopupViews {

    public class var popupViewBackgroundColor: UIColor {
      return StyleKit.Palette.baseColor4.colorWithAlphaComponent(0.9)
    }

//    public class var popupViewBorderColor: UIColor {
//      return UIColor.fromRGB(0x6F6F6F)
//    }

  }

}
