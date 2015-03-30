/// File: Logging.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation
import NSLoggerClient

#if DEBUG
  private func initOnce() {
    struct TokenHolder {
      static var token: dispatch_once_t = 0;
    }
    dispatch_once(&TokenHolder.token) {
      var defaultLogger = LoggerCheckDefaultLogger()
      LoggerSetOptions(defaultLogger, UInt32(kLoggerOption_BrowseBonjour | kLoggerOption_BufferLogsUntilConnection))
    }
  }
#endif

private struct LoggerImpl {

  static let kContextCodeGlobal  = "global"
  static let kContextCodeNetwork = "network"
  static let kContextCodeModel   = "model"
  static let kContextCodeData    = "data"
  static let kContextCodeView    = "view"

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

    var theContext              = context + String(count: 8 - context.length, repeatedValue: Character(" "))
    var theFile                 = "\(file.lastPathComponent):\(line)"
    var theMessage              = "\(message)"

    #if DEBUG
      initOnce()
      let fileNameBuffer = file.cStringUsingEncoding(NSUTF8StringEncoding)!
      let funcNameBuffer = function.cStringUsingEncoding(NSUTF8StringEncoding)!
      LogMessageRawF(fileNameBuffer, line, funcNameBuffer, context, level.integerValue, theMessage)
    #endif

    var thePrefix = "[\(level.rawValue):\(theContext)]"
    var theLocation = "<\(function)@\(theFile)>"
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

  static func logMarker(name: String) {
    #if DEBUG
      initOnce()
      LogMarker(name)
    #endif

    #if DEBUG || TEST
      let msg = name  + "\n" + String(count: name.length, repeatedValue: Character("-"))
      if let buffer = msg.cStringUsingEncoding(NSUTF8StringEncoding) {
        puts(buffer)
      } else {
        println(name)
      }
      //fflush(stdout)
    #endif
  }
}


public func logMarker (name: String) {
  LoggerImpl.logMarker(name)
}

// GLobal

public func logError<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Error, context: LoggerImpl.kContextCodeGlobal, function: function, file: file, line: line)
}

public func logWarn<T>  (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Warn, context: LoggerImpl.kContextCodeGlobal, function: function, file: file, line: line)
}

public func logInfo<T>  (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Info, context: LoggerImpl.kContextCodeGlobal, function: function, file: file, line: line)
}

public func logDebug<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Debug, context: LoggerImpl.kContextCodeGlobal, function: function, file: file, line: line)
}

public func logVerbose<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Verbose, context: LoggerImpl.kContextCodeGlobal, function: function, file: file, line: line)
}

// Data

public func logErrorData<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Error, context: LoggerImpl.kContextCodeData, function: function, file: file, line: line)
}

public func logDebugData<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Debug, context: LoggerImpl.kContextCodeData, function: function, file: file, line: line)
}

public func logVerboseData<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Verbose, context: LoggerImpl.kContextCodeData, function: function, file: file, line: line)
}

// Model

public func logDebugModel<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Debug, context: LoggerImpl.kContextCodeModel, function: function, file: file, line: line)
}

// Network

public func logErrorNetwork<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Error, context: LoggerImpl.kContextCodeNetwork, function: function, file: file, line: line)
}

public func logDebugNetwork<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Debug, context: LoggerImpl.kContextCodeNetwork, function: function, file: file, line: line)
}

public func logVerboseNetwork<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Verbose, context: LoggerImpl.kContextCodeNetwork, function: function, file: file, line: line)
}


// View

public func logDebugView<T> (message: T, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  LoggerImpl.logMessage(message, level: .Debug, context: LoggerImpl.kContextCodeView, function: function, file: file, line: line)
}