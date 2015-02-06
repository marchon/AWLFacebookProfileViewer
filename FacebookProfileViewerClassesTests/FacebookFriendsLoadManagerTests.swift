/// File: FacebookFriendsLoadManagerTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 03.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest
import FacebookProfileViewerClasses

class FacebookFriendsLoadManagerTests : EnpointTestCase {
  
  func testUserFriends() {
    let mngr = FacebookFriendsLoadManager()
    mngr.fetchUserFriends({
      (results: [NSDictionary]) -> Void in
      XCTAssertTrue(results.count > 0)
      },
      success: { (results: [NSDictionary]) -> Void in
      XCTAssertTrue(results.count > 0)
      self.expectation.fulfill()
      },
      failure: { (error: NSError) -> Void in
        self.reportFailure(error)
    })
    
    waitForExpectationsWithTimeout(30, handler: nil)
  }
  
}
