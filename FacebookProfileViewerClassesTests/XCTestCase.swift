/// File: EnpointTestCase.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 04.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest

private var gEnpointTestCaseExpectation: XCTestExpectation?

extension XCTestCase {

  var expectation: XCTestExpectation {
      return gEnpointTestCaseExpectation!
  }
  
  public override func setUp() {
    super.setUp()
    gEnpointTestCaseExpectation = expectationWithDescription("Fetch request")
  }

  func reportFailure(error: NSError) {
    XCTFail("Unexpected error: \(error)")
    self.expectation.fulfill()
  }

}
