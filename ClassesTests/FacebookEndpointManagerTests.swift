//
//  FacebookEndpointManagerTests.swift
//  FBPVClassesTests
//
//  Created by Vlad Gorlov on 25.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit
import XCTest
import FBPVClasses

class FacebookEndpointManagerTests: XCTestCase {

  var manager = FacebookEndpointManager()
  
  override func setUp() {
    super.setUp()
    self.expectation = expectationWithDescription("Fetch request")
  }

  func testDownloadUserProfileImage() {
    var url = manager.fetchUserPictureURL()
    manager.fetchFacebookGraphAPITask(url!,
        success: {(json: NSDictionary) -> Void in

          var downloadURL = json.valueForKeyPath("data.url") as? String
          XCTAssertNotNil(downloadURL)
          let url = NSURL(string: downloadURL!)

          self.manager.photoDownloadTask(url!,
            success: { (image: UIImage) -> Void in
              self.expectation.fulfill()
            },
            failure: {(error: NSError) -> Void in
              self.reportFailure(error)
            }
          ).resume()

        },
        failure: {(error: NSError) -> Void in
          self.reportFailure(error)
        }
    ).resume()

    waitForExpectationsWithTimeout(30, handler: nil)
  }

  func testFetchUserProfileInfo() {
    var url = manager.fetchUserProfileInformationURL()
    manager.fetchFacebookGraphAPITask(url!,
      success: {(json: NSDictionary) -> Void in
        self.expectation.fulfill()
      },
      failure: {(error: NSError) -> Void in
        self.reportFailure(error)
      }
    ).resume()

    waitForExpectationsWithTimeout(30, handler: nil)
  }

  func testFetchFriends() {
    var url = manager.fetchFriendsURL()
    manager.fetchFacebookGraphAPITask(url!,
      success:
      {(json: NSDictionary) -> Void in
        self.expectation.fulfill()
      },
      failure: {(error: NSError) -> Void in
        self.reportFailure(error)
      }
    ).resume()

    waitForExpectationsWithTimeout(30, handler: nil)
  }

  func testFetchPosts() {
    var url = manager.fetchPostsURL()
    manager.fetchFacebookGraphAPITask(url!,
        success:
        {(json: NSDictionary) -> Void in
          self.expectation.fulfill()
        },
        failure: {(error: NSError) -> Void in
          self.reportFailure(error)
        }
    ).resume()

    waitForExpectationsWithTimeout(30, handler: nil)
  }
  
}
