//
//  FacebookEndpointManagerTests.swift
//  FacebookProfileViewerClassesTests
//
//  Created by Vlad Gorlov on 25.01.15.
//  Copyright (c) 2015 WaveLabs. All rights reserved.
//

import UIKit
import XCTest
import FacebookProfileViewerClasses

class FacebookEndpointManagerTests: EnpointTestCase {

  var manager = FacebookEndpointManager()

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
    var url = manager.fetchFriendsURL(nil)
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
