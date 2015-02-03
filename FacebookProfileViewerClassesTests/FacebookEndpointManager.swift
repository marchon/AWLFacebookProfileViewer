//
//  FacebookEndpointManager.swift
//  FacebookProfileViewerClassesTests
//
//  Created by Vlad Gorlov on 25.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit
import XCTest
import FacebookProfileViewerClasses

class FacebookEndpointManagerTests: XCTestCase {
  
  var expectation: XCTestExpectation!
  var manager = FacebookEndpointManager()
  
  override func setUp() {
    super.setUp()
    expectation = expectationWithDescription("Fetch request")
  }
  
  func testDownloadUserProfileImage() {
    var fetchTask = manager.fetchUserPictureURLTask({(url: String) -> Void in
      
      var downloadTask = self.manager.photoDownloadTask(url,
        success: { (image: UIImage) -> Void in
          self.expectation.fulfill()
        },
        failure: {(error: NSError) -> Void in
          logError(error)
          XCTFail("Should not be called")
          self.expectation.fulfill()
        }
      )
      
      XCTAssertNotNil(downloadTask)
      if let task = downloadTask {
        task.resume()
      } else {
        self.expectation.fulfill()
      }
      
      },
      failure: {(error: NSError) -> Void in
        XCTFail("Should not be called")
        logError(error)
        self.expectation.fulfill()
      }
    )
    
    XCTAssertNotNil(fetchTask)
    if let task = fetchTask {
      task.resume()
    } else {
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(30, handler: nil)
  }
  
  func testFetchUserProfileInfo() {
    var fetchTask = manager.fetchUserProfileInformationTask(
      {(json: NSDictionary) -> Void in
        self.expectation.fulfill()
      },
      failure: {(error: NSError) -> Void in
        logError(error)
        XCTFail("Should not be called")
        self.expectation.fulfill()
      }
    )
    
    XCTAssertNotNil(fetchTask)
    if let task = fetchTask {
      task.resume()
    } else {
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(30, handler: nil)
  }
  
  func testFetchFriends() {
    var fetchTask = manager.fetchFriendsTask(nil, success:
      {(json: NSDictionary) -> Void in
        self.expectation.fulfill()
      },
      failure: {(error: NSError) -> Void in
        logError(error)
        XCTFail("Should not be called")
        self.expectation.fulfill()
      }
    )
    
    XCTAssertNotNil(fetchTask)
    if let task = fetchTask {
      task.resume()
    } else {
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(30, handler: nil)
  }
  
}
