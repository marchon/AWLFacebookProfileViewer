//
//  FacebookProfileViewerClassesTests.swift
//  FacebookProfileViewerClassesTests
//
//  Created by Vlad Gorlov on 25.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit
import XCTest
import FacebookProfileViewerClasses

class FacebookProfileViewerClassesTests: XCTestCase {

  func testDownloadUserProfileImage() {
    var exp = expectationWithDescription("Fetch picture")
    var manager = FacebookEndpointManager()
    var fetchTask = manager.fetchUserPictureURLDataTask({(url: String) -> Void in
      var downloadTask = manager.profilePictureImageDownloadTask(url, success: { (image: UIImage) -> Void in
        exp.fulfill()
        },
        failure: {(error: NSError) -> Void in
          XCTFail("Should not be called")
      })

      XCTAssertNotNil(downloadTask)
      downloadTask?.resume()
    }, failure: {(error: NSError) -> Void in
      XCTFail("Should not be called")
    })

    XCTAssertNotNil(fetchTask)
    fetchTask?.resume()
    waitForExpectationsWithTimeout(100, handler: nil)
  }

}
