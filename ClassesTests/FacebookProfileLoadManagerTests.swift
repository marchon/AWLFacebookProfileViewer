/// File: FacebookProfileLoadManagerTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 03.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest
import FBPVClasses

class FacebookProfileLoadManagerTests : XCTestCase {
  
  func testFetchUserProfile() {
    self.expectation = expectationWithDescription("Fetch request")
    let mngr = FacebookProfileLoadManager()
    mngr.fetchUserProfile( success: { (results: FacebookProfileLoadManager.FetchResults) -> Void in
      XCTAssertNotNil(results.userProfile)
      XCTAssertNotNil(results.coverPhotoImageData)
      XCTAssertNotNil(results.avatarPictureImageData)
      self.expectation.fulfill()
      },
      failure: { (error: NSError) -> Void in
        self.reportFailure(error)
    })
    
    waitForExpectationsWithTimeout(30, handler: nil)
  }
}
