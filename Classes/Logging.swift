/// File: Logging.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation
import NSLoggerClient

private func initOnce() {
  struct TokenHolder {
    static var token: dispatch_once_t = 0;
  }
  dispatch_once(&TokenHolder.token) {
    var defaultLogger = LoggerCheckDefaultLogger()
    LoggerSetOptions(defaultLogger, UInt32(kLoggerOption_BrowseBonjour | kLoggerOption_BufferLogsUntilConnection))
  }
}

private struct LoggerImpl {

  static let kGlobalContextCode = "GLOB"

  enum LogLevel : String {
    case Error   = "E"
    case Warn    = "W"
    case Info    = "I"
    case Debug   = "D"
    case Verbose = "V"
    var integerValue: Int32 {
      switch self {
      case .Error:
        return 0
      case .Warn:
        return 1
      case .Info:
        return 2
      case .Debug:
        return 3
      case .Verbose:
        return 4
      }
    }
  }

  static func logMessage<T>(message: T, level: LogLevel, context: String, function: String, file: String, line: Int32) {
    initOnce()
    assert(context.length == 4, "Context should be 4 letters lenght")
    var theLevel                = level.rawValue
    var theContext              = context
    var theFunction             = function
    var theFile                 = "\(file.lastPathComponent):\(line)"
    var theMessage              = "\(message)"
    var separatorPrefix         = "|"
    var separatorContext        = ":"
    var separatorLocation       = ";"
    var separatorLocationBegin  = "<"
    var separatorLocationEnd    = ">"

    #if DEBUG
    let fileNameBuffer = file.cStringUsingEncoding(NSUTF8StringEncoding)!
    let funcNameBuffer = function.cStringUsingEncoding(NSUTF8StringEncoding)!
    LogMessageRawF(fileNameBuffer, line, funcNameBuffer, context, level.integerValue, theMessage)
    #endif

    var thePrefix = separatorPrefix + theLevel + separatorContext + theContext + separatorPrefix
    var theLocation = separatorLocationBegin + theFunction + separatorLocation + theFile + separatorLocationEnd
    var logMessage = thePrefix + " " + theMessage + " " + theLocation

    #if DEBUG || TEST
    if let buffer = logMessage.cStringUsingEncoding(NSUTF8StringEncoding) {
      puts(buffer)
    } else {
      println(logMessage)
    }
    //fflush(stdout)
    #endif
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
    LoggerImpl.logMessage(message, level: .Error, context: self.context, function: function, file: file, line: line)
  }

  public func warn<T>  (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    LoggerImpl.logMessage(message, level: .Warn, context: self.context, function: function, file: file, line: line)
  }

  public func info<T>  (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    LoggerImpl.logMessage(message, level: .Info, context: self.context, function: function, file: file, line: line)
  }

  public func debug<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    LoggerImpl.logMessage(message, level: .Debug, context: self.context, function: function, file: file, line: line)
  }

  public func verbose<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    LoggerImpl.logMessage(message, level: .Verbose, context: self.context, function: function, file: file, line: line)
  }
}

public func logError<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Error, context: LoggerImpl.kGlobalContextCode, function: function, file: file, line: line)
}

public func logWarn<T>  (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Warn, context: LoggerImpl.kGlobalContextCode, function: function, file: file, line: line)
}

public func logInfo<T>  (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Info, context: LoggerImpl.kGlobalContextCode, function: function, file: file, line: line)
}

public func logDebug<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Debug, context: LoggerImpl.kGlobalContextCode, function: function, file: file, line: line)
}

public func logVerbose<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Verbose, context: LoggerImpl.kGlobalContextCode, function: function, file: file, line: line)
}
