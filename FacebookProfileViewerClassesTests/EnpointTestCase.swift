/// File: EnpointTestCase.swift
/// Project: FacebookProfileViewer
/// Author: Created by Vlad Gorlov on 04.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest

class EnpointTestCase : XCTestCase {

  var expectation: XCTestExpectation!

  override func setUp() {
    super.setUp()
    expectation = expectationWithDescription("Fetch request")
  }

  func reportFailure(error: NSError) {
    XCTFail("Unexpected error: \(error)")
    self.expectation.fulfill()
  }

}
