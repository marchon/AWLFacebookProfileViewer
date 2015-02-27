/// File: FacebookPostsLoadManagerTests.swift
/// Project: FacebookProfileViewer
/// Author: Created by Volodymyr Gorlov on 05.02.15.
/// Copyright: Copyright (c) 2015 WaveLabs. All rights reserved.

import UIKit
import XCTest
import FBPVClasses

class FacebookPostsLoadManagerTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    self.expectation = expectationWithDescription("Fetch request")
  }
  
  func testFetch100OldPosts() {
    let mngr = FacebookPostsLoadManager()
    
    let until = NSDateFormatter.facebookDateFormatter().dateFromString("2014-12-31T20:00:00+0000")
    
    mngr.fetchUserPosts(since: nil, until: until!, maxPostsToFetch: 100,
      success: { (results: [NSDictionary]) -> Void in
        XCTAssertTrue(results.count >= 0)
      },
      failure: { (error: NSError) -> Void in
        self.reportFailure(error)
      },
      completion: { (lastPageReached: Bool) -> Void in
        self.expectation.fulfill()
      }
    )
    
    waitForExpectationsWithTimeout(60, handler: nil)
  }
  
  func testFetchNewPostsBeforeCertainDate() {
    let mngr = FacebookPostsLoadManager()
    
    let since = NSDateFormatter.facebookDateFormatter().dateFromString("2014-11-01T20:00:00+0000")
    
    mngr.fetchUserPosts(since: since, until: nil, maxPostsToFetch: 100,
      success: { (results: [NSDictionary]) -> Void in
        XCTAssertTrue(results.count >= 0)
      },
      failure: { (error: NSError) -> Void in
        self.reportFailure(error)
      },
      completion: { (lastPageReached: Bool) -> Void in
        self.expectation.fulfill()
    })
    
    waitForExpectationsWithTimeout(600, handler: nil)
  }
  
  func testLast60Posts() {
    let mngr = FacebookPostsLoadManager()
    
    mngr.fetchUserPosts(since: nil, until: nil, maxPostsToFetch: 60,
      success: { (results: [NSDictionary]) -> Void in
        XCTAssertTrue(results.count >= 0)
      },
      failure: { (error: NSError) -> Void in
        self.reportFailure(error)
      },
      completion: { (lastPageReached: Bool) -> Void in
        self.expectation.fulfill()
    })
    
    waitForExpectationsWithTimeout(600, handler: nil)
  }
  
}
