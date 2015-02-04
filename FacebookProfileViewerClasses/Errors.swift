/// File: Errors.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 04.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import Foundation

let OperationErrorDomain = "FacebookGraphAPITaskErrorDomain"
enum OperationErrorCode: Int {
  case ServerError = -101
  case ResponseDataIsMissed = -102
  case UnexpectedResponseCode = -103
  case MissedAttribute = -104
  case HandleDownloadError = -105
}



let UninitializedTaskErrorDomain = "UninitializedTaskErrorDomain"
let UninitializedTaskErrorCode = -1


extension NSError {
  class func errorForMissedAttribute(attribute: String) -> NSError {
    let e = NSError(domain: OperationErrorDomain,
      code: OperationErrorCode.MissedAttribute.rawValue,
      userInfo: [NSLocalizedFailureReasonErrorKey: "Attribute: \(attribute)"])
    return e
  }

  class func errorForUninitializedURL() -> NSError {
    let e = NSError(domain: UninitializedTaskErrorDomain, code: UninitializedTaskErrorCode, userInfo: nil)
    return e
  }
}


