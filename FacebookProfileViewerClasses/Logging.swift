/// File: Logging.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

extension UIColor {
  var consoleColor: String {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    self.getRed(&r, green: &g, blue: &b, alpha: &a)
    return "\(Int(255 * r)),\(Int(255 * g)),\(Int(255 * b))"
  }
}

struct ColorLog {

  static let kGlobalContextCode = "GLOB"

  enum LogLevel : String {
    case Error   = "E"
    case Warn    = "W"
    case Info    = "I"
    case Debug   = "D"
    case Verbose = "V"
  }

  static let colorError   = UIColor(red:0.831, green:0.184, blue:0.468, alpha:1)
  static let colorWarn    = UIColor(red:0.953, green:0.788, blue:0.3,   alpha:1)
  static let colorInfo    = UIColor(red:0.3,   green:0.589, blue:0.593, alpha:1)
  static let colorDebug   = UIColor(red:0.679, green:0.513, blue:0.306, alpha:1)
  static let colorVerbose = UIColor(red:0.523, green:0.809, blue:0.41,  alpha:1)

  static let colorDefault    = UIColor(red:0.458, green:0.458, blue:0.458,  alpha:1)
  static let colorLocation   = UIColor(red:0.704, green:0.704, blue:0.704,  alpha:1)
  static let colorSeparator  = UIColor(red:0.608, green:0.608, blue:0.608,  alpha:1)

  static let ESCAPE = "\u{001b}["
  static let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
  static let RESET_BG = ESCAPE + "bg;" // Clear any background color
  static let RESET    = ESCAPE + ";"   // Clear any foreground or background color

  static var consoleColorError: String = {
    return ESCAPE + "fg" + colorError.consoleColor + ";"
    }()
  static var consoleColorWarn: String = {
    return ESCAPE + "fg" + colorWarn.consoleColor + ";"
    }()
  static var consoleColorInfo: String = {
    return ESCAPE + "fg" + colorInfo.consoleColor + ";"
    }()
  static var consoleColorDebug: String = {
    return ESCAPE + "fg" + colorDebug.consoleColor + ";"
    }()
  static var consoleColorVerbose: String = {
    return ESCAPE + "fg" + colorVerbose.consoleColor + ";"
    }()

  static var cDefaultBegin: String = {
    return ESCAPE + "fg" + colorDefault.consoleColor + ";"
    }()
  static var cLocationBegin: String = {
    return ESCAPE + "fg" + colorLocation.consoleColor + ";"
    }()
  static var cSeparatorBegin: String = {
    return ESCAPE + "fg" + colorSeparator.consoleColor + ";"
    }()
  static var cDefaultEnd: String   = ESCAPE + "fg;"
  static var cLocationEnd: String  = ESCAPE + "fg;"
  static var cSeparatorEnd: String = ESCAPE + "fg;"

  static var isEnabledXcodeColors: Bool = {
    let XcodeColorsValue = NSProcessInfo.processInfo().environment["XcodeColors"] as? String
    return XcodeColorsValue == "YES"
    }()

  static func logMessage<T>(message: T, level: LogLevel, context: String, function: String, file: String, line: Int32) {
    assert(context.length == 4, "Context should be 4 letters lenght")
    var theLevel                = level.rawValue
    var theContext              = context
    var theFunction             = function
    var theFile                 = "\(file):\(line)"
    var theMessage              = "\(message)"
    var separatorPrefix         = "|"
    var separatorContext        = ":"
    var separatorLocation       = ";"
    var separatorLocationBegin  = "<"
    var separatorLocationEnd    = ">"

    if isEnabledXcodeColors {
      theFunction = "\(cLocationBegin)\(theFunction)\(cLocationEnd)"
      theFile     = "\(cLocationBegin)\(theFile)\(cLocationEnd)"
      separatorContext = cSeparatorBegin + separatorContext + cSeparatorEnd
      separatorLocation = cSeparatorBegin + separatorLocation + cSeparatorEnd
      separatorLocationBegin = cSeparatorBegin + separatorLocationBegin + cSeparatorEnd
      separatorLocationEnd = cSeparatorBegin + separatorLocationEnd + cSeparatorEnd
      var prefix: String
      switch (level) {
      case .Error:
        prefix = consoleColorError
      case .Warn:
        prefix = consoleColorWarn
      case .Info:
        prefix = consoleColorInfo
      case .Debug:
        prefix = consoleColorDebug
      case .Verbose:
        prefix = consoleColorVerbose
      }
      theLevel   = "\(prefix)\(theLevel)\(RESET_FG)"
      separatorPrefix = prefix + separatorPrefix + RESET_FG

      if context != kGlobalContextCode {
        // Converting context to color
        var chars = context.cStringUsingEncoding(NSUTF8StringEncoding)
        var c0 = Int(chars?[0] ?? 0)
        var c1 = Int(chars?[1] ?? 0)
        var c2 = Int(chars?[2] ?? 0)
        var c3 = Int(chars?[3] ?? 0)

        var r = (c0 * c1) % 255
        var g = (c1 * c2) % 255
        var b = (c2 * c3) % 255
        theContext = ESCAPE + "fg\(r),\(g),\(b);" + theContext + ESCAPE + "fg;"
        theMessage = ESCAPE + "fg\(r),\(g),\(b);" + theMessage + ESCAPE + "fg;"
      } else {
        theContext = "\(cDefaultBegin)\(theContext)\(cDefaultEnd)"
        theMessage = "\(cDefaultBegin)\(theMessage)\(cDefaultEnd)"
      }
    }

    var logMessage = separatorPrefix + theLevel + separatorContext + theContext + separatorPrefix
      + " " + theMessage
      + " " + separatorLocationBegin + theFunction + separatorLocation + theFile + separatorLocationEnd
    if let buffer = logMessage.cStringUsingEncoding(NSUTF8StringEncoding) {
      puts(buffer)
    } else {
      println(logMessage)
    }
    //fflush(stdout)
  }
}

public class Logger {

  private var context: String

  public class func getLogger(context: String) -> Logger {
    return Logger(context: context)
  }

  private init(context: String) {
    self.context = context
  }

  public func error<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    ColorLog.logMessage(message, level: .Error, context: self.context, function: function, file: file.lastPathComponent, line: line)
  }

  public func warn<T>  (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    ColorLog.logMessage(message, level: .Warn, context: self.context, function: function, file: file.lastPathComponent, line: line)
  }

  public func info<T>  (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    ColorLog.logMessage(message, level: .Info, context: self.context, function: function, file: file.lastPathComponent, line: line)
  }

  public func debug<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    ColorLog.logMessage(message, level: .Debug, context: self.context, function: function, file: file.lastPathComponent, line: line)
  }

  public func verbose<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    ColorLog.logMessage(message, level: .Verbose, context: self.context, function: function, file: file.lastPathComponent, line: line)
  }
}

public func logError<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  ColorLog.logMessage(message, level: .Error, context: ColorLog.kGlobalContextCode, function: function, file: file.lastPathComponent, line: line)
}

public func logWarn<T>  (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  ColorLog.logMessage(message, level: .Warn, context: ColorLog.kGlobalContextCode, function: function, file: file.lastPathComponent, line: line)
}

public func logInfo<T>  (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  ColorLog.logMessage(message, level: .Info, context: ColorLog.kGlobalContextCode, function: function, file: file.lastPathComponent, line: line)
}

public func logDebug<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  ColorLog.logMessage(message, level: .Debug, context: ColorLog.kGlobalContextCode, function: function, file: file.lastPathComponent, line: line)
}

public func logVerbose<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  ColorLog.logMessage(message, level: .Verbose, context: ColorLog.kGlobalContextCode, function: function, file: file.lastPathComponent, line: line)
}
