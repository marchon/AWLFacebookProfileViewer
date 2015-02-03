/// File: FacebookProfileLoadManagerTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 03.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest
import FacebookProfileViewerClasses

class FacebookProfileLoadManagerTests : XCTestCase {
  
  func testFetchUserProfile() {
    var exp = expectationWithDescription("Fetch profile")
    let mngr = FacebookProfileLoadManager()
    mngr.fetchUserProfile( { (results: FacebookProfileLoadManager.FetchResults) -> Void in
      XCTAssertTrue(results.isResultsValid)
      exp.fulfill()
      },
      failure: { (error: NSError) -> Void in
        logError(error)
        XCTFail("Unecpected error: \(error)")
        exp.fulfill()
    })
    
    waitForExpectationsWithTimeout(30, handler: nil)
  }
}
