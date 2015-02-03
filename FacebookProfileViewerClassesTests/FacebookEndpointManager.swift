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
  
  func testDownloadUserProfileImage() {
    var exp = expectationWithDescription("Fetch picture")
    var manager = FacebookEndpointManager()
    var fetchTask = manager.fetchUserPictureURLTask({(url: String) -> Void in
      
      var downloadTask = manager.profilePictureImageDownloadTask(url,
        success: { (image: UIImage) -> Void in
          exp.fulfill()
        },
        failure: {(error: NSError) -> Void in
          logError(error)
          XCTFail("Should not be called")
          exp.fulfill()
        }
      )
      
      XCTAssertNotNil(downloadTask)
      downloadTask?.resume()
      
      },
      failure: {(error: NSError) -> Void in
        XCTFail("Should not be called")
        logError(error)
        exp.fulfill()
      }
    )
    
    XCTAssertNotNil(fetchTask)
    if let task = fetchTask {
      task.resume()
    } else {
      exp.fulfill()
    }
    
    waitForExpectationsWithTimeout(30, handler: nil)
  }
  
  func testFetchUserProfileInfo() {
    var exp = expectationWithDescription("Fetch picture")
    var manager = FacebookEndpointManager()
    var fetchTask = manager.fetchUserProfileInformationTask(
      {(json: NSDictionary) -> Void in
        exp.fulfill()
      },
      failure: {(error: NSError) -> Void in
        logError(error)
        XCTFail("Should not be called")
        exp.fulfill()
      }
    )
    
    XCTAssertNotNil(fetchTask)
    if let task = fetchTask {
      task.resume()
    } else {
      exp.fulfill()
    }
    waitForExpectationsWithTimeout(30, handler: nil)
  }
  
}
