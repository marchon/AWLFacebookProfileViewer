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
  case IncompleteDictionary = -106
}



let UninitializedTaskErrorDomain = "UninitializedTaskErrorDomain"
let UninitializedTaskErrorCode = -1


public extension NSError {
  public class func errorForMissedAttribute(attribute: String) -> NSError {
    let e = NSError(domain: OperationErrorDomain,
      code: OperationErrorCode.MissedAttribute.rawValue,
      userInfo: [NSLocalizedFailureReasonErrorKey: "Attribute: \(attribute)"])
    return e
  }
  
  public class func errorForIncompleteDictionary(json: NSDictionary) -> NSError {
    let e = NSError(domain: OperationErrorDomain,
      code: OperationErrorCode.IncompleteDictionary.rawValue,
      userInfo: [NSLocalizedFailureReasonErrorKey: "JSON: \(json)"])
    return e
  }

  public class func errorForUninitializedURL() -> NSError {
    let e = NSError(domain: UninitializedTaskErrorDomain, code: UninitializedTaskErrorCode, userInfo: nil)
    return e
  }

  public var securedDescription: String {
    #if TEST || DEBUG
      return self.description
      #else
      if let token = PersistenceStore.sharedInstance().facebookAccesToken {
      return self.description.stringByReplacingOccurrencesOfString(token, withString: "TOKEN-WAS-STRIPPED")
      } else {
      return self.description
      }
    #endif
  }

}


