/// File: FacebookFriendsLoadManagerTests.swift
/// Project: FBPV
/// Author: Created by Volodymyr Gorlov on 03.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest
import FBPVClasses

class FacebookFriendsLoadManagerTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    self.expectation = expectationWithDescription("Fetch request")
  }
  
  func testUserFriends() {
    let mngr = FacebookFriendsLoadManager()
    mngr.fetchUserFriends(success: {
      (results: [NSDictionary]) -> Void in
      XCTAssertTrue(results.count > 0)
    }, failure: {
      (error: NSError) -> Void in
      self.reportFailure(error)
    }, completion: {
      self.expectation.fulfill()
    })

    waitForExpectationsWithTimeout(30, handler: nil)
  }

}
