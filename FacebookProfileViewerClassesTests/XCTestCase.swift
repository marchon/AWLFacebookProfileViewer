/// File: EnpointTestCase.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 04.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest

private var gEnpointTestCaseExpectation: XCTestExpectation?

extension XCTestCase {
  
  var expectation: XCTestExpectation {
    get {
      return gEnpointTestCaseExpectation!
    }
    set {
      gEnpointTestCaseExpectation = newValue
    }
  }
  
  func reportFailure(error: NSError) {
    XCTFail("Unexpected error: \(error)")
    self.expectation.fulfill()
  }
  
}
