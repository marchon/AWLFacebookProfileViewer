/// File: Logging.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 29.01.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

public func logError (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  println("|E| \(message) <\(file.lastPathComponent):\(line), \(function)>")
}

public func logWarn  (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  println("|W| \(message) <\(file.lastPathComponent):\(line), \(function)>")
}

public func logInfo  (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  println("|I| \(message) <\(file.lastPathComponent):\(line), \(function)>")
}

public func logDebug (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  println("|D| \(message) <\(file.lastPathComponent):\(line), \(function)>")
}

public func logVerbose (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  println("|V| \(message) <\(file.lastPathComponent):\(line), \(function)>")
}

public func logError (error: NSError, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
  println("|E| \(error.description) <\(file.lastPathComponent):\(line), \(function)>")
}