/// File: FacebookPostsLoadManagerTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest
import FacebookProfileViewerClasses

class FacebookPostsLoadManagerTests: EnpointTestCase {
  
  func testUserPosts() {
    let mngr = FacebookPostsLoadManager()
    mngr.fetchUserPosts( { (results: FacebookPostsLoadManager.FetchResults) -> Void in
      XCTAssertTrue(results.isResultsValid)
      self.expectation.fulfill()
      },
      failure: { (error: NSError) -> Void in
        self.reportFailure(error)
    })
    
    waitForExpectationsWithTimeout(60, handler: nil)
  }
  
}
