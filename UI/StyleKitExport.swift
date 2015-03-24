//
// File: StyleKitExport.swift
//
// NOTE:
// File automatically generated by "SketchStyleKitExport.php" tool.
// Any modification will lost on next export!

import UIKit

private extension UIColor {
  class func fromRGB(hex: Int) -> UIColor {
    let R = CGFloat((hex & 0xFF0000) >> 16) / 255.0
    let G = CGFloat((hex & 0xFF00) >> 8) / 255.0
    let B = CGFloat(hex & 0xFF) / 255.0
    return UIColor(red: R, green: G, blue: B, alpha: 1.0)
  }
}

public class StyleKitExport {
    
    // LayerStyle: "Icon: Background"
    public class iconBackground {
        public var fillColor: UIColor {
            return UIColor.fromRGB(0x44D3C2)
        }
    }

    // LayerStyle: "UI: Popup"
    public class uIPopup {
        public var fillColor: UIColor {
            return UIColor(red: 68 / 255.0, green: 211 / 255.0, blue: 194 / 255.0, alpha: 0.89)
        }
    }

    // LayerStyle: "UI: TableView Background"
    public class uITableViewBackground {
        public var fillColor: UIColor {
            return UIColor.fromRGB(0xF9F9F9)
        }
    }

    // LayerTextStyle: "Post: Date"
    public class postDate {
        public var font: UIFont {
            return UIFont(name: "OpenSans", size: 22)!
        }
        public var textColor: UIColor {
            return UIColor(red: 0.271518, green: 0.707377, blue: 0.655574, alpha: 1.000000)
        }
    }

    // LayerTextStyle: "Post: Title"
    public class postTitle {
        public var font: UIFont {
            return UIFont(name: "OpenSans", size: 26)!
        }
        public var textColor: UIColor {
            return UIColor(red: 0.258238, green: 0.258238, blue: 0.258238, alpha: 1.000000)
        }
    }

}
