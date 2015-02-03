/// File: FacebookFriendsLoadManagerTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 03.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest
import FacebookProfileViewerClasses

class FacebookFriendsLoadManagerTests : XCTestCase {
  
  func testUserFriends() {
    var exp = expectationWithDescription("Fetch friends")
    let mngr = FacebookFriendsLoadManager()
    mngr.fetchUserFriends( { (results: FacebookFriendsLoadManager.FetchResults) -> Void in
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
