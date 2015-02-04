/// File: FacebookProfileLoadManagerTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 03.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest
import FacebookProfileViewerClasses

class FacebookProfileLoadManagerTests : EnpointTestCase {

  func testFetchUserProfile() {
    let mngr = FacebookProfileLoadManager()
    mngr.fetchUserProfile( { (results: FacebookProfileLoadManager.FetchResults) -> Void in
      XCTAssertTrue(results.isResultsValid)
      self.expectation.fulfill()
      },
      failure: { (error: NSError) -> Void in
        self.reportFailure(error)
    })

    waitForExpectationsWithTimeout(30, handler: nil)
  }
}
